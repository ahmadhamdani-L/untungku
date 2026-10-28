import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/services/ads.dart';

void main() {
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
  test('mock banner never loads SDK', () async {
    expect(await MockAdsService().loadBanner(), isNull);
  });
  test('interstitial cap enforces cooldown, daily maximum, and restore', () {
    final cap = InterstitialFrequencyCap();
    final start = DateTime(2026, 10, 28, 9);
    expect(cap.canShow(start), isTrue);
    cap.recordShown(start);
    expect(cap.canShow(start.add(const Duration(minutes: 9))), isFalse);
    expect(cap.canShow(start.add(const Duration(minutes: 10))), isTrue);
    cap.recordShown(start.add(const Duration(minutes: 10)));
    cap.recordShown(start.add(const Duration(minutes: 20)));
    expect(cap.canShow(start.add(const Duration(hours: 3))), isFalse);
    final restored = InterstitialFrequencyCap()
      ..restore(
        lastShown: start.add(const Duration(minutes: 20)),
        shownToday: 3,
      );
    expect(restored.canShow(start.add(const Duration(hours: 3))), isFalse);
    expect(restored.canShow(start.add(const Duration(days: 1))), isTrue);
  });
}
