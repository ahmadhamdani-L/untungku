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
  Future<void>? _initializing;
  final String rewardedId;
  GoogleAdsService({
    this.rewardedId = const String.fromEnvironment(
      'ADMOB_REWARDED_AD_UNIT_ID',
      defaultValue: 'ca-app-pub-3940256099942544/5224354917',
    ),
  });
  @override
  Future<void> initialize() =>
      _initializing ??= _initialize().catchError((Object error) {
        _initializing = null;
        throw error;
      });

  Future<void> _initialize() async {
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
    try {
      await consent.future;
    } catch (error) {
      // UMP can still allow requests using a previous session's decision.
      debugPrint('AdMob consent update failed: $error');
    }
    try {
      await refreshAdPrivacyRequirement();
    } catch (error) {
      debugPrint('AdMob privacy options status unavailable: $error');
    }
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
          debugPrint('AdMob banner failed to load: $error');
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

const liveAdsEnabled =
    bool.fromEnvironment('ADMOB_ENABLED') &&
    !bool.fromEnvironment('ADMOB_USE_MOCK', defaultValue: true);
final _googleAdsService = GoogleAdsService();
final adPrivacyRequired = ValueNotifier<bool>(false);
final _adPrivacyOpen = ValueNotifier<bool>(false);

Future<void> refreshAdPrivacyRequirement() async {
  adPrivacyRequired.value =
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;
}

AdsService createAdsService() =>
    liveAdsEnabled ? _googleAdsService : MockAdsService();

/// One persistent banner above navigation; privacy choices live in settings.
class OptionalAdBanner extends StatefulWidget {
  const OptionalAdBanner({super.key});
  @override
  State<OptionalAdBanner> createState() => _OptionalAdBannerState();
}

class _OptionalAdBannerState extends State<OptionalAdBanner>
    with WidgetsBindingObserver {
  BannerAd? banner;
  Timer? _retry;
  bool _loading = false;
  int _generation = 0;
  int _retrySeconds = 30;

  @override
  void initState() {
    super.initState();
    if (liveAdsEnabled) {
      WidgetsBinding.instance.addObserver(this);
      _adPrivacyOpen.addListener(_privacyChanged);
      // Show any required consent form after the first screen has rendered.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(load());
      });
    }
  }

  void _privacyChanged() {
    _generation++;
    _retry?.cancel();
    setState(() {
      banner?.dispose();
      banner = null;
      _loading = false;
    });
    if (!_adPrivacyOpen.value) unawaited(load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && banner == null) {
      unawaited(load());
    } else if (state != AppLifecycleState.resumed) {
      _retry?.cancel();
    }
  }

  Future<void> load() async {
    if (_loading || !mounted || _adPrivacyOpen.value) return;
    _retry?.cancel();
    _loading = true;
    final generation = _generation;
    try {
      final service = createAdsService();
      await service.initialize();
      if (!mounted || generation != _generation) return;
      final result = await service.loadBanner();
      if (!mounted || generation != _generation) {
        result?.dispose();
        return;
      }
      setState(() => banner = result);
      if (result != null) _retrySeconds = 30;
    } catch (error) {
      debugPrint('AdMob banner unavailable: $error');
    } finally {
      if (mounted && generation == _generation) {
        _loading = false;
        final lifecycle = WidgetsBinding.instance.lifecycleState;
        if (banner == null &&
            !_adPrivacyOpen.value &&
            (lifecycle == null || lifecycle == AppLifecycleState.resumed)) {
          _retry = Timer(
            Duration(seconds: _retrySeconds),
            () => unawaited(load()),
          );
          _retrySeconds = (_retrySeconds * 2).clamp(30, 120);
        }
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _retry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _adPrivacyOpen.removeListener(_privacyChanged);
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => banner == null
      ? const SizedBox.shrink()
      : SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Iklan'),
                SizedBox(
                  width: banner!.size.width.toDouble(),
                  height: banner!.size.height.toDouble(),
                  child: AdWidget(ad: banner!),
                ),
              ],
            ),
          ),
        );
}

class AdPrivacyOptions extends StatelessWidget {
  const AdPrivacyOptions({super.key});

  Future<void> _show(BuildContext context) async {
    if (_adPrivacyOpen.value) return;
    _adPrivacyOpen.value = true;
    try {
      final done = Completer<FormError?>();
      ConsentForm.showPrivacyOptionsForm(done.complete);
      final error = await done.future;
      await refreshAdPrivacyRequirement();
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilihan privasi belum dapat dibuka. Coba lagi.'),
          ),
        );
      }
    } catch (error) {
      debugPrint('AdMob privacy options unavailable: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilihan privasi belum dapat dibuka. Coba lagi.'),
          ),
        );
      }
    } finally {
      // Reload only after the form closes, including cancellation/errors.
      _adPrivacyOpen.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: adPrivacyRequired,
    builder: (context, required, _) => !required
        ? const SizedBox.shrink()
        : ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Pilihan privasi iklan'),
            onTap: () => unawaited(_show(context)),
          ),
  );
}
