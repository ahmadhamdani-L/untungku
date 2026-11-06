import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';

void main() {
  test(
    'real schema-1 file upgrade preserves raw snapshots and derived unallocated cash',
    () async {
      final dir = await Directory.systemTemp.createTemp('untungku-migration-');
      final file = File('${dir.path}/old.db');
      final old = sqlite3.open(file.path);
      // Frozen schema fixture: do not derive the legacy schema from v2 tables.
      final fixture =
          jsonDecode(
                await File('test/schema/drift_schema_v1.json').readAsString(),
              )
              as Map<String, dynamic>;
      for (final entity in fixture['fixed_sql'] as List) {
        for (final statement in entity['sql'] as List) {
          if (statement['dialect'] == 'sqlite') {
            old.execute(statement['sql'] as String);
          }
        }
      }
      final products = [
        const Product(
          id: 'p',
          name: 'Kopi',
          price: 10000,
          cost: 5000,
          stock: 14,
          created: '2026-10-01',
          updated: '2026-10-31',
        ),
        const Product(
          id: 'minus',
          name: 'Pesanan',
          price: 10000,
          cost: 3000,
          stock: -2,
          created: '2026-10-01',
          updated: '2026-10-31',
        ),
        const Product(
          id: 'archive',
          name: 'Arsip',
          price: 10000,
          cost: 3000,
          stock: 0,
          archived: true,
          created: '2026-10-01',
          updated: '2026-10-31',
        ),
      ];
      for (final p in products) {
        old.execute('INSERT INTO product_rows VALUES (?,?)', [
          p.id,
          jsonEncode(
            p.toJson()
              ..remove('barcode')
              ..remove('favorite'),
          ),
        ]);
        old.execute('INSERT INTO movement_rows VALUES (?,?,?)', [
          'm-${p.id}',
          p.id,
          jsonEncode({
            'id': 'm-${p.id}',
            'productId': p.id,
            'delta': p.stock,
            'date': '2026-10-31',
            'reason': 'Koreksi awal',
          }),
        ]);
      }
      SaleLine line(int q) => SaleLine(
        productId: 'p',
        name: 'Nama lama',
        quantity: q,
        price: 10000,
        cost: 4000,
        packaging: 500,
        extra: 0,
      );
      final sales = [
        Sale(
          id: 'cash',
          date: '2026-10-31',
          lines: [line(1)],
          discount: 1000,
          feeBps: 100,
        ),
        Sale(
          id: 'partial',
          date: '2026-10-31',
          lines: [line(2)],
          credit: true,
          customer: 'Rina',
          payments: const [
            SalePayment(
              id: 'pay',
              date: '2026-10-31',
              amount: 5000,
              method: 'Transfer',
            ),
          ],
        ),
        Sale(
          id: 'unpaid',
          date: '2026-10-31',
          lines: [line(3)],
          credit: true,
          customer: 'Rina',
        ),
        Sale(id: 'void', date: '2026-10-31', lines: [line(1)], voided: true),
      ];
      final raw = <String, String>{};
      for (final s in sales) {
        raw[s.id] = jsonEncode(s.toJson());
        old.execute('INSERT INTO sale_rows VALUES (?,?)', [s.id, raw[s.id]]);
        old.execute('INSERT INTO sale_item_rows VALUES (?,?,?)', [
          s.id,
          0,
          'p',
        ]);
      }
      old.execute('INSERT INTO setting_rows VALUES (?,?)', [
        'settings',
        jsonEncode({
          'allowNegativeStock': true,
          'theme': 'dark',
          'onboarded': true,
        }),
      ]);
      old.execute('PRAGMA user_version=1');
      old.close();
      var db = AppDatabase(NativeDatabase(file));
      var store = Store(db);
      await store.load();
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        2,
      );
      for (final r in await db.select(db.saleRows).get()) {
        expect(r.payload, raw[r.id]);
      }
      expect(
        store.sales.firstWhere((s) => s.id == 'partial').outstanding,
        15000,
      );
      expect(
        store.sales.firstWhere((s) => s.id == 'unpaid').outstanding,
        30000,
      );
      expect(store.products.firstWhere((p) => p.id == 'minus').stock, -2);
      expect(
        store.products.firstWhere((p) => p.id == 'archive').archived,
        true,
      );
      expect(await store.customerLinks(), isEmpty);
      expect((await store.cashBalances())[null], 14000);
      expect(await store.cashAccounts(), isEmpty);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      // A second open must neither rerun migration nor rewrite legacy snapshots.
      store.dispose();
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      store = Store(db);
      await store.load();
      for (final row in await db.select(db.saleRows).get()) {
        expect(row.payload, raw[row.id]);
      }
      expect(await store.customerLinks(), isEmpty);
      expect(await store.cashAccounts(), isEmpty);
      expect((await store.cashBalances())[null], 14000);
      final fresh = AppDatabase(NativeDatabase.memory());
      try {
        Future<List<String>> schema(AppDatabase database) async =>
            (await database
                    .customSelect(
                      "SELECT sql FROM sqlite_master WHERE type = 'table' "
                      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
                    )
                    .get())
                .map((row) => row.read<String>('sql'))
                .toList();
        // Force initial creation before querying sqlite_master.
        await fresh.select(fresh.settingRows).get();
        expect(await schema(db), await schema(fresh));
      } finally {
        await fresh.close();
      }
      final backup = store.backup();
      await store.restore(backup);
      expect((await store.cashBalances())[null], 14000);
      for (final version in [1, 2]) {
        final b = jsonDecode(backup)
          ..['version'] = version
          ..remove('business');
        await store.restore(jsonEncode(b));
        expect(store.sales.length, 4);
        expect(store.products.firstWhere((p) => p.id == 'minus').stock, -2);
        expect((await store.cashBalances())[null], 14000);
      }
      store.dispose();
      await db.close();
      await dir.delete(recursive: true);
    },
  );
}
