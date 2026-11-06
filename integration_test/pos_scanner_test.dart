import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native scanner can return to manual input', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
                );
              },
              child: const Text('Open scanner'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open scanner'));
    // A native camera preview can keep scheduling frames.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Masukkan barcode manual'), findsOneWidget);
    await tester.tap(find.text('Masukkan barcode manual'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Open scanner'), findsOneWidget);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
