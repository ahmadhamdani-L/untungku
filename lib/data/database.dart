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

@DriftDatabase(
  tables: [
    ProductRows,
    SaleRows,
    SaleItemRows,
    ExpenseRows,
    MovementRows,
    SettingRows,
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
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
