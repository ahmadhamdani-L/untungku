import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/entities.dart';

const date = '2026-11-03T10:00:00';
Contact contact(String id, String name) =>
    Contact(id: id, name: name, created: date, updated: date);
const line = SaleLine(
  productId: 'p',
  name: 'Kopi',
  quantity: 2,
  price: 10000,
  cost: 5000,
  packaging: 0,
  extra: 0,
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
        price: 10000,
        cost: 5000,
        stock: 10,
        created: date,
        updated: date,
      ),
    );
  });
  tearDown(() async {
    store.dispose();
    await db.close();
  });
  test(
    'contacts with identical names stay distinct and explicit linking preserves snapshots',
    () async {
      await store.saveContact(contact('a', 'Rina'));
      await store.saveContact(contact('b', 'Rina'));
      await store.saveSale(
        const Sale(
          id: 's',
          date: date,
          lines: [line],
          credit: true,
          customer: 'Rina',
        ),
      );
      expect(await store.customerLinks(), isEmpty);
      final before = store.sales.single.toJson();
      await store.linkCustomer('s', 'a');
      expect(await store.customerLinks(), {'s': 'a'});
      expect(store.sales.single.toJson(), before);
      await store.restore(store.backup());
      expect((await store.contacts()).length, 2);
      expect(await store.customerLinks(), {'s': 'a'});
      await expectLater(store.linkCustomer('s', 'missing'), throwsA(anything));
    },
  );
  test(
    'cash sale and checkout retry post once, partial collections are not extra revenue',
    () async {
      await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
      const s = Sale(id: 's', date: date, lines: [line], accountId: 'cash');
      await store.saveSale(s, checkoutOperationId: 'checkout');
      await store.saveSale(s, checkoutOperationId: 'checkout');
      expect(store.products.single.stock, 8);
      expect((await store.cashBalances())['cash'], 20000);
      expect((await store.cashLedger()).length, 1);
      await expectLater(
        store.saveSale(
          const Sale(id: 'different', date: date, lines: [line]),
          checkoutOperationId: 'checkout',
        ),
        throwsStateError,
      );
      await store.saveSale(
        const Sale(
          id: 'credit',
          date: date,
          lines: [line],
          credit: true,
          customer: 'Ayu',
        ),
      );
      expect((await store.cashBalances())['cash'], 20000);
      const pay = SalePayment(
        id: 'pay',
        date: date,
        amount: 5000,
        method: 'Tunai',
        accountId: 'cash',
      );
      await store.recordPayment('credit', pay);
      await store.recordPayment('credit', pay);
      expect((await store.cashBalances())['cash'], 25000);
      expect(
        store.sales.firstWhere((s) => s.id == 'credit').outstanding,
        15000,
      );
      expect(store.sales.fold(0, (v, s) => v + s.result.revenue), 40000);
    },
  );
  test(
    'transfer conserves consolidated cash and invalid destination rolls back',
    () async {
      await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
      await store.saveCashAccount(
        const CashAccount(id: 'bank', name: 'Bank', type: 'Bank'),
      );
      await store.recordCash(
        id: 'capital',
        accountId: 'cash',
        amount: 100000,
        category: 'owner_capital',
        date: date,
      );
      await store.recordCash(
        id: 'transfer',
        accountId: 'cash',
        destination: 'bank',
        amount: 40000,
        category: 'transfer',
        date: date,
      );
      await store.recordCash(
        id: 'transfer',
        accountId: 'cash',
        destination: 'bank',
        amount: 40000,
        category: 'transfer',
        date: date,
      );
      expect(await store.cashBalances(), {'cash': 60000, 'bank': 40000});
      await expectLater(
        store.recordCash(
          id: 'bad',
          accountId: 'cash',
          destination: 'missing',
          amount: 10000,
          category: 'transfer',
          date: date,
        ),
        throwsA(anything),
      );
      expect(await store.cashBalances(), {'cash': 60000, 'bank': 40000});
    },
  );
  test(
    'expense revisions and deletion preserve ledger with compensating entries',
    () async {
      await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
      await store.saveExpense(
        const Expense(
          id: 'e',
          date: date,
          category: 'Transportasi',
          note: '',
          amount: 1000,
        ),
        accountId: 'cash',
      );
      await store.saveExpense(
        const Expense(
          id: 'e',
          date: date,
          category: 'Transportasi',
          note: '',
          amount: 1500,
        ),
        accountId: 'cash',
      );
      expect((await store.cashBalances())['cash'], -1500);
      await store.deleteExpense('e');
      expect((await store.cashBalances())['cash'], 0);
      expect((await store.cashLedger()).length, 4);
    },
  );
  Purchase purchase(String id) => Purchase(
    id: id,
    date: date,
    supplierId: 'supplier',
    lines: const [
      PurchaseLine(productId: 'p', name: 'Kopi', quantity: 10, unitCost: 7000),
    ],
    discount: 1000,
    additional: 2000,
  );
  test(
    'purchase receive, WAC, supplier payments and backup reconcile atomically',
    () async {
      await store.saveContact(contact('supplier', 'Pemasok'), supplier: true);
      await store.savePurchaseDraft(purchase('po'));
      await store.confirmPurchase('po', 'confirm');
      await store.receivePurchase(
        id: 'r1',
        purchaseId: 'po',
        quantities: {'p': 4},
        date: date,
      );
      await store.receivePurchase(
        id: 'r1',
        purchaseId: 'po',
        quantities: {'p': 4},
        date: date,
      );
      expect(store.products.single.stock, 14);
      expect(store.products.single.cost, 5600);
      await store.receivePurchase(
        id: 'r2',
        purchaseId: 'po',
        quantities: {'p': 6},
        date: date,
      );
      expect(store.products.single.stock, 20);
      expect(store.products.single.cost, 6050);
      await expectLater(
        store.receivePurchase(
          id: 'r3',
          purchaseId: 'po',
          quantities: {'p': 1},
          date: date,
        ),
        throwsArgumentError,
      );
      await store.paySupplier(
        id: 'pay',
        purchaseId: 'po',
        amount: 20000,
        date: date,
        method: 'Tunai',
      );
      await store.paySupplier(
        id: 'pay',
        purchaseId: 'po',
        amount: 20000,
        date: date,
        method: 'Tunai',
      );
      expect(await store.purchasePaid('po'), 20000);
      expect((await store.cashBalances())[null], -20000);
      await store.restore(store.backup());
      expect(await store.receivedQuantities('po'), {'p': 10});
      expect(await store.purchasePaid('po'), 20000);
      final b = jsonDecode(store.backup());
      b['business']['purchases'][0]['supplierId'] = 'missing';
      await expectLater(store.restore(jsonEncode(b)), throwsFormatException);
      expect(store.products.single.stock, 20);
    },
  );
  test(
    'eligible purchase cancellation reverses quantities and exact prior valuation once',
    () async {
      await store.saveContact(contact('supplier', 'Pemasok'), supplier: true);
      await store.savePurchaseDraft(purchase('po'));
      await store.confirmPurchase('po', 'confirm');
      await store.receivePurchase(
        id: 'r1',
        purchaseId: 'po',
        quantities: {'p': 4},
        date: date,
      );
      await store.receivePurchase(
        id: 'r2',
        purchaseId: 'po',
        quantities: {'p': 6},
        date: date,
      );
      await store.cancelPurchase('po', 'cancel', 'Pesanan salah');
      await store.cancelPurchase('po', 'cancel', 'Pesanan salah');
      expect(store.products.single.stock, 10);
      expect(store.products.single.cost, 5000);
      expect(await store.receivedQuantities('po'), {'p': 0});
      await store.restore(store.backup());
      expect((await store.purchase('po')).status, 'cancelled');
    },
  );
  test(
    'opname drafts do not mutate stock and stale sessions fail without partial posting',
    () async {
      final p = store.products.single;
      await store.saveOpnameDraft(
        id: 'count',
        items: [
          OpnameItem(
            productId: p.id,
            expectedUpdated: p.updated,
            expectedStock: p.stock,
            counted: 8,
          ),
        ],
        reason: 'Hitung fisik',
      );
      expect(store.products.single.stock, 10);
      await store.adjustStock('p', 1, 'Restok');
      await expectLater(
        store.confirmOpname('count', 'confirm-count'),
        throwsStateError,
      );
      expect(store.products.single.stock, 11);
      final fresh = store.products.single;
      await store.saveOpnameDraft(
        id: 'count',
        items: [
          OpnameItem(
            productId: fresh.id,
            expectedUpdated: fresh.updated,
            expectedStock: fresh.stock,
            counted: 8,
          ),
        ],
        reason: 'Hitung ulang',
      );
      await store.confirmOpname('count', 'confirm-count');
      await store.confirmOpname('count', 'confirm-count');
      expect(store.products.single.stock, 8);
      await store.restore(store.backup());
      expect(store.products.single.stock, 8);
    },
  );
  test(
    'integer landed allocation totals and negative stock WAC are deterministic',
    () {
      final p = Purchase(
        id: 'p',
        date: date,
        lines: const [
          PurchaseLine(productId: 'a', name: 'A', quantity: 3, unitCost: 101),
          PurchaseLine(productId: 'b', name: 'B', quantity: 2, unitCost: 202),
        ],
        discount: 13,
        additional: 7,
      );
      expect(p.landedValue(0) + p.landedValue(1), p.total);
      expect(
        p.receivedValue(0, 0, 1) + p.receivedValue(0, 1, 2),
        p.landedValue(0),
      );
      expect(
        weightedAverageCost(
          oldQuantity: -3,
          oldCost: 9000,
          receivedQuantity: 5,
          receivedValue: 35000,
        ),
        7000,
      );
    },
  );
}
