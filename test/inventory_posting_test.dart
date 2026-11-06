import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/entities.dart';

const date = '2026-11-04T10:00:00';
void main() {
  late Directory dir;
  late AppDatabase db;
  late Store store;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('inventory-');
    db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
    store = Store(db);
    await store.load();
    for (final id in ['a', 'b']) {
      await store.saveProduct(
        Product(
          id: id,
          name: id,
          price: 10000,
          cost: 5000,
          stock: 10,
          created: date,
          updated: date,
        ),
      );
    }
  });
  tearDown(() async {
    store.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });
  Future<void> reopen() async {
    store.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
    store = Store(db);
    await store.load();
  }

  Future<void> failSecondMovement() => db.customStatement(
    "CREATE TRIGGER fail_movement BEFORE INSERT ON movement_rows "
    "WHEN NEW.product_id = 'b' BEGIN SELECT RAISE(ABORT, 'injected'); END",
  );
  void reconciled() {
    for (final p in store.products) {
      expect(
        store.movements
            .where((m) => m['productId'] == p.id)
            .fold<int>(0, (sum, m) => sum + (m['delta'] as int)),
        p.stock,
      );
    }
  }

  test(
    'concurrent adjustment retry persists one audit event and rejects changed intent',
    () async {
      Future<void> adjust() =>
          store.adjustStock('a', -2, 'Rusak', operationId: 'adjust');
      await Future.wait([adjust(), adjust()]);
      await reopen();
      await adjust();
      expect(store.products.firstWhere((p) => p.id == 'a').stock, 8);
      final movement = store.movements.singleWhere(
        (m) => m['operationId'] == 'adjust',
      );
      expect(movement['reference'], 'a');
      await expectLater(
        store.adjustStock('a', -3, 'Rusak', operationId: 'adjust'),
        throwsStateError,
      );
      reconciled();
    },
  );
  test(
    'receipt failure on second product rolls back valuation, movements, receipt and key',
    () async {
      await store.savePurchaseDraft(
        const Purchase(
          id: 'po',
          date: date,
          lines: [
            PurchaseLine(
              productId: 'a',
              name: 'A',
              quantity: 2,
              unitCost: 7000,
            ),
            PurchaseLine(
              productId: 'b',
              name: 'B',
              quantity: 2,
              unitCost: 7000,
            ),
          ],
        ),
      );
      await store.confirmPurchase('po', 'confirm');
      Future<void> receive() => store.receivePurchase(
        id: 'receive',
        purchaseId: 'po',
        quantities: {'a': 2, 'b': 2},
        date: date,
      );
      await failSecondMovement();
      await expectLater(receive(), throwsA(anything));
      await reopen();
      expect(
        store.products.every((p) => p.stock == 10 && p.cost == 5000),
        true,
      );
      expect(await store.receivedQuantities('po'), isEmpty);
      expect(store.movements.length, 2);
      await db.customStatement('DROP TRIGGER fail_movement');
      await receive();
      await reopen();
      await receive();
      expect(store.products.every((p) => p.stock == 12), true);
      expect(
        store.movements.where((m) => m['operationId'] == 'receive').length,
        2,
      );
      reconciled();
    },
  );
  test(
    'opname failure on second product preserves draft and retries atomically',
    () async {
      await store.saveOpnameDraft(
        id: 'count',
        reason: 'Hitung',
        items: [
          for (final p in store.products)
            OpnameItem(
              productId: p.id,
              expectedUpdated: p.updated,
              expectedStock: p.stock,
              counted: 8,
            ),
        ],
      );
      await failSecondMovement();
      await expectLater(
        store.confirmOpname('count', 'post-count'),
        throwsA(anything),
      );
      await reopen();
      expect(store.products.every((p) => p.stock == 10), true);
      expect(
        jsonDecode(
          (await db.select(db.opnameRows).get()).single.payload,
        )['confirmed'],
        false,
      );
      await db.customStatement('DROP TRIGGER fail_movement');
      await store.confirmOpname('count', 'post-count');
      await reopen();
      await store.confirmOpname('count', 'post-count');
      expect(store.products.every((p) => p.stock == 8), true);
      expect(
        store.movements.where((m) => m['operationId'] == 'post-count').length,
        2,
      );
      reconciled();
    },
  );
  test(
    'return failure rolls back restock and preserves original sale cost bytes',
    () async {
      SaleLine line(String id) => SaleLine(
        productId: id,
        name: id,
        quantity: 2,
        price: 10000,
        cost: 4000,
        packaging: 0,
        extra: 0,
      );
      await store.saveSale(
        Sale(id: 'sale', date: date, lines: [line('a'), line('b')]),
      );
      final original = (await db.select(db.saleRows).get()).single.payload;
      Future<void> returns() => store.recordReturn(
        id: 'return',
        saleId: 'sale',
        quantities: {0: 1, 1: 1},
        restock: {0, 1},
        reason: 'Retur',
        date: date,
      );
      await failSecondMovement();
      await expectLater(returns(), throwsA(anything));
      await reopen();
      expect(store.products.every((p) => p.stock == 8), true);
      expect(await store.salesReturns(), isEmpty);
      expect((await db.select(db.saleRows).get()).single.payload, original);
      await db.customStatement('DROP TRIGGER fail_movement');
      await returns();
      await reopen();
      await returns();
      expect(store.products.every((p) => p.stock == 9), true);
      expect(
        store.movements.where((m) => m['operationId'] == 'return').length,
        2,
      );
      expect((await db.select(db.saleRows).get()).single.payload, original);
      reconciled();
    },
  );
}
