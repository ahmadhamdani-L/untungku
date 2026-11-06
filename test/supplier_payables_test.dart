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
void main() {
  late AppDatabase db;
  late Store store;
  bool owned = false;
  setUpAll(() => initializeDateFormatting('id_ID'));
  setUp(() async {
    owned = false;
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
    await store.saveContact(
      const Contact(
        id: 'supplier',
        name: 'Pemasok Kopi',
        created: date,
        updated: date,
      ),
      supplier: true,
    );
  });
  tearDown(() async {
    if (!owned) store.dispose();
    await db.close();
  });
  Purchase po(String id, {String? supplier = 'supplier'}) => Purchase(
    id: id,
    date: date,
    supplierId: supplier,
    lines: const [
      PurchaseLine(productId: 'p', name: 'Kopi', quantity: 2, unitCost: 7000),
    ],
  );
  test(
    'payables exclude drafts/cancellations and group partial payments by supplier without expense',
    () async {
      for (final id in ['draft', 'confirmed', 'cancelled']) {
        await store.savePurchaseDraft(po(id));
      }
      await store.confirmPurchase('confirmed', 'confirm');
      await store.cancelPurchase('cancelled', 'cancel', 'Salah pesan');
      await store.savePurchaseDraft(po('unassigned', supplier: null));
      await store.confirmPurchase('unassigned', 'confirm-unassigned');
      await store.paySupplier(
        id: 'pay',
        purchaseId: 'confirmed',
        amount: 4000,
        date: date,
        method: 'Tunai',
      );
      var report = await store.payableReport();
      final supplier = report.singleWhere((r) => r.supplierId == 'supplier');
      expect(supplier.purchaseCount, 1);
      expect(supplier.total, 14000);
      expect(supplier.paid, 4000);
      expect(supplier.outstanding, 10000);
      expect(
        report.singleWhere((r) => r.supplierId == null).outstanding,
        14000,
      );
      expect(store.expenses, isEmpty);
      expect(store.products.single.stock, 10);
      await store.restore(store.backup());
      report = await store.payableReport();
      expect(report.fold<int>(0, (sum, r) => sum + r.outstanding), 24000);
      await expectLater(
        store.paySupplier(
          id: 'too-much',
          purchaseId: 'confirmed',
          amount: 10001,
          date: date,
          method: 'Tunai',
        ),
        throwsArgumentError,
      );
      expect((await store.cashBalances())[null], -4000);
    },
  );
  test(
    'archived supplier cannot enter a new draft; old purchase and payable remain readable',
    () async {
      await store.savePurchaseDraft(po('old'));
      await store.confirmPurchase('old', 'confirm');
      final contact = (await store.contacts(suppliers: true)).single;
      await store.saveContact(
        Contact.fromJson({...contact.toJson(), 'archived': true}),
        supplier: true,
      );
      await expectLater(
        store.savePurchaseDraft(po('new')),
        throwsArgumentError,
      );
      expect((await store.purchase('old')).supplierId, contact.id);
      expect((await store.payableReport()).single.outstanding, 14000);
      await store.paySupplier(
        id: 'settle',
        purchaseId: 'old',
        amount: 14000,
        date: date,
        method: 'Tunai',
      );
      expect((await store.payableReport()).single.outstanding, 0);
    },
  );
  testWidgets(
    'supplier CRUD preserves identity and payables report displays outstanding debt',
    (tester) async {
      owned = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: ContactsPage(suppliers: true)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah pemasok'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Pemasok Baru');
      await tester.ensureVisible(find.text('Simpan kontak'));
      await tester.tap(find.text('Simpan kontak'));
      await tester.pumpAndSettle();
      expect((await store.contacts(suppliers: true)).length, 2);
      await tester.tap(find.text('Pemasok Baru'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan kontak'));
      await tester.pumpAndSettle();
      expect(find.text('Kontak diarsipkan'), findsOneWidget);
      await tester.tap(find.text('Aktifkan kontak'));
      await tester.pumpAndSettle();
      expect(
        (await store.contacts(suppliers: true)).every((c) => !c.archived),
        true,
      );
      await store.savePurchaseDraft(po('po'));
      await store.confirmPurchase('po', 'confirm');
      await store.paySupplier(
        id: 'pay',
        purchaseId: 'po',
        amount: 4000,
        date: date,
        method: 'Tunai',
      );
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const PurchasesPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Total utang pemasok'), findsOneWidget);
      expect(find.text('Pemasok Kopi'), findsOneWidget);
      expect(find.textContaining('10.000'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
