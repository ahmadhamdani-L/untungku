import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  testWidgets('create credit sale, settle from detail, and show paid history', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await store.saveSettings({'onboarded': true});
    await store.saveProduct(
      const Product(
        id: 'p',
        name: 'Kopi',
        price: 10000,
        cost: 5000,
        stock: 10,
        created: '2026-11-01',
        updated: '2026-11-01',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    await tester.tap(find.text('Catat penjualan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopi • stok 10').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Penjualan tempo / piutang').hitTestable(),
      150,
      scrollable: find
          .descendant(
            of: find.byType(SaleForm),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Penjualan tempo / piutang'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'Nama pelanggan'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(SaleForm),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nama pelanggan'),
      'Sari',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextField, 'Pembayaran awal (Rp)'),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Pembayaran awal (Rp)'),
      '2000',
    );
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Simpan penjualan'));
    await tester.tap(find.text('Simpan penjualan'));
    await tester.pumpAndSettle();
    expect(find.text('Penjualan berhasil disimpan'), findsOneWidget);
    expect(store.sales.single.outstanding, 8000);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Piutang pelanggan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sari'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Catat pelunasan'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Catat pelunasan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan pembayaran'));
    await tester.pumpAndSettle();
    expect(store.sales.single.outstanding, 0);
    expect(store.products.single.stock, 9);
    expect(store.sales.single.result.revenue, 10000);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('LUNAS'),
      -250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('LUNAS'), findsOneWidget);
    expect(find.text('Catat pelunasan'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  for (final theme in ['light', 'dark']) {
    testWidgets('compact $theme dashboard and receivables fit at 320px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await store.saveSettings({
        'onboarded': true,
        'theme': theme,
        'business': 'Nama usaha yang sangat panjang sekali',
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const UntungkuApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Tren pendapatan'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Piutang pelanggan'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }
}
