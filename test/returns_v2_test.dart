import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';

void main() {
  late AppDatabase db;
  late Store store;
  const date = '2026-11-03T10:00:00';
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    store = Store(db);
    await store.load();
    await store.saveProduct(
      const Product(
        id: 'p',
        name: 'Kopi',
        stock: 10,
        cost: 4000,
        price: 10000,
        created: date,
        updated: date,
      ),
    );
  });
  tearDown(() async {
    store.dispose();
    await db.close();
  });
  Sale sale({bool credit = false, int initial = 0}) => Sale(
    id: 's',
    date: date,
    lines: const [
      SaleLine(
        productId: 'p',
        name: 'Kopi',
        quantity: 4,
        price: 10000,
        cost: 4000,
        packaging: 500,
        extra: 0,
      ),
    ],
    discount: 1000,
    feeBps: 100,
    credit: credit,
    customer: credit ? 'Rina' : '',
    payments: initial == 0
        ? const []
        : [
            SalePayment(
              id: 'initial',
              date: date,
              amount: initial,
              method: 'Tunai',
            ),
          ],
  );
  test(
    'cash partial return preserves sale bytes, restocks only resale goods, refund is idempotent',
    () async {
      await store.saveSale(sale());
      final before = (await db.select(db.saleRows).get()).single.payload;
      await store.recordReturn(
        id: 'r',
        saleId: 's',
        quantities: {0: 1},
        restock: {0},
        reason: 'Salah pesan',
        date: date,
      );
      await store.recordReturn(
        id: 'r',
        saleId: 's',
        quantities: {0: 1},
        restock: {0},
        reason: 'Salah pesan',
        date: date,
      );
      expect(store.products.single.stock, 7);
      expect(store.sales.single.result.revenue, 29250);
      expect(store.sales.single.result.cogs, 12000);
      expect(store.sales.single.refundOutstanding, 9750);
      expect((await db.select(db.saleRows).get()).single.payload, before);
      await store.refundCustomer(
        id: 'refund',
        returnId: 'r',
        amount: 9750,
        date: date,
        method: 'Tunai',
      );
      await store.refundCustomer(
        id: 'refund',
        returnId: 'r',
        amount: 9750,
        date: date,
        method: 'Tunai',
      );
      expect(store.sales.single.refundOutstanding, 0);
      expect((await store.cashBalances())[null], 29250);
      await expectLater(
        store.refundCustomer(
          id: 'more',
          returnId: 'r',
          amount: 1,
          date: date,
          method: 'Tunai',
        ),
        throwsArgumentError,
      );
      await store.recordReturn(
        id: 'damaged',
        saleId: 's',
        quantities: {0: 3},
        restock: {},
        reason: 'Rusak',
        date: date,
      );
      expect(store.products.single.stock, 7);
      expect(store.sales.single.result.revenue, 0);
      expect(store.sales.single.result.cogs, 12000);
      await expectLater(
        store.recordReturn(
          id: 'extra',
          saleId: 's',
          quantities: {0: 1},
          restock: {0},
          reason: 'Berlebih',
          date: date,
        ),
        throwsArgumentError,
      );
      await store.restore(store.backup());
      expect(store.sales.single.result.revenue, 0);
      expect(store.sales.single.refundOutstanding, 29250);
    },
  );
  test(
    'credit return reduces receivable before generating refund liability',
    () async {
      await store.saveSale(sale(credit: true, initial: 10000));
      await store.recordReturn(
        id: 'r1',
        saleId: 's',
        quantities: {0: 2},
        restock: {0},
        reason: 'Retur',
        date: date,
      );
      expect(store.sales.single.outstanding, 9500);
      expect(store.sales.single.refundOutstanding, 0);
      await expectLater(
        store.recordPayment(
          's',
          const SalePayment(
            id: 'over',
            date: date,
            amount: 10000,
            method: 'Tunai',
          ),
        ),
        throwsArgumentError,
      );
      await store.recordPayment(
        's',
        const SalePayment(
          id: 'balance',
          date: date,
          amount: 9500,
          method: 'Tunai',
        ),
      );
      await store.recordReturn(
        id: 'r2',
        saleId: 's',
        quantities: {0: 1},
        restock: {},
        reason: 'Rusak',
        date: date,
      );
      expect(store.sales.single.outstanding, 0);
      expect(store.sales.single.refundOutstanding, 9750);
      await store.restore(store.backup());
      expect(store.sales.single.refundOutstanding, 9750);
    },
  );
  test(
    'cancelled paid sale keeps cash until explicit refund and restores stock exactly once',
    () async {
      await store.saveSale(sale());
      await store.voidSale('s');
      await store.voidSale('s');
      expect(store.products.single.stock, 10);
      expect((await store.cashBalances())[null], 39000);
      expect(store.sales.single.refundOutstanding, 39000);
      await store.refundCustomer(
        id: 'refund',
        returnId: 'cancel:s',
        amount: 39000,
        date: DateTime.now().add(const Duration(seconds: 1)).toIso8601String(),
        method: 'Tunai',
      );
      expect((await store.cashBalances())[null], 0);
      await store.restore(store.backup());
      expect(store.sales.single.refundOutstanding, 0);
    },
  );
  test(
    'tampered return amounts and missing refund references are rejected before restore',
    () async {
      await store.saveSale(sale());
      await store.recordReturn(
        id: 'r',
        saleId: 's',
        quantities: {0: 1},
        restock: {0},
        reason: 'Retur',
        date: date,
      );
      final backup = jsonDecode(store.backup());
      final payload = jsonDecode(backup['business']['returns'][0]['payload']);
      payload['revenueReduction'] = 1;
      backup['business']['returns'][0]['payload'] = jsonEncode(payload);
      await expectLater(
        store.restore(jsonEncode(backup)),
        throwsFormatException,
      );
      expect(store.sales.single.result.revenue, 29250);
      expect(store.products.single.stock, 7);
    },
  );
}
