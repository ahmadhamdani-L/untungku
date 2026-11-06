import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/support/performance_scenario.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android 10000 transaction read benchmark', (tester) async {
    final result = await performanceScenario(10000);
    debugPrint('PERFORMANCE_ANDROID ${jsonEncode(result)}');
    expect(result['sales'], 10000);
    expect(result['loadMs'], lessThan(30000));
    expect(result['insightMs'], lessThan(10000));
  });
}
