import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/entities.dart';

const date = '2026-11-04T10:00:00';
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
  late Directory dir;
  late AppDatabase db;
  late Store store;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('ledger-');
    db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
    store = Store(db);
    await store.load();
    await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
    await store.saveCashAccount(const CashAccount(id: 'bank', name: 'Bank'));
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
    await dir.delete(recursive: true);
  });
  Future<void> restart() async {
    store.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
    store = Store(db);
    await store.load();
  }

  Future<void> cash({int amount = 10000}) => store.recordCash(
    id: 'transfer',
    accountId: 'cash',
    destination: 'bank',
    amount: amount,
    category: 'transfer',
    date: date,
  );

  test(
    'failed second transfer leg rolls back cash and operation; retry survives restart',
    () async {
      await db.customStatement(
        "CREATE TRIGGER fail_credit BEFORE INSERT ON cash_movement_rows "
        "WHEN NEW.id = 'transfer:in' BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      await expectLater(cash(), throwsA(anything));
      expect(await store.cashLedger(), isEmpty);
      expect(
        (await db.select(db.operationRows).get()).where(
          (r) => r.id == 'transfer',
        ),
        isEmpty,
      );
      await db.customStatement('DROP TRIGGER fail_credit');
      await cash();
      await restart();
      await cash();
      expect(await store.cashBalances(), {'cash': -10000, 'bank': 10000});
      expect((await store.cashLedger()).length, 2);
      await expectLater(cash(amount: 20000), throwsStateError);
      expect(await store.cashBalances(), {'cash': -10000, 'bank': 10000});
    },
  );

  test(
    'failed operation marker rolls back checkout stock, sale, and cash',
    () async {
      await db.customStatement(
        "CREATE TRIGGER fail_operation BEFORE INSERT ON operation_rows "
        "WHEN NEW.id = 'checkout' BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      const sale = Sale(
        id: 'sale',
        date: date,
        lines: [line],
        accountId: 'cash',
      );
      final movementCount = store.movements.length;
      await expectLater(
        store.saveSale(sale, checkoutOperationId: 'checkout'),
        throwsA(anything),
      );
      await restart();
      expect(store.products.single.stock, 10);
      expect(store.movements.length, movementCount);
      expect(store.sales, isEmpty);
      expect(await store.cashLedger(), isEmpty);
      await db.customStatement('DROP TRIGGER fail_operation');
      await store.saveSale(sale, checkoutOperationId: 'checkout');
      expect(store.products.single.stock, 9);
      expect(await store.cashBalances(), {'cash': 10000});
    },
  );

  test(
    'failed collection posting preserves receivable and permits retry',
    () async {
      await store.saveSale(
        const Sale(
          id: 'credit',
          date: date,
          lines: [line],
          credit: true,
          customer: 'Rina',
        ),
      );
      const payment = SalePayment(
        id: 'payment',
        date: date,
        amount: 4000,
        method: 'Tunai',
        accountId: 'cash',
      );
      await db.customStatement(
        "CREATE TRIGGER fail_payment BEFORE INSERT ON cash_movement_rows "
        "WHEN NEW.category = 'receivable_collection' BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      await expectLater(
        store.recordPayment('credit', payment),
        throwsA(anything),
      );
      await restart();
      expect(store.sales.single.outstanding, 10000);
      expect(store.sales.single.payments, isEmpty);
      expect(await store.cashLedger(), isEmpty);
      await db.customStatement('DROP TRIGGER fail_payment');
      await store.recordPayment('credit', payment);
      await restart();
      await store.recordPayment('credit', payment);
      expect(store.sales.single.outstanding, 6000);
      expect(store.sales.single.result.revenue, 10000);
      expect(store.products.single.stock, 9);
      expect(await store.cashBalances(), {'cash': 4000});
    },
  );

  test(
    'supplier payment failure rolls back payable, cash and operation',
    () async {
      await store.savePurchaseDraft(
        const Purchase(
          id: 'purchase',
          date: date,
          lines: [
            PurchaseLine(
              productId: 'p',
              name: 'Kopi',
              quantity: 2,
              unitCost: 5000,
            ),
          ],
        ),
      );
      await store.confirmPurchase('purchase', 'confirm-purchase');
      Future<void> pay() => store.paySupplier(
        id: 'supplier-pay',
        purchaseId: 'purchase',
        amount: 3000,
        date: date,
        method: 'Tunai',
        accountId: 'cash',
      );
      await db.customStatement(
        "CREATE TRIGGER fail_supplier BEFORE INSERT ON purchase_payment_rows "
        "BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      await expectLater(pay(), throwsA(anything));
      await restart();
      expect(await store.purchasePaid('purchase'), 0);
      expect(await store.cashLedger(), isEmpty);
      expect(
        (await db.select(db.operationRows).get()).where(
          (r) => r.id == 'supplier-pay',
        ),
        isEmpty,
      );
      await db.customStatement('DROP TRIGGER fail_supplier');
      await pay();
      await restart();
      await pay();
      expect(await store.purchasePaid('purchase'), 3000);
      expect(await store.cashBalances(), {'cash': -3000});
      expect(store.expenses, isEmpty);
      expect(store.products.single.stock, 10);
    },
  );

  test(
    'expense revision failure rolls back compensating entries and expense',
    () async {
      const original = Expense(
        id: 'expense',
        date: date,
        category: 'Transportasi',
        note: '',
        amount: 1000,
      );
      await store.saveExpense(original, accountId: 'cash');
      final before = (await store.cashLedger()).map((r) => r.toJson()).toList();
      await db.customStatement(
        "CREATE TRIGGER fail_expense BEFORE INSERT ON cash_movement_rows "
        "WHEN NEW.category = 'operational_expense' AND NEW.amount = -2000 "
        "BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      await expectLater(
        store.saveExpense(
          const Expense(
            id: 'expense',
            date: date,
            category: 'Transportasi',
            note: '',
            amount: 2000,
          ),
          accountId: 'cash',
        ),
        throwsA(anything),
      );
      await restart();
      expect(store.expenses.single.toJson(), original.toJson());
      expect(
        (await store.cashLedger()).map((r) => r.toJson()).toList(),
        before,
      );
      expect(await store.cashBalances(), {'cash': -1000});
    },
  );

  test(
    'unchanged checkout reserves operation key before later conflicting reuse',
    () async {
      const sale = Sale(
        id: 'sale',
        date: date,
        lines: [line],
        accountId: 'cash',
      );
      await store.saveSale(sale);
      await store.saveSale(sale, checkoutOperationId: 'retry');
      await restart();
      await expectLater(
        store.saveSale(
          const Sale(id: 'other', date: date, lines: [line]),
          checkoutOperationId: 'retry',
        ),
        throwsStateError,
      );
      expect(store.products.single.stock, 9);
      expect((await store.cashLedger()).length, 1);
    },
  );

  test(
    'expense reversal leaves unrelated cash with identical reference intact',
    () async {
      await store.recordCash(
        id: 'shared',
        accountId: 'cash',
        amount: 20000,
        category: 'owner_capital',
        date: date,
      );
      await store.saveExpense(
        const Expense(
          id: 'shared',
          date: date,
          category: 'Transportasi',
          note: '',
          amount: 1000,
        ),
        accountId: 'cash',
      );
      await store.deleteExpense('shared');
      await store.deleteExpense('shared');
      expect(await store.cashBalances(), {'cash': 20000});
      final ledger = await store.cashLedger();
      expect(ledger.length, 3);
      expect(
        ledger.singleWhere((r) => r.category == 'owner_capital').amount,
        20000,
      );
    },
  );

  test(
    'concurrent direct posting and archived-account retry preserve one immutable row',
    () async {
      Future<void> post([int amount = 1000]) => store.postCash(
        id: 'direct',
        reference: 'reference',
        date: date,
        category: 'owner_capital',
        amount: amount,
        accountId: 'cash',
      );
      await Future.wait([post(), post()]);
      await store.saveCashAccount(
        const CashAccount(id: 'cash', name: 'Laci', archived: true),
      );
      await restart();
      await post();
      await expectLater(post(2000), throwsStateError);
      await expectLater(post(0), throwsStateError);
      expect((await store.cashLedger()).single.amount, 1000);
    },
  );
}
