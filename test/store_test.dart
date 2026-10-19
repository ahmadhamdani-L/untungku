import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';

void main() {
  late AppDatabase db;
  late Store store;
  late Product product;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    store = Store(db);
    await store.load();
    product = Product(
      id: 'p',
      name: 'Kopi',
      cost: 5000,
      price: 10000,
      stock: 10,
      created: '2026-10-19T10:00:00',
      updated: '2026-10-19T10:00:00',
    );
    await store.saveProduct(product);
  });
  tearDown(() async {
    store.dispose();
    await db.close();
  });
  Sale sale(int q, {String id = 's'}) => Sale(
    id: id,
    date: '2026-10-19T10:00:00',
    lines: [
      SaleLine(
        productId: 'p',
        name: 'Kopi',
        quantity: q,
        price: 10000,
        cost: 5000,
        packaging: 0,
        extra: 0,
      ),
    ],
  );
  test('create, revise, cancel and repeated cancel maintain stock', () async {
    await store.saveSale(sale(3));
    expect(store.products.single.stock, 7);
    await store.saveSale(sale(2));
    expect(store.products.single.stock, 8);
    await store.voidSale('s');
    expect(store.products.single.stock, 10);
    await store.voidSale('s');
    expect(store.products.single.stock, 10);
    expect(() => store.saveSale(sale(1)), throwsArgumentError);
  });
  test('insufficient stock rolls back all effects', () async {
    await store.saveSale(sale(3));
    final before = store.backup();
    await expectLater(store.saveSale(sale(20)), throwsArgumentError);
    await store.load();
    expect(store.products.single.stock, 7);
    expect(store.sales.single.lines.single.quantity, 3);
    expect(
      jsonDecode(store.backup())['movements'],
      jsonDecode(before)['movements'],
    );
  });
  test('multi line failure is atomic', () async {
    final s = Sale(
      id: 'multi',
      date: '2026-10-19',
      lines: [
        ...sale(2).lines,
        SaleLine(
          productId: 'missing',
          name: 'Missing',
          quantity: 1,
          price: 100,
          cost: 10,
          packaging: 0,
          extra: 0,
        ),
      ],
    );
    await expectLater(store.saveSale(s), throwsA(anything));
    await store.load();
    expect(store.products.single.stock, 10);
    expect(store.sales, isEmpty);
  });
  test('backup round trip and invalid restore preserve data', () async {
    await store.saveSale(sale(2));
    await store.saveExpense(
      const Expense(
        id: 'e',
        date: '2026-10-19',
        category: 'Transport',
        note: 'a,"b"\nc',
        amount: 1000,
      ),
    );
    final backup = store.backup();
    await store.adjustStock('p', 3, 'Restok');
    await store.restore(backup);
    expect(store.products.single.stock, 8);
    expect(store.expenses.single.amount, 1000);
    final bad = jsonDecode(backup);
    bad['products'][0]['stock'] = 999;
    await expectLater(store.restore(jsonEncode(bad)), throwsFormatException);
    expect(store.products.single.stock, 8);
    expect(store.csv(), contains('"a,""b""\nc"'));
  });
  test('data persists across repository reload', () async {
    await store.saveSale(sale(1));
    final another = Store(db);
    await another.load();
    expect(another.sales.single.result.net, 5000);
    expect(another.products.single.stock, 9);
    another.dispose();
  });
  test('negative stock correction rejected', () async {
    await expectLater(
      store.adjustStock('p', -11, 'Rusak'),
      throwsArgumentError,
    );
    expect(store.products.single.stock, 10);
  });
  test('backup rejects wrong version and broken references', () {
    final b = jsonDecode(store.backup());
    b['version'] = 99;
    expect(() => Store.validateBackup(jsonEncode(b)), throwsFormatException);
  });
  test('stale product edit cannot overwrite sale stock', () async {
    await store.saveSale(sale(2));
    await expectLater(
      store.saveProduct(product, expectedUpdated: product.updated),
      throwsStateError,
    );
    expect(store.products.single.stock, 8);
    await store.archiveProduct(product.id, true);
    expect(store.products.single.stock, 8);
    expect(store.products.single.archived, true);
  });
  test('restore database failure rolls back the entire replacement', () async {
    final backup = store.backup();
    await store.adjustStock('p', 2, 'Restok');
    await db.customStatement(
      "CREATE TRIGGER reject_restore BEFORE INSERT ON product_rows BEGIN SELECT RAISE(ABORT, 'simulated disk write failure'); END",
    );
    await expectLater(store.restore(backup), throwsA(anything));
    await store.load();
    expect(store.products.single.stock, 12);
    expect(store.movements.length, 2);
  });
}
