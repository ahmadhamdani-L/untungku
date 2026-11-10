part of 'ads.dart';

/// Shared session-wide spacing across fullscreen formats. Rewards never touch
/// business data and expire with this process (as disclosed in the opt-in UI).
class AdSession extends ChangeNotifier {
  final DateTime Function() now;
  AdSession({DateTime Function()? clock}) : now = clock ?? DateTime.now;
  DateTime? quietUntil, lastFullscreen;
  bool fullscreen = false;
  Timer? _expiry;
  bool get quiet => quietUntil != null && now().isBefore(quietUntil!);
  bool get automaticAllowed =>
      !quiet &&
      !fullscreen &&
      (lastFullscreen == null ||
          now().difference(lastFullscreen!) >= const Duration(minutes: 3));
  bool acquire({bool voluntary = false}) {
    if (fullscreen || quiet || (!voluntary && !automaticAllowed)) return false;
    fullscreen = true;
    return true;
  }

  void shown() => lastFullscreen = now();
  void release() {
    fullscreen = false;
  }

  void earnQuietTime() {
    quietUntil = now().add(const Duration(minutes: 30));
    _expiry?.cancel();
    _expiry = Timer(const Duration(minutes: 30), notifyListeners);
    notifyListeners();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }
}

final adSession = AdSession();

/// Warm returns only; ad-generated pauses must not create another opportunity.
class WarmResumePolicy {
  final DateTime Function() now;
  DateTime? _backgrounded;
  WarmResumePolicy({DateTime Function()? clock}) : now = clock ?? DateTime.now;
  void background({required bool fullscreen}) {
    if (!fullscreen) _backgrounded = now();
  }

  bool resume() {
    final since = _backgrounded;
    _backgrounded = null;
    return since != null &&
        now().difference(since) >= const Duration(seconds: 30);
  }
}

enum PreparedFormat { rewarded, appOpen }

/// Only preloaded ads may be shown. Late loads cannot interrupt the user.
class PreparedPlacement extends ChangeNotifier with WidgetsBindingObserver {
  final PreparedFormat format;
  final GoogleAdsService service;
  final AdSession session;
  final DateTime Function() now;
  final VoidCallback? onEarned;
  PreparedPlacement(
    this.format, {
    GoogleAdsService? service,
    AdSession? session,
    DateTime Function()? clock,
    this.onEarned,
  }) : service = service ?? _googleAdsService,
       session = session ?? adSession,
       now = clock ?? DateTime.now;
  AdWithoutView? _ad;
  DateTime? _loadedAt, _lastOpen;
  bool _started = false, _loading = false, _disposed = false;
  int _generation = 0, _openCount = 0;
  Timer? _retry;
  int _retrySeconds = 30;
  bool get _foreground =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  Duration get maxAge => format == PreparedFormat.appOpen
      ? const Duration(hours: 4)
      : const Duration(minutes: 55);
  bool get ready =>
      _ad != null && _loadedAt != null && now().difference(_loadedAt!) < maxAge;
  bool get loading => _loading;
  bool get canOpen =>
      format == PreparedFormat.appOpen &&
      ready &&
      _openCount < 2 &&
      session.automaticAllowed &&
      (_lastOpen == null ||
          now().difference(_lastOpen!) >= const Duration(minutes: 10));

  void start() {
    if (!liveAdsEnabled || _started || _disposed) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _adPrivacyOpen.addListener(_invalidate);
    session.addListener(_invalidate);
    unawaited(prepare());
  }

