import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  testWidgets(
    'encrypted export password requires matching confirmation and cancellation returns no password',
    (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await backupPassword(context, confirmation: true);
                },
                child: const Text('Backup'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Backup'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'password-uji-panjang',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password-yang-berbeda',
      );
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();
      expect(
        find.text('Password minimal 12 karakter dan konfirmasi harus sama.'),
        findsOneWidget,
      );
      expect(result, isNull);
      await tester.enterText(
        find.byType(TextField).last,
        'password-uji-panjang',
      );
      await tester.tap(find.text('Lanjutkan'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(result, 'password-uji-panjang');
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
