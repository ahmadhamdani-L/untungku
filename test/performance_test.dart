import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/performance_scenario.dart';

void main() {
  for (final count in [10000, 50000]) {
    test('read benchmark $count synthetic transactions', () async {
      final result = await performanceScenario(count);
      debugPrint('PERFORMANCE_HOST ${jsonEncode(result)}');
      expect(result['sales'], count);
      expect(result['products'], 1000);
      expect(result['loadMs'], lessThan(30000));
      expect(result['insightMs'], lessThan(10000));
    }, timeout: const Timeout(Duration(minutes: 3)));
  }
}