  void _invalidate() {
    _generation++;
    _retry?.cancel();
    _ad?.dispose();
    _ad = null;
    _loading = false;
    notifyListeners();
    if (!_adPrivacyOpen.value && !session.quiet) unawaited(prepare());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(prepare());
    } else {
      _retry?.cancel();
    }
  }

  void _scheduleRetry() {
    if (!_started || !_foreground || session.quiet || _adPrivacyOpen.value) {
      return;
    }
    _retry?.cancel();
    _retry = Timer(
      Duration(seconds: _retrySeconds),
      () => unawaited(prepare()),
    );
    _retrySeconds = (_retrySeconds * 2).clamp(30, 300);
  }

  Future<void> prepare() async {
    if (!_started ||
        _disposed ||
        _loading ||
        ready ||
        !_foreground ||
        session.quiet ||
        _adPrivacyOpen.value) {
      return;
    }
    _retry?.cancel();
    _ad?.dispose();
    _ad = null;
    _loading = true;
    final generation = _generation;
    void loaded(AdWithoutView ad) {
      if (_disposed ||
          generation != _generation ||
          _adPrivacyOpen.value ||
          session.quiet) {
        ad.dispose();
        return;
      }
      _ad = ad;
      _loadedAt = now();
      _loading = false;
      _retrySeconds = 30;
      notifyListeners();
    }

    void failed(Object error) {
      if (_disposed || generation != _generation) return;
      _loading = false;
      notifyListeners();
      _scheduleRetry();
    }

    try {
      await service.initialize();
      if (_disposed || generation != _generation) return;
      final allowed = await ConsentInformation.instance.canRequestAds();
      if (_disposed || generation != _generation) return;
      if (!_foreground || _adPrivacyOpen.value || session.quiet || !allowed) {
        _loading = false;
        return;
      }
      if (format == PreparedFormat.rewarded) {
        await RewardedAd.load(
          adUnitId: service.rewardedId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: loaded,
            onAdFailedToLoad: failed,
          ),
        );
      } else {
        await AppOpenAd.load(
          adUnitId: const String.fromEnvironment(
            'ADMOB_APP_OPEN_AD_UNIT_ID',
            defaultValue: 'ca-app-pub-3940256099942544/9257395921',
          ),
          request: const AdRequest(),
          adLoadCallback: AppOpenAdLoadCallback(
            onAdLoaded: loaded,
            onAdFailedToLoad: failed,
          ),
        );
      }
    } catch (error) {
      failed(error);
    }
  }

  Future<bool> show({required bool Function() safe}) async {
    final voluntary = format == PreparedFormat.rewarded;
    if (!liveAdsEnabled ||
        !ready ||
        !safe() ||
        !_foreground ||
        _adPrivacyOpen.value ||
        (!voluntary && !canOpen) ||
        !session.acquire(voluntary: voluntary)) {
      return false;
    }
    final generation = _generation;
    var earned = false, finished = false;
    final done = Completer<bool>();
    AdWithoutView? presenting;
    void finish() {
      if (finished) return;
      finished = true;
      presenting?.dispose();
      session.release();
      if (!done.isCompleted) done.complete(earned);
      if (!_disposed) {
        notifyListeners();
        unawaited(prepare());
      }
    }

    void showed() {
      session.shown();
      if (!voluntary) {
        _openCount++;
        _lastOpen = now();
      }
    }

    try {
      if (!await ConsentInformation.instance.canRequestAds() ||
          _disposed ||
          generation != _generation ||
          !safe() ||
          !_foreground ||
          _adPrivacyOpen.value) {
        finish();
        return false;
      }
      final ad = _ad;
      presenting = ad;
      _ad = null;
      if (ad is RewardedAd) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => showed(),
          onAdDismissedFullScreenContent: (_) => finish(),
          onAdFailedToShowFullScreenContent: (_, error) => finish(),
        );
        await ad.show(
          onUserEarnedReward: (_, reward) {
            if (!earned && !finished && !_disposed) {
              earned = true;
              if (onEarned != null) {
                onEarned!();
              } else {
                session.earnQuietTime();
              }
            }
          },
        );
      } else if (ad is AppOpenAd) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => showed(),
          onAdDismissedFullScreenContent: (_) => finish(),
          onAdFailedToShowFullScreenContent: (_, error) => finish(),
        );
        await ad.show();
      } else {
        finish();
      }
    } catch (_) {
      finish();
    }
    return done.future;
  }

  @override
  void dispose() {
    _disposed = true;
    _started = false;
    _generation++;
    _retry?.cancel();
    _ad?.dispose();
    _ad = null;
    WidgetsBinding.instance.removeObserver(this);
    _adPrivacyOpen.removeListener(_invalidate);
    session.removeListener(_invalidate);
    super.dispose();
  }
}

/// SDK templates own attribution, AdChoices and click handling.
class OptionalNativeAd extends StatefulWidget {
  const OptionalNativeAd({super.key});
  @override
  State<OptionalNativeAd> createState() => _OptionalNativeAdState();
}

