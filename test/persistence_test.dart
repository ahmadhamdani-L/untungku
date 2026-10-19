import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/dates.dart';

void main() {
  test('schema version, FK constraints, and restart persistence', () async {
    final dir = await Directory.systemTemp.createTemp('untungku-db-');
    final file = File('${dir.path}/db.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var store = Store(db);
    await store.load();
    await store.saveProduct(
      const Product(
        id: 'p',
        name: 'Persist',
        cost: 1,
        price: 2,
        stock: 4,
        created: '2026-10-19',
        updated: '2026-10-19',
      ),
    );
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      1,
    );
    await expectLater(
      db.customStatement(
        "INSERT INTO movement_rows(id,product_id,payload) VALUES ('bad','missing','{}')",
      ),
      throwsA(anything),
    );
    store.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    store = Store(db);
    await store.load();
    expect(store.products.single.stock, 4);
    expect(store.movements.single['delta'], 4);
    store.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });
  test('calendar overflow and malformed dates rejected', () {
    for (final d in ['2026-02-31', '2026-13-01', '2026-00-01', 'garbage']) {
      expect(() => validDate(d), throwsFormatException);
    }
    expect(validDate('2024-02-29').day, 29);
  });
}
