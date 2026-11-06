import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android receipt save success and share cancellations preserve data',
    (tester) async {
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
          id: 'native-receipt',
          date: '2026-11-05T10:00:00',
          lines: [
            SaleLine(
              productId: 'p',
              name: 'Kopi native',
              quantity: 1,
              price: 10000,
              cost: 5000,
              packaging: 0,
              extra: 0,
            ),
          ],
        ),
      );
      final before = jsonDecode(store.backup()) as Map<String, dynamic>
        ..remove('created');
      final ledger = (await store.cashLedger()).map((r) => r.toJson()).toList();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: ReceiptPage(saleId: 'native-receipt')),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in [
        'Simpan PDF struk',
        'Bagikan PDF struk',
        'Bagikan gambar struk',
      ]) {
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(label));
        await tester.pump(const Duration(seconds: 2));
        // The host dismisses the real Android dialog using adb BACK.
        var recovered = false;
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          final button = tester.widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Simpan PDF struk'),
          );
          if (button.onPressed != null) {
            recovered = true;
            break;
          }
        }
        expect(
          recovered,
          isTrue,
          reason: '$label must recover after native cancellation',
        );
        expect(find.text('PDF struk disimpan.'), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
      }
      await tester.scrollUntilVisible(
        find.text('Simpan PDF struk'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Simpan PDF struk'));
      await tester.pump(const Duration(seconds: 2));
      for (
        var i = 0;
        i < 60 && find.text('PDF struk disimpan.').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(find.text('PDF struk disimpan.'), findsOneWidget);
      expect(
        jsonDecode(store.backup()) as Map<String, dynamic>..remove('created'),
        before,
      );
      expect(
        (await store.cashLedger()).map((r) => r.toJson()).toList(),
        ledger,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
