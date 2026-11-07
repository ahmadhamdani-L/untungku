import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture current store listing with isolated example data', (
    tester,
  ) async {
    await initializeDateFormatting('id_ID');
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await store.saveSettings({
      'onboarded': true,
      'business': 'Contoh • Kedai Kopi Senja',
      'theme': 'light',
    });
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);
    final products = [
      ('kopi', 'Kopi Susu Gula Aren', 'Minuman', 9000, 18000, 48),
      ('latte', 'Cafe Latte', 'Minuman', 11000, 22000, 35),
      ('matcha', 'Matcha Latte', 'Minuman', 12000, 25000, 18),
      ('roti', 'Roti Panggang Cokelat', 'Makanan', 7000, 15000, 4),
    ];
    for (final p in products) {
      await store.saveProduct(
        Product(
          id: p.$1,
          name: p.$2,
          sku: 'SKU-${p.$1.toUpperCase()}',
          category: p.$3,
          cost: p.$4,
          price: p.$5,
          stock: p.$6,
          threshold: 5,
          created: today.subtract(const Duration(days: 30)).toIso8601String(),
          updated: today.toIso8601String(),
        ),
      );
    }
    SaleLine line(String id, int q) {
      final p = store.products.firstWhere((p) => p.id == id);
      return SaleLine(
        productId: id,
        name: p.name,
        quantity: q,
        price: p.price,
        cost: p.cost,
        packaging: 0,
        extra: 0,
      );
    }

    for (var day = 6; day >= 1; day--) {
      await store.saveSale(
        Sale(
          id: 'example-day-$day',
          date: today.subtract(Duration(days: day)).toIso8601String(),
          lines: [line('kopi', 2 + day % 3), line('latte', 1 + day % 2)],
          payment: 'QRIS',
        ),
      );
    }
    await store.saveSale(
      Sale(
        id: 'example-cash',
        date: today.toIso8601String(),
        lines: [line('kopi', 3), line('latte', 2)],
        payment: 'QRIS',
        note: 'Pesanan dibawa pulang',
      ),
    );
    await store.saveSale(
      Sale(
        id: 'example-credit',
        date: today.add(const Duration(hours: 1)).toIso8601String(),
        lines: [line('matcha', 4), line('latte', 2)],
        credit: true,
        customer: 'Pelanggan contoh • Rina',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day + 7,
        ).toIso8601String().substring(0, 10),
        payments: [
          SalePayment(
            id: 'example-initial',
            date: today.add(const Duration(hours: 1)).toIso8601String(),
            amount: 50000,
            method: 'Transfer',
          ),
        ],
        note: 'Pesanan rapat kantor • data contoh',
      ),
    );
    await store.saveExpense(
      Expense(
        id: 'example-expense',
        date: today.toIso8601String(),
        category: 'Operasional',
        note: 'Transportasi bahan baku',
        amount: 15000,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    await tester.pumpAndSettle();
    if (const bool.fromEnvironment('LABARAPI_PREVIEW_ONLY')) {
      // Allow a lossless host adb capture without changing Android surfaces.
      debugPrint('LABARAPI_PREVIEW_READY');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 20)),
      );
      await tester.pumpWidget(const SizedBox());
      await db.close();
      return;
    }
    await binding.convertFlutterSurfaceToImage();
    // Repaint static app bars after Android switches the rendering surface.
    await binding.reassembleApplication();
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await binding.reassembleApplication();
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    await tester.tap(find.text('7 hari'));
    await tester.pumpAndSettle();
    await capture('01-dashboard');
    await tester.scrollUntilVisible(
      find.text('Tren pendapatan'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await capture('02-insights');
    await tester.tap(find.text('Produk'));
    await capture('03-products');
    await tester.tap(find.text('Lainnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Kasir cepat'));
    await tester.pumpAndSettle();
    await capture('09-cashier');
    Navigator.of(tester.element(find.byType(PosPage))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transaksi'));
    await capture('04-transactions');
    await tester.tap(find.byTooltip('Piutang pelanggan'));
    await capture('05-receivables');
    await tester.tap(find.text('Pelanggan contoh • Rina'));
    await capture('06-sale-detail');
    final nav = Navigator.of(tester.element(find.byType(SaleDetailPage)));
    nav.pop();
    await tester.pumpAndSettle();
    nav.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();
    await capture('10-reports');
    await tester.scrollUntilVisible(
      find.text('Kalkulator harga'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ReportsPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Kalkulator harga'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'Harga jual/unit (Rp)'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(CalculatorPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Harga jual/unit (Rp)'),
      '25000',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Modal/unit (Rp)'),
      '12000',
    );
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Rencanakan untung'),
      -250,
      scrollable: find
          .descendant(
            of: find.byType(CalculatorPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await capture('07-calculator');
    Navigator.of(tester.element(find.byType(CalculatorPage))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pengaturan & backup'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Simpan backup JSON'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(SettingsPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await capture('08-backup');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
