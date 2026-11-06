import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/services/ads.dart';

const line = SaleLine(
  productId: 'p',
  name: 'Kopi',
  quantity: 2,
  price: 10000,
  cost: 5000,
  packaging: 0,
  extra: 0,
);
const payment = SalePayment(
  id: 'payment',
  date: '2026-11-03T12:00:00',
  amount: 5000,
  method: 'Tunai',
);
const creditSale = Sale(
  id: 'sale',
  date: '2026-11-03T10:00:00',
  lines: [line],
  credit: true,
  customer: 'Sari',
  dueDate: '2026-11-10',
);

void main() {
  late AppDatabase db;
  late Store store;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    store = Store(db);
    await store.load();
    await store.saveProduct(
      const Product(
        id: 'p',
        name: 'Kopi',
        cost: 5000,
        price: 10000,
        stock: 10,
        created: '2026-11-01',
        updated: '2026-11-01',
      ),
    );
  });
  tearDown(() async {
    store.dispose();
    await db.close();
  });

  test(
    'legacy sale and v1 backup remain fully paid without data loss',
    () async {
      final legacy = Sale.fromJson({
        'id': 'old',
        'date': '2026-11-03',
        'lines': [line.toJson()],
        'discount': 0,
        'fixed': 0,
        'feeBps': 0,
        'payment': 'Tunai',
        'note': '',
        'voided': false,
      });
      await store.saveSale(legacy);
      final backup = jsonDecode(store.backup()) as Map<String, dynamic>;
      backup['version'] = 1;
      await store.restore(jsonEncode(backup));
      expect(store.sales.single.credit, isFalse);
      expect(store.sales.single.paid, 20000);
      expect(store.sales.single.outstanding, 0);
      expect(store.products.single.stock, 8);
    },
  );

  test(
    'partial and full settlement do not change revenue, cost or stock; retry is idempotent',
    () async {
      await store.saveSale(creditSale);
      final movements = store.movements.length;
      await store.recordPayment('sale', payment);
      await store.recordPayment('sale', payment);
      expect(store.sales.single.paid, 5000);
      expect(store.sales.single.outstanding, 15000);
      expect(store.sales.single.paymentStatus, 'Sebagian');
      expect(store.sales.single.overdueAt(DateTime(2026, 11, 11)), isTrue);
      await store.recordPayment(
        'sale',
        const SalePayment(
          id: 'final',
          date: '2026-11-04',
          amount: 15000,
          method: 'QRIS',
        ),
      );
      expect(store.sales.single.paymentStatus, 'Lunas');
      expect(store.sales.single.result.revenue, 20000);
      expect(store.sales.single.result.net, 10000);
      expect(store.products.single.stock, 8);
      expect(store.movements.length, movements);
      final backup = store.backup();
      await store.restore(backup);
      expect(store.sales.single.payments.length, 2);
      expect(store.csv(), contains('Sari'));
      expect(store.csv(), contains('riwayat_pembayaran_json'));
    },
  );

  test(
    'overpayment, duplicate IDs and stale sale edits are rejected atomically',
    () async {
      await store.saveSale(creditSale);
      await store.recordPayment('sale', payment);
      await expectLater(
        store.recordPayment(
          'sale',
          const SalePayment(
            id: 'too-much',
            date: '2026-11-04',
            amount: 16000,
            method: 'Tunai',
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        store.recordPayment(
          'sale',
          const SalePayment(
            id: 'payment',
            date: '2026-11-04',
            amount: 1000,
            method: 'Tunai',
          ),
        ),
        throwsStateError,
      );
      await expectLater(store.saveSale(creditSale), throwsStateError);
      await store.load();
      expect(store.sales.single.paid, 5000);
      expect(store.products.single.stock, 8);
      final invalid = Sale.fromJson({
        ...store.sales.single.toJson(),
        'lines': [
          const SaleLine(
            productId: 'p',
            name: 'Kopi',
            quantity: 1,
            price: 4000,
            cost: 5000,
            packaging: 0,
            extra: 0,
          ).toJson(),
        ],
      });
      await expectLater(store.saveSale(invalid), throwsArgumentError);
      final b = jsonDecode(store.backup());
      b['sales'][0]['payments'][0]['amount'] = 21000;
      expect(() => Store.validateBackup(jsonEncode(b)), throwsArgumentError);
    },
  );

  test(
    'cancellation preserves payments and excludes receivables; no further settlement',
    () async {
      await store.saveSale(creditSale);
      await store.recordPayment('sale', payment);
      await store.voidSale('sale');
      await store.voidSale('sale');
      expect(store.sales.single.payments.length, 1);
      expect(store.sales.single.outstanding, 0);
      expect(store.products.single.stock, 10);
      await expectLater(store.recordPayment('sale', payment), throwsStateError);
      await store.restore(store.backup());
      expect(store.sales.single.voided, isTrue);
    },
  );

  test(
    'credit payment fields persist after reopening an existing schema v1 file',
    () async {
      final dir = await Directory.systemTemp.createTemp('untungku-upgrade');
      final file = File('${dir.path}/existing.sqlite');
      final product = store.products.single;
      store.dispose();
      await db.close();
      var disk = AppDatabase(NativeDatabase(file));
      var original = Store(disk);
      await original.load();
      await original.saveProduct(product);
      // Existing released payload has no credit fields.
      final legacy = {...creditSale.toJson()}
        ..remove('customer')
        ..remove('credit')
        ..remove('payments')
        ..remove('dueDate');
      await original.put('sale', 'sale', legacy);
      await disk.close();
      disk = AppDatabase(NativeDatabase(file));
      original = Store(disk);
      await original.load();
      expect(original.sales.single.outstanding, 0);
      await original.saveSale(
        const Sale(
          id: 'credit',
          date: '2026-11-03',
          lines: [line],
          credit: true,
          customer: 'Ayu',
        ),
      );
      await original.recordPayment('credit', payment);
      await disk.close();
      disk = AppDatabase(NativeDatabase(file));
      original = Store(disk);
      await original.load();
      expect(
        original.sales.firstWhere((s) => s.id == 'credit').outstanding,
        15000,
      );
      expect(
        (await disk.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        2,
      );
      await disk.close();
      await dir.delete(recursive: true);
      db = AppDatabase(NativeDatabase.memory());
      store = Store(db);
    },
  );

  test(
    'completion ads require 3 successful tasks, grace period, cooldown and session cap',
    () {
      final now = DateTime(2026, 11, 3, 10);
      final policy = CompletionAdPolicy(now)..completions = 3;
      expect(policy.eligible(now.add(const Duration(seconds: 119))), false);
      expect(policy.eligible(now.add(const Duration(minutes: 2))), true);
      policy.didShow(now.add(const Duration(minutes: 2)));
      expect(policy.eligible(now.add(const Duration(minutes: 6))), false);
      policy.completions = 3;
      expect(policy.eligible(now.add(const Duration(minutes: 4))), false);
      expect(policy.eligible(now.add(const Duration(minutes: 5))), true);
      policy.shown = 5;
      expect(policy.eligible(now.add(const Duration(hours: 1))), false);
    },
  );
}
