import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:untungku_pro/services/ads.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Google test banner loads after UMP permits ad requests', (
    tester,
  ) async {
    expect(const bool.fromEnvironment('ADMOB_ENABLED'), isTrue);
    expect(
      const bool.fromEnvironment('ADMOB_USE_MOCK', defaultValue: true),
      isFalse,
    );
    // This device test must never request the owner's production ad units.
    expect(
      const String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID'),
      'ca-app-pub-3940256099942544/6300978111',
    );
    final service = GoogleAdsService();
    await tester.runAsync(() async {
      await service.initialize().timeout(const Duration(seconds: 60));
      expect(service.ready, isTrue);
      final banner = await service.loadBanner().timeout(
        const Duration(seconds: 60),
      );
      expect(banner, isNotNull, reason: 'A real Google test banner must fill');
      await banner!.dispose();
    });
  }, timeout: const Timeout(Duration(minutes: 3)));
  testWidgets(
    'Google test interstitial preloads without displaying at startup',
    (tester) async {
      expect(
        const String.fromEnvironment('ADMOB_INTERSTITIAL_AD_UNIT_ID'),
        'ca-app-pub-3940256099942544/1033173712',
      );
      final ads = CompletionAds(service: GoogleAdsService());
      try {
        ads.start();
        await tester.runAsync(() async {
          final deadline = DateTime.now().add(const Duration(seconds: 50));
          while (!ads.hasPreparedAd && DateTime.now().isBefore(deadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
          }
        });
        expect(
          ads.hasPreparedAd,
          isTrue,
          reason: 'A real Google test interstitial must preload',
        );
        expect(ads.policy.shown, 0);
      } finally {
        ads.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
  for (final format in PreparedFormat.values) {
    testWidgets('Google sample $format preloads without automatic display', (
      tester,
    ) async {
      expect(
        const String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID'),
        'ca-app-pub-3940256099942544/5224354917',
      );
      expect(
        const String.fromEnvironment('ADMOB_APP_OPEN_AD_UNIT_ID'),
        'ca-app-pub-3940256099942544/9257395921',
      );
      final session = AdSession();
      final placement = PreparedPlacement(
        format,
        service: GoogleAdsService(),
        session: session,
      );
      try {
        placement.start();
        await tester.runAsync(() async {
          final deadline = DateTime.now().add(const Duration(seconds: 60));
          while (!placement.ready && DateTime.now().isBefore(deadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
          }
        });
        expect(placement.ready, isTrue);
        expect(session.fullscreen, isFalse);
        expect(session.quiet, isFalse);
      } finally {
        placement.dispose();
        session.dispose();
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
  testWidgets('Google sample native template loads and renders', (
    tester,
  ) async {
    expect(
      const String.fromEnvironment('ADMOB_NATIVE_AD_UNIT_ID'),
      'ca-app-pub-3940256099942544/2247696110',
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OptionalNativeAd())),
    );
    await tester.pump();
    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (find.byType(AdWidget).evaluate().isEmpty &&
        DateTime.now().isBefore(deadline)) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await tester.pump();
    }
    expect(find.byType(AdWidget), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(minutes: 2)));
}
