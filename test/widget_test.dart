import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  testWidgets('onboarding to empty dashboard and product validation', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    expect(find.text('Usaha rapi.\nUntung lebih pasti.'), findsOneWidget);
    await tester.ensureVisible(find.text('Mulai / lewati pengenalan'));
    await tester.tap(find.text('Mulai / lewati pengenalan'));
    await tester.pumpAndSettle();
    expect(find.text('Kabar usaha Anda'), findsOneWidget);
    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah produk'));
    await tester.pumpAndSettle();
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
    expect(find.text('Wajib diisi'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
  testWidgets('multi product selector resets and sale persists once', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await store.saveSettings({'onboarded': true});
    await store.saveProduct(
      const Product(
        id: 'coffee',
        name: 'Kopi',
        price: 10000,
        cost: 5000,
        stock: 10,
        created: '2026-10-19',
        updated: '2026-10-19',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Catat penjualan').hitTestable(),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catat penjualan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopi • stok 10').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.widgetWithText(TextField, 'Jumlah'), '2');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Simpan penjualan').hitTestable(),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan penjualan'));
    await tester.pumpAndSettle();
    expect(store.sales.length, 1);
    expect(store.products.single.stock, 8);
    expect(store.sales.single.result.net, 10000);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
  testWidgets('settings persist dark theme and reject invalid fee', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await store.saveSettings({'onboarded': true});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    await tester.tap(find.byTooltip('Pengaturan & backup'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(DropdownButtonFormField<String>).hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gelap').last);
    await tester.pumpAndSettle();
    expect(store.settings['theme'], 'dark');
    expect(
      Theme.of(tester.element(find.text('Pengaturan usaha'))).brightness,
      Brightness.dark,
    );
    await tester.scrollUntilVisible(
      find
          .widgetWithText(TextField, 'Asumsi biaya transaksi (%)')
          .hitTestable(),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Asumsi biaya transaksi (%)'),
      '100',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Simpan preferensi').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan preferensi'));
    await tester.pumpAndSettle();
    expect(store.settings['feeBps'], isNull);
    expect(find.textContaining('Persentase harus'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
