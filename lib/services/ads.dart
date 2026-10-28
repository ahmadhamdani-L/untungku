import 'dart:async';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdState { idle, loading, loaded, dismissed, failed, rewarded }

abstract interface class AdsService {
  Future<void> initialize();
  Stream<AdState> rewarded();
  Future<BannerAd?> loadBanner({AdSize? size});
}

class MockAdsService implements AdsService {
  final bool fail;
  MockAdsService({this.fail = false});
  @override
  Future<void> initialize() async {}
  @override
  Future<BannerAd?> loadBanner({AdSize? size}) async => null;
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
  Future<void>? _initialization;
  final String rewardedId;
  GoogleAdsService({
    this.rewardedId = const String.fromEnvironment(
      'ADMOB_REWARDED_AD_UNIT_ID',
      defaultValue: 'ca-app-pub-3940256099942544/5224354917',
    ),
  });
  @override
  Future<void> initialize() async {
    try {
      await (_initialization ??= _initialize());
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  Future<void> _initialize() async {
    if (!kReleaseMode &&
        [
          const String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID'),
          const String.fromEnvironment('ADMOB_INTERSTITIAL_AD_UNIT_ID'),
          rewardedId,
        ].any((id) => id.startsWith('ca-app-pub-6953774620667597/'))) {
      throw StateError('Production ads are disabled outside release builds');
    }
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
  Future<BannerAd?> loadBanner({AdSize? size}) async {
    if (!ready || !await ConsentInformation.instance.canRequestAds()) {
      return null;
    }
    final result = Completer<BannerAd?>();
    final ad = BannerAd(
      size: size ?? AdSize.banner,
      adUnitId: const String.fromEnvironment(
        'ADMOB_BANNER_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/6300978111',
      ),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => result.complete(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdMob banner gagal dimuat: $error');
          ad.dispose();
          result.complete(null);
        },
      ),
    );
    await ad.load();
    return result.future;
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

/// One SDK/consent session shared by every safe advertising placement.
final AdsService appAdsService = createAdsService();

class InterstitialFrequencyCap {
  InterstitialFrequencyCap({
    this.cooldown = const Duration(minutes: 10),
    this.maxPerDay = 3,
  });
  final Duration cooldown;
  final int maxPerDay;
  DateTime? _lastShown;
  DateTime? _day;
  int _shown = 0;
  int get shownToday => _shown;
  DateTime? get lastShown => _lastShown;

  void restore({required DateTime lastShown, required int shownToday}) {
    _lastShown = lastShown;
    _day = DateTime(lastShown.year, lastShown.month, lastShown.day);
    _shown = shownToday.clamp(0, maxPerDay);
  }

  bool canShow(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    if (_day != day) {
      _day = day;
      _shown = 0;
    }
    return _shown < maxPerDay &&
        (_lastShown == null || now.difference(_lastShown!) >= cooldown);
  }

  void recordShown(DateTime now) {
    if (!canShow(now)) throw StateError('Interstitial frequency cap reached');
    _lastShown = now;
    _shown++;
  }
}

/// Full-screen ads are shown only from an explicit navigation break, if ready.
/// Loading never opens an ad later on its own.
class AdManager {
  AdManager._();
  static final instance = AdManager._();
  final cap = InterstitialFrequencyCap();
  InterstitialAd? _prepared;
  bool _preparing = false;
  Future<void>? _initialization;
  Future<void> Function(DateTime time, int count)? persistImpression;

  void restoreFrequencyCap(Map<String, dynamic> settings) {
    final time = DateTime.tryParse(
      settings['adInterstitialLastShown']?.toString() ?? '',
    );
    final count = settings['adInterstitialCount'];
    if (time != null && count is int) {
      cap.restore(lastShown: time, shownToday: count);
    }
  }

  Future<void> initialize() async {
    try {
      await (_initialization ??= appAdsService.initialize());
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  Future<void> prepareInterstitial() async {
    if (_preparing || _prepared != null || !cap.canShow(DateTime.now())) return;
    _preparing = true;
    try {
      await initialize();
      if (appAdsService is MockAdsService ||
          !await ConsentInformation.instance.canRequestAds()) {
        _preparing = false;
        return;
      }
      InterstitialAd.load(
        adUnitId: const String.fromEnvironment(
          'ADMOB_INTERSTITIAL_AD_UNIT_ID',
          defaultValue: 'ca-app-pub-3940256099942544/1033173712',
        ),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _prepared = ad;
            _preparing = false;
          },
          onAdFailedToLoad: (_) => _preparing = false,
        ),
      );
    } catch (_) {
      _preparing = false;
    }
  }

  bool showPreparedAtNavigationBreak() {
    final ad = _prepared;
    final now = DateTime.now();
    if (ad == null || !cap.canShow(now)) return false;
    _prepared = null;
    cap.recordShown(now);
    final persist = persistImpression;
    if (persist != null) {
      unawaited(
        persist(now, cap.shownToday).catchError((Object error) {
          debugPrint('Ad impression cap could not be saved: $error');
        }),
      );
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, _) => ad.dispose(),
    );
    ad.show();
    return true;
  }

  void dispose() {
    _prepared?.dispose();
    _prepared = null;
  }
}

/// In-flow banner: never overlays navigation or reserves empty space on failure.
class OptionalAdBanner extends StatefulWidget {
  const OptionalAdBanner({super.key, this.active = true});
  final bool active;
  @override
  State<OptionalAdBanner> createState() => _OptionalAdBannerState();
}

class _OptionalAdBannerState extends State<OptionalAdBanner> {
  BannerAd? banner;
  AdSize? bannerSize;
  bool privacyRequired = false;
  bool loading = false;
  bool attempted = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  @override
  void didUpdateWidget(OptionalAdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _maybeLoad();
  }

  void _maybeLoad() {
    if (!mounted ||
        !widget.active ||
        loading ||
        attempted ||
        !const bool.fromEnvironment('ADMOB_ENABLED') ||
        const bool.fromEnvironment('ADMOB_USE_MOCK', defaultValue: true)) {
      return;
    }
    attempted = true;
    loading = true;
    unawaited(load());
  }

  Future<void> load() async {
    try {
      await AdManager.instance.initialize();
      if (!mounted || !widget.active) return;
      final width = (MediaQuery.sizeOf(context).width - 40)
          .clamp(1, 900)
          .toInt();
      final size = AdSize.getInlineAdaptiveBannerAdSize(width, 100);
      final result = await appAdsService.loadBanner(size: size);
      if (!mounted) {
        result?.dispose();
        return;
      }
      if (result != null) {
        final actualSize = await result.getPlatformAdSize();
        if (!mounted) {
          result.dispose();
          return;
        }
        if (actualSize == null || actualSize.height <= 0) {
          result.dispose();
          return;
        }
        setState(() {
          banner = result;
          bannerSize = actualSize;
        });
      }
    } catch (error) {
      debugPrint('AdMob tidak siap: $error');
      // Business functions remain available when advertising fails.
    } finally {
      loading = false;
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
      bannerSize = null;
      attempted = false;
    });
    ConsentForm.showPrivacyOptionsForm((error) {
      if (mounted && error == null) {
        _maybeLoad();
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
    mainAxisSize: MainAxisSize.min,
    children: [
      if (banner != null && bannerSize != null) ...[
        const SizedBox(height: 16),
        const Text('Iklan'),
        SizedBox(
          width: bannerSize!.width.toDouble(),
          height: bannerSize!.height.toDouble(),
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
