import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/core/security/pin_controller.dart';
import 'package:untungku_pro/features/app.dart';
import 'security_test.dart' show MemoryVault;

void main() {
  testWidgets(
    'PIN setup confirmation and idle/background lock hide all routes',
    (tester) async {
      final controller = PinController(MemoryVault());
      await controller.load();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [pinProvider.overrideWithValue(controller)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PinSettingsPage()),
                  ),
                  child: const Text('Atur PIN'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atur PIN'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'PIN baru (4–6 digit)'),
        '1234',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Konfirmasi PIN baru'),
        '9999',
      );
      await tester.scrollUntilVisible(
        find.text('Simpan PIN'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Simpan PIN'));
      await tester.pumpAndSettle();
      expect(controller.enabled, false);
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Konfirmasi PIN baru'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Konfirmasi PIN baru'),
        '1234',
      );
      await tester.ensureVisible(find.byType(DropdownButtonFormField<int>));
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30 detik').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simpan PIN'));
      await tester.tap(find.text('Simpan PIN'));
      await tester.pump();
      for (var i = 0; i < 100 && !controller.enabled; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
      }
      expect(controller.enabled, true);
      expect(controller.timeoutSeconds, 30);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              SecurityGate(controller: controller, child: child!),
          home: const Scaffold(
            body: Column(
              children: [
                Text('Data rahasia'),
                TextField(decoration: InputDecoration(labelText: 'Catatan')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Data rahasia'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Catatan'), 'a');
      await tester.pump(const Duration(seconds: 20));
      await tester.enterText(find.widgetWithText(TextField, 'Catatan'), 'ab');
      await tester.pump(const Duration(seconds: 20));
      expect(
        controller.locked,
        false,
        reason: 'Soft-keyboard editing counts as activity',
      );
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();
      expect(find.text('Data rahasia'), findsNothing);
      expect(find.text('Buka LabaRapi'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'PIN'), '1234');
      await tester.tap(find.text('Buka'));
      for (var i = 0; i < 100 && controller.locked; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
      }
      expect(controller.locked, false);
      await tester.pumpAndSettle();
      expect(find.text('Data rahasia'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text('Data rahasia'), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
}
