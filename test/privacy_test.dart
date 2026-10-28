import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/features/privacy.dart';

void main() {
  testWidgets(
    'bundled privacy policy identifies owner and explains ads offline',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));
      await tester.pumpAndSettle();
      expect(find.text('Kebijakan Privasi LarisKas'), findsOneWidget);
      expect(find.textContaining('PT DDD DREAM DEVELOP DIGITAL'), findsWidgets);
      expect(find.textContaining('hmdhmdndani@gmail.com'), findsWidgets);
      expect(
        find.text('Iklan Google AdMob dan data perangkat'),
        findsOneWidget,
      );
      expect(
        find.text('Penyimpanan, retensi, dan penghapusan'),
        findsOneWidget,
      );
      expect(
        find.text('Kebijakan ini dapat dibaca tanpa internet.'),
        findsOneWidget,
      );
      expect(find.textContaining('BELUM DIISI'), findsNothing);
    },
  );
}
