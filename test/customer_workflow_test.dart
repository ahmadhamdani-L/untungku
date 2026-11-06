import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/entities.dart';
import 'package:untungku_pro/features/app.dart';

const date = '2026-11-04T10:00:00';
Contact customer(String id, {bool archived = false}) => Contact(
  id: id,
  name: 'Rina',
  phone: id == 'a' ? '081111' : '082222',
  created: date,
  updated: date,
  archived: archived,
);
const line = SaleLine(
  productId: 'p',
  name: 'Kopi',
  quantity: 1,
  price: 10000,
  cost: 5000,
  packaging: 0,
  extra: 0,
);
void main() {
  late AppDatabase db;
  late Store store;
  bool widgetOwnsStore = false;
  setUpAll(() => initializeDateFormatting('id_ID'));
  setUp(() async {
    widgetOwnsStore = false;
    db = AppDatabase(NativeDatabase.memory());
    store = Store(db);
    await store.load();
    await store.saveProduct(
      const Product(
        id: 'p',
        name: 'Kopi',
        price: 10000,
        cost: 5000,
        stock: 10,
        created: date,
        updated: date,
      ),
    );
    await store.saveContact(customer('a'));
    await store.saveContact(customer('b'));
  });
  tearDown(() async {
    if (!widgetOwnsStore) store.dispose();
    await db.close();
  });

  test(
    'unchanged sale can be explicitly linked; duplicate names and balances stay separate through backup',
    () async {
      const sale = Sale(
        id: 'legacy',
        date: date,
        lines: [line],
        customer: 'Rina',
        credit: true,
      );
      await store.saveSale(sale);
      final raw = (await db.select(db.saleRows).get()).single.payload;
      await store.saveSale(
        sale,
        customerId: 'b',
        checkoutOperationId: 'link-checkout',
      );
      expect(await store.customerLinks(), {'legacy': 'b'});
      expect((await db.select(db.saleRows).get()).single.payload, raw);
      await store.recordPayment(
        'legacy',
        const SalePayment(
          id: 'payment',
          date: date,
          amount: 3000,
          method: 'Tunai',
        ),
      );
      final backup = store.backup();
      await store.restore(backup);
      expect((await store.contacts()).length, 2);
      expect(await store.customerLinks(), {'legacy': 'b'});
      expect(store.sales.single.outstanding, 7000);
      expect(store.sales.single.result.revenue, 10000);
      expect((await store.cashBalances())[null], 3000);
    },
  );
  test(
    'manual relinking preserves name snapshot and retains prior audit events',
    () async {
      await store.saveSale(
        const Sale(
          id: 'legacy',
          date: date,
          lines: [line],
          customer: 'Nama lama',
          credit: true,
        ),
      );
      final raw = (await db.select(db.saleRows).get()).single.payload;
      await store.linkCustomer('legacy', 'a', operationId: 'link-a');
      await store.linkCustomer('legacy', 'a', operationId: 'link-a');
      await store.linkCustomer('legacy', 'b', operationId: 'link-b');
      await expectLater(
        store.linkCustomer('legacy', 'a', operationId: 'link-b'),
        throwsStateError,
      );
      final operations = await db.select(db.operationRows).get();
      expect(
        operations.where((r) => ['link-a', 'link-b'].contains(r.id)).length,
        2,
      );
      expect(await store.customerLinks(), {'legacy': 'b'});
      expect((await db.select(db.saleRows).get()).single.payload, raw);
      await store.saveContact(customer('b', archived: true));
      expect(store.sales.single.outstanding, 10000);
      expect(await store.customerLinks(), {'legacy': 'b'});
      await expectLater(store.linkCustomer('legacy', 'b'), throwsArgumentError);
      await store.saveContact(customer('b'));
      await store.linkCustomer('legacy', 'b');
      expect((await db.select(db.saleRows).get()).single.payload, raw);
    },
  );
  test(
    'invalid customer checkout rolls back sale, stock and operation key',
    () async {
      await store.saveContact(customer('a', archived: true));
      for (final id in ['a', 'missing']) {
        await expectLater(
          store.saveSale(
            const Sale(id: 's', date: date, lines: [line]),
            customerId: id,
            checkoutOperationId: 'checkout',
          ),
          throwsA(anything),
        );
        expect(store.sales, isEmpty);
        expect(store.products.single.stock, 10);
        expect(await store.cashLedger(), isEmpty);
        expect(
          (await db.select(db.operationRows).get()).where(
            (r) => r.id == 'checkout',
          ),
          isEmpty,
        );
      }
      await store.saveContact(customer('a'));
      await store.saveSale(
        const Sale(id: 's', date: date, lines: [line], customer: 'Rina'),
        customerId: 'a',
        checkoutOperationId: 'checkout',
      );
      expect(await store.customerLinks(), {'s': 'a'});
    },
  );
  test(
    'stale contact edit is rejected and malformed linked backup leaves live data intact',
    () async {
      await store.saveContact(
        Contact.fromJson({
          ...customer('a').toJson(),
          'updated': '2026-11-04T11:00:00',
          'name': 'Nama baru',
        }),
        expectedUpdated: date,
      );
      await expectLater(
        store.saveContact(customer('a'), expectedUpdated: date),
        throwsStateError,
      );
      await store.saveSale(
        const Sale(id: 's', date: date, lines: [line]),
        customerId: 'a',
      );
      final backup = jsonDecode(store.backup());
      backup['business']['saleCustomers'][0]['customerId'] = 'missing';
      await expectLater(
        store.restore(jsonEncode(backup)),
        throwsFormatException,
      );
      expect(
        (await store.contacts()).firstWhere((c) => c.id == 'a').name,
        'Nama baru',
      );
      expect(await store.customerLinks(), {'s': 'a'});
    },
  );
  testWidgets(
    'customer CRUD search and archive restore work without merging names',
    (tester) async {
      widgetOwnsStore = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: ContactsPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah pelanggan'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Sari');
      await tester.enterText(find.byType(TextFormField).at(1), '083333');
      await tester.ensureVisible(find.text('Simpan kontak'));
      await tester.tap(find.text('Simpan kontak'));
      await tester.pumpAndSettle();
      expect((await store.contacts()).length, 3);
      await tester.enterText(
        find.widgetWithText(TextField, 'Cari nama atau telepon'),
        '083333',
      );
      await tester.pumpAndSettle();
      expect(find.text('Sari'), findsOneWidget);
      expect(find.text('Rina'), findsNothing);
      await tester.tap(find.text('Sari'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit kontak'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Sari Baru');
      await tester.ensureVisible(find.text('Simpan kontak'));
      await tester.tap(find.text('Simpan kontak'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan kontak'));
      await tester.pumpAndSettle();
      expect(find.text('Kontak diarsipkan'), findsOneWidget);
      await tester.tap(find.text('Aktifkan kontak'));
      await tester.pumpAndSettle();
      expect(
        (await store.contacts())
            .singleWhere((c) => c.phone == '083333')
            .archived,
        false,
      );
      expect((await store.contacts()).where((c) => c.name == 'Rina').length, 2);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'sale selection uses customer ID and preserves selected cash-customer name',
    (tester) async {
      widgetOwnsStore = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: SaleForm()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kopi • stok 10').last);
      await tester.pumpAndSettle();
      final selector = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Pilih pelanggan (opsional)',
      );
      await tester.scrollUntilVisible(
        selector.hitTestable(),
        150,
        scrollable: find
            .descendant(
              of: find.byType(SaleForm),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(selector);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rina • 082222').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simpan penjualan'));
      await tester.tap(find.text('Simpan penjualan'));
      await tester.pumpAndSettle();
      expect(store.sales.single.customer, 'Rina');
      expect((await store.customerLinks())[store.sales.single.id], 'b');
      expect(store.sales.single.credit, false);
      expect(store.products.single.stock, 9);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
