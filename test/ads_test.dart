import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/services/ads.dart';

void main() {
  testWidgets('banner does not render a privacy button; settings owns it', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OptionalAdBanner())),
    );
    expect(find.text('Pilihan privasi iklan'), findsNothing);
    adPrivacyRequired.value = true;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdPrivacyOptions())),
    );
    expect(find.text('Pilihan privasi iklan'), findsOneWidget);
    adPrivacyRequired.value = false;
    await tester.pump();
    expect(find.text('Pilihan privasi iklan'), findsNothing);
  });
  test('development never initializes live SDK', () {
    expect(createAdsService(), isA<MockAdsService>());
  });
  test('deterministic reward and failure', () async {
    expect(await MockAdsService().rewarded().toList(), [
      AdState.loading,
      AdState.loaded,
      AdState.rewarded,
      AdState.dismissed,
    ]);
    expect(await MockAdsService(fail: true).rewarded().toList(), [
      AdState.loading,
      AdState.failed,
    ]);
  });
  test('mock banner never loads SDK and interstitial has no reward', () async {
    expect(await MockAdsService().loadBanner(), isNull);
    expect(await MockAdsService().interstitial().toList(), [
      AdState.loading,
      AdState.loaded,
      AdState.dismissed,
    ]);
  });
}
