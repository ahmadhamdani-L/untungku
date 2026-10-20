import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdState { idle, loading, loaded, dismissed, failed, rewarded }

abstract interface class AdsService {
  Future<void> initialize();
  Stream<AdState> rewarded();
  Stream<AdState> interstitial();
  Future<BannerAd?> loadBanner();
}

class MockAdsService implements AdsService {
  final bool fail;
  MockAdsService({this.fail = false});
  @override
  Future<void> initialize() async {}
  @override
  Future<BannerAd?> loadBanner() async => null;
  @override
  Stream<AdState> interstitial() async* {
    yield AdState.loading;
    if (fail) {
      yield AdState.failed;
      return;
    }
    yield AdState.loaded;
    yield AdState.dismissed;
  }

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
  Future<BannerAd?> loadBanner() async {
    if (!ready || !await ConsentInformation.instance.canRequestAds()) {
      return null;
    }
    final result = Completer<BannerAd?>();
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: const String.fromEnvironment(
        'ADMOB_BANNER_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/6300978111',
      ),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => result.complete(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          result.complete(null);
        },
      ),
    );
    await ad.load();
    return result.future;
  }

  @override
  Stream<AdState> interstitial() {
    final states = StreamController<AdState>();
    void emit(AdState state) {
      if (!states.isClosed) {
        states.add(state);
      }
    }

    if (!ready) {
      states.add(AdState.failed);
      unawaited(states.close());
      return states.stream;
    }
    emit(AdState.loading);
    InterstitialAd.load(
      adUnitId: const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/1033173712',
      ),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          emit(AdState.loaded);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              emit(AdState.dismissed);
              ad.dispose();
              unawaited(states.close());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              emit(AdState.failed);
              ad.dispose();
              unawaited(states.close());
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          emit(AdState.failed);
          unawaited(states.close());
        },
      ),
    );
    return states.stream;
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

/// A single optional placement at the end of settings, clear of business controls.
class OptionalAdBanner extends StatefulWidget {
  const OptionalAdBanner({super.key});
  @override
  State<OptionalAdBanner> createState() => _OptionalAdBannerState();
}

class _OptionalAdBannerState extends State<OptionalAdBanner> {
  BannerAd? banner;
  bool privacyRequired = false;
  @override
  void initState() {
    super.initState();
    if (const bool.fromEnvironment('ADMOB_ENABLED') &&
        !const bool.fromEnvironment('ADMOB_USE_MOCK', defaultValue: true)) {
      unawaited(load());
    }
  }

  Future<void> load() async {
    try {
      final service = createAdsService();
      await service.initialize();
      final result = await service.loadBanner();
      if (!mounted) {
        result?.dispose();
        return;
      }
      setState(() => banner = result);
    } catch (_) {
      // Business functions remain available when advertising fails.
    } finally {
      // Privacy choices must not depend on whether an ad filled successfully.
      try {
        final required = await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus();
        if (mounted) {
          setState(
            () => privacyRequired =
                required == PrivacyOptionsRequirementStatus.required,
          );
        }
      } catch (_) {
        // A missing platform response must not interrupt the business screen.
      }
    }
  }

  void showPrivacy() {
    // Remove the old ad before a changed consent decision can take effect.
    setState(() {
      banner?.dispose();
      banner = null;
    });
    ConsentForm.showPrivacyOptionsForm((error) {
      if (mounted && error == null) {
        unawaited(load());
      }
    });
  }

  @override
  void dispose() {
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (banner != null) ...[
        const SizedBox(height: 16),
        const Text('Iklan'),
        SizedBox(
          width: banner!.size.width.toDouble(),
          height: banner!.size.height.toDouble(),
          child: AdWidget(ad: banner!),
        ),
      ],
      if (privacyRequired)
        TextButton(
          onPressed: showPrivacy,
          child: const Text('Pilihan privasi iklan'),
        ),
    ],
  );
}
