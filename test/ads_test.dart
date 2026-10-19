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
}
