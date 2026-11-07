import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/features/app.dart';
import 'package:untungku_pro/services/ads.dart';

void main() {
  testWidgets(
    'report navigation retains calculator and isolates banner from forms',
    (tester) async {
      await initializeDateFormatting('id_ID');
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
      await tester.pumpAndSettle();
      expect(find.text('LabaRapi'), findsOneWidget);
      expect(find.byType(OptionalAdBanner), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Kasir cepat'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(Dashboard),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Kasir cepat'));
      await tester.pumpAndSettle();
      expect(find.byType(PosPage), findsOneWidget);
      expect(find.byType(OptionalAdBanner).hitTestable(), findsNothing);
      Navigator.of(tester.element(find.byType(PosPage))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transaksi'));
      await tester.pumpAndSettle();
      expect(find.byType(OptionalAdBanner), findsNothing);
      await tester.tap(find.text('Laporan'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportsPage), findsOneWidget);
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
      expect(find.byType(CalculatorPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
