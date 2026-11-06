import 'package:flutter_test/flutter_test.dart';
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
}
