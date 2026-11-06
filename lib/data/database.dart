import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
part 'database.g.dart';

class ProductRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SaleRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SaleItemRows extends Table {
  TextColumn get saleId =>
      text().references(SaleRows, #id, onDelete: KeyAction.cascade)();
  IntColumn get lineIndex => integer()();
  TextColumn get productId => text().references(ProductRows, #id)();
  @override
  Set<Column> get primaryKey => {saleId, lineIndex};
}

class ExpenseRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class MovementRows extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(ProductRows, #id)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SettingRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class CustomerRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SupplierRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class CashAccountRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class OperationRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseRows extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId =>
      text().nullable().references(SupplierRows, #id)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class StockReceiptRows extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text().references(PurchaseRows, #id)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class PurchasePaymentRows extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text().references(PurchaseRows, #id)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SaleCustomerRows extends Table {
  TextColumn get saleId => text().references(SaleRows, #id)();
  TextColumn get customerId => text().references(CustomerRows, #id)();
  @override
  Set<Column> get primaryKey => {saleId};
}

class ReturnRows extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(SaleRows, #id)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class RefundRows extends Table {
  TextColumn get id => text()();
  TextColumn get returnId => text().references(ReturnRows, #id)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class OpnameRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class CashMovementRows extends Table {
  TextColumn get id => text()();
  TextColumn get accountId =>
      text().nullable().references(CashAccountRows, #id)();
  TextColumn get reference => text()();
  TextColumn get category => text()();
  TextColumn get date => text()();
  IntColumn get amount => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ProductRows,
    SaleRows,
    SaleItemRows,
    ExpenseRows,
    MovementRows,
    SettingRows,
    CustomerRows,
    SupplierRows,
    CashAccountRows,
    OperationRows,
    PurchaseRows,
    StockReceiptRows,
    PurchasePaymentRows,
    SaleCustomerRows,
    ReturnRows,
    RefundRows,
    OpnameRows,
    CashMovementRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  factory AppDatabase.local() => AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      return NativeDatabase.createInBackground(
        File(p.join(dir.path, 'untungku.sqlite')),
      );
    }),
  );
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(customerRows);
        await m.createTable(supplierRows);
        await m.createTable(cashAccountRows);
        await m.createTable(operationRows);
        await m.createTable(purchaseRows);
        await m.createTable(stockReceiptRows);
        await m.createTable(purchasePaymentRows);
        await m.createTable(saleCustomerRows);
        await m.createTable(returnRows);
        await m.createTable(refundRows);
        await m.createTable(opnameRows);
        await m.createTable(cashMovementRows);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
