import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/business/insights.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/entities.dart';

/// Read-path fixture only; direct batch seeding deliberately does not benchmark posting.
Future<Map<String, int>> performanceScenario(int count) async {
  final database = AppDatabase(NativeDatabase.memory());
  final store = Store(database);
  await store.load();
  const date = '2026-11-05T10:00:00';
  await database.batch((batch) {
    batch.insertAll(database.productRows, [
      for (var i = 0; i < 1000; i++)
        ProductRowsCompanion.insert(
          id: 'p$i',
          payload: jsonEncode(
            Product(
              id: 'p$i',
              name: 'Produk $i',
              price: 10000,
              cost: 5000,
              stock: 100,
              created: '2026-10-01',
              updated: date,
            ).toJson(),
          ),
        ),
    ]);
    batch.insertAll(database.customerRows, [
      for (var i = 0; i < 300; i++)
        CustomerRowsCompanion.insert(
          id: 'c$i',
          payload: jsonEncode(
            Contact(
              id: 'c$i',
              name: 'Pelanggan $i',
              created: date,
              updated: date,
            ).toJson(),
          ),
        ),
    ]);
    batch.insertAll(database.supplierRows, [
      for (var i = 0; i < 100; i++)
        SupplierRowsCompanion.insert(
          id: 's$i',
          payload: jsonEncode(
            Contact(
              id: 's$i',
              name: 'Pemasok $i',
              created: date,
              updated: date,
            ).toJson(),
          ),
        ),
    ]);
  });
  for (var start = 0; start < count; start += 500) {
    await database.batch((batch) {
      for (var i = start; i < start + 500 && i < count; i++) {
        final sale = Sale(
          id: 'sale$i',
          date: date,
          lines: [
            SaleLine(
              productId: 'p${i % 1000}',
              name: 'Produk ${i % 1000}',
              quantity: 1,
              price: 10000,
              cost: 5000,
              packaging: 0,
              extra: 0,
            ),
          ],
        );
        batch.insert(
          database.saleRows,
          SaleRowsCompanion.insert(
            id: sale.id,
            payload: jsonEncode(sale.toJson()),
          ),
        );
        batch.insert(
          database.saleItemRows,
          SaleItemRowsCompanion.insert(
            saleId: sale.id,
            lineIndex: 0,
            productId: 'p${i % 1000}',
          ),
        );
        if (i < 10000) {
          batch.insert(
            database.movementRows,
            MovementRowsCompanion.insert(
              id: 'm$i',
              productId: 'p${i % 1000}',
              payload: jsonEncode({
                'id': 'm$i',
                'productId': 'p${i % 1000}',
                'delta': -1,
                'reason': 'Synthetic benchmark',
                'date': date,
                'reference': sale.id,
              }),
            ),
          );
        }
      }
    });
  }
  final watch = Stopwatch()..start();
  await store.load();
  final load = watch.elapsedMilliseconds;
  watch.reset();
  final insights = businessInsights(
    products: store.products,
    sales: store.sales,
    expenses: store.expenses,
    now: DateTime(2026, 11, 5, 12),
  );
  final calc = watch.elapsedMilliseconds;
  final result = {
    'products': store.products.length,
    'sales': store.sales.length,
    'movements': store.movements.length,
    'customers': (await store.contacts()).length,
    'suppliers': (await store.contacts(suppliers: true)).length,
    'loadMs': load,
    'insightMs': calc,
    'insights': insights.length,
    'rssMiB': ProcessInfo.currentRss ~/ 1048576,
  };
  store.dispose();
  await database.close();
  return result;
}
