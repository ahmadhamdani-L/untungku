import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drift/native.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';

Future<void> dismissNativeKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await tester.pump(const Duration(milliseconds: 300));
  for (var i = 0; i < 50 && tester.view.viewInsets.bottom > 0; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(tester.view.viewInsets.bottom, 0);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('product, sale, dashboard, expense and backup flow', (
    tester,
  ) async {
    await initializeDateFormatting('id_ID');
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await store.saveSettings({'onboarded': true, 'business': 'Uji integrasi'});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah produk'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Kopi Integrasi');
    await tester.enterText(fields.at(3), '5000');
    await tester.enterText(fields.at(4), '10000');
    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Stok'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Stok'), '10');
    await dismissNativeKeyboard(tester);
    await tester.scrollUntilVisible(
      find.text('Simpan produk').hitTestable(),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ProductForm),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan produk'));
    await tester.pumpAndSettle();
    expect(store.products.single.name, 'Kopi Integrasi');
    final p = store.products.single;
    await tester.tap(find.text('Transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Penjualan').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopi Integrasi • stok 10').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Jumlah'), '2');
    await dismissNativeKeyboard(tester);
    await tester.scrollUntilVisible(
      find.text('Simpan penjualan').hitTestable(),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Simpan penjualan'));
    await tester.pumpAndSettle();
    expect(store.products.single.stock, 8);
    await tester.tap(find.text('Ringkasan'));
    await tester.pumpAndSettle();
    expect(find.text('Rp 20.000'), findsOneWidget);
    await store.saveExpense(
      Expense(
        id: 'integration-expense',
        date: DateTime.now().toIso8601String(),
        category: 'Transportasi',
        note: 'Pengiriman',
        amount: 1000,
      ),
    );
    final backup = store.backup();
    await store.adjustStock(p.id, 5, 'Restok');
    await store.restore(backup);
    expect(store.products.single.stock, 8);
    expect(store.expenses.single.amount, 1000);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
