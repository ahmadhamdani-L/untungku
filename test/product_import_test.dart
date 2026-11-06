import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/product_import.dart';

const date = '2026-11-04T10:00:00';
const header =
    'nama,sku,barcode,kategori,modal,harga_jual,kemasan,biaya_tambahan,stok,batas_stok\r\n';
Map<String, int?> mapping(CsvTable table) => {
  for (final key in productCsvColumns) key: table.headers.indexOf(key),
};
void main() {
  test(
    'CSV handles BOM, escaped quotes, comma and newline fields; malformed CSV fails',
    () {
      final table = parseProductCsv(
        '\uFEFF$header"Kopi, ""Susu""\nSegar",A,123,Minuman,"1.000,00",2000,0,0,5,1\r\n',
      );
      expect(table.rows.single.first, 'Kopi, "Susu"\nSegar');
      expect(importInteger(table.rows.single[4], 'Modal'), 1000);
      for (final invalid in [
        'nama,nama\na,b',
        'nama,harga_jual\n"Kopi,2000',
        'nama,harga_jual\n"Kopi"x,2000',
        'nama,harga_jual\nKo"pi,2000',
      ]) {
        expect(() => parseProductCsv(invalid), throwsFormatException);
      }
      expect(() => importInteger('1,5', 'Modal'), throwsArgumentError);
      expect(() => importInteger('1.23', 'Modal'), throwsArgumentError);
    },
  );
  test('preview reports bad rows and never matches identity by name', () {
    final table = parseProductCsv(
      '${header}Kopi,A,123,M,1000,2000,0,0,5,1\r\nKopi,B,456,M,1000,2000,0,0,5,1\r\nBad,C,789,M,1000,1.5,0,0,5,1\r\nDup,A,111,M,1000,2000,0,0,5,1',
    );
    final plan = planProductImport(
      table,
      mapping(table),
      [],
      id: 'import',
      timestamp: date,
      policy: ImportDuplicatePolicy.skip,
    );
    expect(plan.created, 2);
    expect(plan.valid, false);
    expect(plan.rows.where((r) => r.error != null).length, 2);
    expect(plan.rows[0].product!.id, isNot(plan.rows[1].product!.id));
  });
  group('transactional import', () {
    late Directory dir;
    late AppDatabase db;
    late Store store;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('csv-');
      db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
      store = Store(db);
      await store.load();
      await store.saveProduct(
        const Product(
          id: 'old',
          name: 'Kopi',
          sku: 'OLD',
          barcode: '111',
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
    Future<void> reopen() async {
      store.dispose();
      await db.close();
      db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
      store = Store(db);
      await store.load();
    }

    ProductImportPlan plan(
      String rows, {
      ImportDuplicatePolicy policy = ImportDuplicatePolicy.update,
    }) {
      final table = parseProductCsv('$header$rows');
      return planProductImport(
        table,
        mapping(table),
        store.products,
        id: 'batch',
        timestamp: date,
        policy: policy,
      );
    }

    test(
      'preview cancellation writes nothing; commit retries survive reopen and preserve sale cost',
      () async {
        await store.saveSale(
          const Sale(
            id: 'sale',
            date: date,
            lines: [
              SaleLine(
                productId: 'old',
                name: 'Kopi',
                quantity: 2,
                price: 10000,
                cost: 5000,
                packaging: 0,
                extra: 0,
              ),
            ],
          ),
        );
        final raw = (await db.select(db.saleRows).get()).single.payload;
        final beforeCount = store.movements.length;
        final preview = plan(
          'Kopi Baru,OLD,111,M,7000,12000,0,0,12,2\r\nKopi,NEW,222,M,3000,6000,0,0,3,1',
        );
        expect(preview.valid, true);
        expect(preview.updated, 1);
        expect(preview.created, 1);
        expect(store.products.length, 1);
        expect(store.products.single.stock, 8);
        expect(store.movements.length, beforeCount);
        await store.commitProductImport(preview);
        await reopen();
        await store.commitProductImport(preview);
        expect(store.products.length, 2);
        expect(store.products.singleWhere((p) => p.id == 'old').stock, 12);
        expect(store.products.singleWhere((p) => p.id == 'old').cost, 7000);
        expect(
          store.movements.where((m) => m['operationId'] == 'batch').length,
          2,
        );
        expect((await db.select(db.saleRows).get()).single.payload, raw);
        await store.restore(store.backup());
        expect(store.products.singleWhere((p) => p.sku == 'NEW').stock, 3);
      },
    );
    test(
      'mid-batch failure rolls back products, movements and operation; retry commits once',
      () async {
        final preview = plan(
          'Kopi Baru,OLD,111,M,7000,12000,0,0,12,2\r\nTeh,NEW,222,M,3000,6000,0,0,3,1',
        );
        await db.customStatement(
          "CREATE TRIGGER fail_import BEFORE INSERT ON product_rows WHEN NEW.id = 'batch:row:3' BEGIN SELECT RAISE(ABORT, 'injected'); END",
        );
        await expectLater(
          store.commitProductImport(preview),
          throwsA(anything),
        );
        await reopen();
        expect(store.products.single.stock, 10);
        expect(store.products.single.cost, 5000);
        expect(store.movements.length, 1);
        expect(
          (await db.select(db.operationRows).get()).where(
            (r) => r.id == 'batch',
          ),
          isEmpty,
        );
        await db.customStatement('DROP TRIGGER fail_import');
        await store.commitProductImport(preview);
        expect(store.products.length, 2);
      },
    );
    test(
      'stale stock and newly conflicting identifiers reject the whole preview',
      () async {
        final preview = plan('Kopi Baru,OLD,111,M,7000,12000,0,0,12,2');
        await store.adjustStock('old', -1, 'Rusak');
        await expectLater(store.commitProductImport(preview), throwsStateError);
        expect(store.products.single.stock, 9);
        final create = plan('Teh,NEW,222,M,3000,6000,0,0,3,1');
        await store.saveProduct(
          const Product(
            id: 'concurrent',
            name: 'Other',
            sku: 'NEW',
            barcode: '222',
            price: 1000,
            cost: 0,
            stock: 1,
            created: date,
            updated: date,
          ),
        );
        await expectLater(store.commitProductImport(create), throwsStateError);
        expect(store.products.length, 2);
      },
    );
    test(
      'skip/create-only do not change duplicates; ambiguous SKU/barcode reports identity error',
      () async {
        for (final policy in [
          ImportDuplicatePolicy.skip,
          ImportDuplicatePolicy.createOnly,
        ]) {
          final preview = plan(
            'Kopi Baru,OLD,111,M,7000,12000,0,0,12,2',
            policy: policy,
          );
          expect(preview.skipped, 1);
          expect(preview.updated, 0);
        }
        await store.saveProduct(
          const Product(
            id: 'other',
            name: 'Teh',
            sku: 'OTHER',
            barcode: '222',
            price: 1000,
            cost: 0,
            stock: 1,
            created: date,
            updated: date,
          ),
        );
        final ambiguous = plan('Nama,OLD,222,M,1000,2000,0,0,1,1');
        expect(ambiguous.valid, false);
        expect(ambiguous.rows.single.error, contains('beberapa produk'));
        final backup = jsonDecode(store.backup());
        expect((backup['products'] as List).length, 2);
      },
    );
  });
}
