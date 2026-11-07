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
  for (final width in [320.0, 360.0, 1024.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('v2 layouts ${width.toInt()} $brightness at large text', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        final store = Store(db);
        await store.load();
        await store.saveProduct(
          const Product(
            id: 'p',
            name: 'Kopi',
            price: 10000,
            cost: 5000,
            stock: 5,
            created: '2026-11-05',
            updated: '2026-11-05',
          ),
        );
        await store.saveSale(
          const Sale(
            id: 's',
            date: '2026-11-05T10:00:00',
            lines: [
              SaleLine(
                productId: 'p',
                name: 'Kopi',
                quantity: 1,
                price: 10000,
                cost: 5000,
                packaging: 0,
                extra: 0,
              ),
            ],
          ),
        );
        final semantics = tester.ensureSemantics();
        final overrides = [storeProvider.overrideWith((ref) => store)];
        for (final page in const <Widget>[
          Dashboard(),
          ReportsPage(),
          PosPage(),
          ProductImportPage(),
          BusinessInsightsPage(),
          ReceiptPage(saleId: 's'),
          PrinterSettingsPage(),
          SettingsPage(),
        ]) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: overrides,
              child: MaterialApp(
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: brightness,
                  colorSchemeSeed: const Color(0xFF1565C0),
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.3)),
                  child: child!,
                ),
                home: Scaffold(body: page),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${page.runtimeType} should fit',
          );
          expect(tester.getSemantics(find.byType(Scaffold).first), isNotNull);
        }
        semantics.dispose();
        await tester.pumpWidget(const SizedBox());
        await store.db.close();
      });
    }
  }
}
