import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdState { idle, loading, loaded, dismissed, failed, rewarded }

abstract interface class AdsService {
  Future<void> initialize();
  Stream<AdState> rewarded();
}

class MockAdsService implements AdsService {
  final bool fail;
  MockAdsService({this.fail = false});
  @override
  Future<void> initialize() async {}
  @override
  Stream<AdState> rewarded() async* {
    yield AdState.loading;
    if (fail) {
      yield AdState.failed;
      return;
    }
    yield AdState.loaded;
    yield AdState.rewarded;
    yield AdState.dismissed;
  }
}

class GoogleAdsService implements AdsService {
  bool ready = false;
  final String rewardedId;
  GoogleAdsService({
    this.rewardedId = const String.fromEnvironment(
      'ADMOB_REWARDED_AD_UNIT_ID',
      defaultValue: 'ca-app-pub-3940256099942544/5224354917',
    ),
  });
  @override
  Future<void> initialize() async {
    if (!const bool.fromEnvironment('ADMOB_ENABLED') ||
        const bool.fromEnvironment('ADMOB_USE_MOCK', defaultValue: true)) {
      throw StateError('Live ads disabled');
    }
    final consent = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) {
            consent.completeError(StateError(error.message));
          } else {
            consent.complete();
          }
        });
      },
      (error) => consent.completeError(StateError(error.message)),
    );
    await consent.future;
    if (!await ConsentInformation.instance.canRequestAds()) {
      throw StateError('Consent does not permit ads');
    }
    await MobileAds.instance.initialize();
    ready = true;
  }

  @override
  Stream<AdState> rewarded() {
    final controller = StreamController<AdState>();
    void emit(AdState s) {
      if (!controller.isClosed) {
        controller.add(s);
      }
    }

    if (!ready) {
      controller.add(AdState.failed);
      unawaited(controller.close());
      return controller.stream;
    }
    emit(AdState.loading);
    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          emit(AdState.loaded);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              emit(AdState.dismissed);
              ad.dispose();
              unawaited(controller.close());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              emit(AdState.failed);
              ad.dispose();
              unawaited(controller.close());
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) => emit(AdState.rewarded));
        },
        onAdFailedToLoad: (error) {
          emit(AdState.failed);
          unawaited(controller.close());
        },
      ),
    );
    return controller.stream;
  }
}

AdsService createAdsService() =>
    !const bool.fromEnvironment('ADMOB_ENABLED') ||
        const bool.fromEnvironment('ADMOB_USE_MOCK', defaultValue: true)
    ? MockAdsService()
    : GoogleAdsService();