class _OptionalNativeAdState extends State<OptionalNativeAd>
    with WidgetsBindingObserver {
  NativeAd? _ad;
  bool _loaded = false;
  int _generation = 0;
  Timer? _retry;
  int _retrySeconds = 30;
  @override
  void initState() {
    super.initState();
    if (liveAdsEnabled) {
      WidgetsBinding.instance.addObserver(this);
      _adPrivacyOpen.addListener(_reload);
      adSession.addListener(_reload);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    }
  }

  bool get _foreground =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  void _scheduleRetry() {
    if (!mounted || !_foreground || adSession.quiet || _adPrivacyOpen.value) {
      return;
    }
    _retry?.cancel();
    _retry = Timer(Duration(seconds: _retrySeconds), _reload);
    _retrySeconds = (_retrySeconds * 2).clamp(30, 300);
  }

  void _reload() {
    if (!mounted) return;
    final generation = ++_generation;
    _retry?.cancel();
    _ad?.dispose();
    _ad = null;
    setState(() => _loaded = false);
    if (adSession.quiet ||
        _adPrivacyOpen.value ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.hidden) {
      return;
    }
    unawaited(_load(generation));
  }

  Future<void> _load(int generation) async {
    try {
      await _googleAdsService.initialize();
      final allowed = await ConsentInformation.instance.canRequestAds();
      if (!mounted ||
          generation != _generation ||
          adSession.quiet ||
          _adPrivacyOpen.value ||
          !allowed ||
          !_foreground) {
        return;
      }
      final ad = NativeAd(
        adUnitId: const String.fromEnvironment(
          'ADMOB_NATIVE_AD_UNIT_ID',
          defaultValue: 'ca-app-pub-3940256099942544/2247696110',
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (!mounted ||
                generation != _generation ||
                adSession.quiet ||
                _adPrivacyOpen.value) {
              ad.dispose();
              return;
            }
            _retrySeconds = 30;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted || generation != _generation) return;
            _ad = null;
            _scheduleRetry();
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      if (mounted && generation == _generation) {
        _scheduleRetry();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _ad == null) {
      _reload();
    } else if (state != AppLifecycleState.resumed) {
      _retry?.cancel();
    }
  }

  @override
  void dispose() {
    _generation++;
    _retry?.cancel();
    _ad?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _adPrivacyOpen.removeListener(_reload);
    adSession.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!liveAdsEnabled ||
        adSession.quiet ||
        !_loaded ||
        _ad == null ||
        ModalRoute.isCurrentOf(context) == false) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: [
          const Text('Iklan', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(height: 120, width: 400, child: AdWidget(ad: _ad!)),
        ],
      ),
    );
  }
}

class RewardedQuietTile extends StatefulWidget {
  const RewardedQuietTile({super.key});
  @override
  State<RewardedQuietTile> createState() => _RewardedQuietTileState();
}

class _RewardedQuietTileState extends State<RewardedQuietTile> {
  late final PreparedPlacement placement;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    placement = PreparedPlacement(PreparedFormat.rewarded)..start();
  }

  @override
  void dispose() {
    placement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!liveAdsEnabled) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: Listenable.merge([placement, adSession]),
      builder: (context, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jeda iklan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                adSession.quiet
                    ? 'Jeda iklan aktif hingga ${TimeOfDay.fromDateTime(adSession.quietUntil!).format(context)} pada sesi ini.'
                    : 'Pilihan: selesaikan satu iklan untuk jeda semua iklan selama 30 menit pada sesi aplikasi ini. Semua fitur tetap bisa digunakan tanpa menonton.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: busy || adSession.quiet || !placement.ready
                    ? null
                    : () async {
                        final confirmed = await confirmRewardAd(
                          context,
                          'Jeda semua iklan selama 30 menit pada sesi ini.',
                        );
                        if (!confirmed || !mounted) return;
                        setState(() => busy = true);
                        final earned = await placement.show(
                          safe: () =>
                              mounted &&
                              ModalRoute.isCurrentOf(context) != false,
                        );
                        if (!mounted || !context.mounted) return;
                        setState(() => busy = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              earned
                                  ? 'Jeda iklan 30 menit aktif pada sesi ini.'
                                  : 'Iklan belum selesai. Jeda iklan belum diberikan.',
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.ondemand_video_outlined),
                label: Text(
                  adSession.quiet
                      ? 'Jeda aktif'
                      : placement.ready
                      ? 'Tonton iklan • jeda 30 menit'
                      : placement.loading
                      ? 'Menyiapkan iklan…'
                      : 'Iklan belum tersedia',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
