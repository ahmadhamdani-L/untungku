import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/features/app.dart';
import 'package:untungku_pro/services/receipts/printer.dart';

void main() {
  testWidgets(
    'printer selection/width persist and failed test-print retry posts no sale',
    (tester) async {
      var attempts = 0;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(ReceiptPrinter.channel, (call) async {
        if (call.method == 'paired') {
          return [
            {'name': 'Printer uji', 'address': '00:11:22:33:44:55'},
          ];
        }
        if (++attempts == 1) {
          throw PlatformException(
            code: 'print_failed',
            message: 'Terputus. Periksa cetakan.',
          );
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(ReceiptPrinter.channel, null),
      );
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: PrinterSettingsPage()),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> tap(String text) async {
        await tester.scrollUntilVisible(
          find.text(text),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      await tap('80 mm');
      await tap('Muat printer berpasangan');
      await tap('Printer uji');
      expect(store.settings['receiptWidth'], 80);
      expect(store.settings['printerAddress'], '00:11:22:33:44:55');
      await tap('Uji cetak');
      expect(find.textContaining('Terputus. Periksa cetakan.'), findsOneWidget);
      await tap('Uji cetak');
      expect(attempts, 2);
      expect(store.sales, isEmpty);
      expect(await store.cashLedger(), isEmpty);
      await tester.pumpWidget(const SizedBox());
      final reopened = Store(db);
      await reopened.load();
      expect(reopened.settings['receiptWidth'], 80);
      expect(reopened.settings['printerAddress'], '00:11:22:33:44:55');
      reopened.dispose();
      await db.close();
    },
  );
}
