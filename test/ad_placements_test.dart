import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:untungku_pro/services/ads.dart';
import 'ads_consent_test.dart' show OfflineConsent;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'session shares fullscreen exclusion, cooldown and exact reward expiry',
    () {
      var now = DateTime(2026, 11, 6);
      final session = AdSession(clock: () => now);
      addTearDown(session.dispose);
      expect(session.acquire(), isTrue);
      expect(session.acquire(voluntary: true), isFalse);
      session.shown();
      session.release();
      expect(session.automaticAllowed, isFalse);
      now = now.add(const Duration(minutes: 3));
      expect(session.automaticAllowed, isTrue);
      session.earnQuietTime();
      expect(session.acquire(voluntary: true), isFalse);
      now = now.add(const Duration(minutes: 30));
      expect(session.quiet, isFalse);
      expect(session.acquire(), isTrue);
    },
  );
  testWidgets('offline placements never request or render live ads', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(children: [OptionalNativeAd(), RewardedQuietTile()]),
        ),
      ),
    );
    expect(find.byType(AdWidget), findsNothing);
    expect(find.text('Jeda iklan'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  }, skip: liveAdsEnabled);

  group('live prepared adapters', () {
    final original = ConsentInformation.instance;
    late OfflineConsent consent;
    late AdSession session;
    late DateTime now;
    late Map<String, int> ids;
    late List<String> loads;
    var shows = 0;
    final channel = MethodChannel(
      'plugins.flutter.io/google_mobile_ads',
      StandardMethodCodec(AdMessageCodec()),
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    setUp(() {
      consent = OfflineConsent();
      ConsentInformation.instance = consent;
      now = DateTime(2026, 11, 6);
      session = AdSession(clock: () => now);
      ids = {};
      loads = [];
      shows = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'MobileAds#initialize') {
          return InitializationStatus(<String, AdapterStatus>{});
        }
        if ([
          'loadRewardedAd',
          'loadAppOpenAd',
          'loadNativeAd',
        ].contains(call.method)) {
          ids[call.method] = (call.arguments as Map)['adId'] as int;
          loads.add(call.method);
        }
        if (call.method == 'showAdWithoutView') shows++;
        return null;
      });
    });
    tearDown(() {
      session.dispose();
      ConsentInformation.instance = original;
      messenger.setMockMethodCallHandler(channel, null);
      adPrivacyRequired.value = false;
    });
    Future<void> event(
      WidgetTester tester,
      int id,
      String name, [
      Map<String, Object>? extras,
    ]) async {
      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          MethodCall('onAdEvent', {'adId': id, 'eventName': name, ...?extras}),
        ),
        (_) {},
      );
      await tester.pump();
    }

    for (final format in PreparedFormat.values) {
      testWidgets(
        '$format preloads only, rechecks safety/consent and expires',
        (tester) async {
          final placement = PreparedPlacement(
            format,
            service: GoogleAdsService(),
            session: session,
            clock: () => now,
          );
          addTearDown(placement.dispose);
          placement.start();
          await tester.pump();
          final method = format == PreparedFormat.rewarded
              ? 'loadRewardedAd'
              : 'loadAppOpenAd';
          expect(loads, [method]);
          expect(await placement.show(safe: () => true), isFalse);
          await event(tester, ids[method]!, 'onAdLoaded');
          expect(placement.ready, isTrue);
          expect(shows, 0);
          consent.allowed = false;
          expect(await placement.show(safe: () => true), isFalse);
          expect(shows, 0);
          consent.allowed = true;
          expect(await placement.show(safe: () => false), isFalse);
          expect(session.fullscreen, isFalse);
          now = now.add(
            format == PreparedFormat.appOpen
                ? const Duration(hours: 4)
                : const Duration(minutes: 55),
          );
          expect(placement.ready, isFalse);
          expect(await placement.show(safe: () => true), isFalse);
        },
      );
    }
    testWidgets(
      'reward is granted once only on earned callback; dismissal alone earns nothing',
      (tester) async {
        final placement = PreparedPlacement(
          PreparedFormat.rewarded,
          service: GoogleAdsService(),
          session: session,
          clock: () => now,
        );
        addTearDown(placement.dispose);
        placement.start();
        await tester.pump();
        var id = ids['loadRewardedAd']!;
        await event(tester, id, 'onAdLoaded');
        var finished = placement.show(safe: () => true);
        await tester.pump();
        expect(shows, 1);
        await event(tester, id, 'onAdShowedFullScreenContent');
        await event(tester, id, 'onAdDismissedFullScreenContent');
        expect(await finished, isFalse);
        expect(session.quiet, isFalse);
        await tester.pump();
        id = ids['loadRewardedAd']!;
        await event(tester, id, 'onAdLoaded');
        finished = placement.show(safe: () => true);
        await tester.pump();
        expect(shows, 2);
        await event(tester, id, 'onAdShowedFullScreenContent');
        await event(tester, id, 'onRewardedAdUserEarnedReward', {
          'rewardItem': RewardItem(1, 'quiet'),
        });
        final until = session.quietUntil;
        now = now.add(const Duration(minutes: 1));
        await event(tester, id, 'onRewardedAdUserEarnedReward', {
          'rewardItem': RewardItem(1, 'quiet'),
        });
        expect(session.quietUntil, until);
        await event(tester, id, 'onAdDismissedFullScreenContent');
        expect(await finished, isTrue);
        expect(session.quiet, isTrue);
        expect(session.fullscreen, isFalse);
        now = until!;
        await tester.pump(const Duration(minutes: 30));
      },
    );
    testWidgets(
      'app-open respects shared fullscreen gate, cooldown and session cap',
      (tester) async {
        final placement = PreparedPlacement(
          PreparedFormat.appOpen,
          service: GoogleAdsService(),
          session: session,
          clock: () => now,
        );
        addTearDown(placement.dispose);
        placement.start();
        await tester.pump();
        for (var count = 0; count < 2; count++) {
          final id = ids['loadAppOpenAd']!;
          await event(tester, id, 'onAdLoaded');
          session.fullscreen = true;
          expect(await placement.show(safe: () => true), isFalse);
          session.fullscreen = false;
          final finished = placement.show(safe: () => true);
          await tester.pump();
          await event(tester, id, 'onAdShowedFullScreenContent');
          await event(tester, id, 'onAdDismissedFullScreenContent');
          await finished;
          await tester.pump();
          expect(placement.canOpen, isFalse);
          now = now.add(const Duration(minutes: 10));
        }
        await event(tester, ids['loadAppOpenAd']!, 'onAdLoaded');
        expect(placement.canOpen, isFalse);
        expect(shows, 2);
      },
    );
    testWidgets(
      'failed preload backs off and disposed late callbacks never show',
      (tester) async {
        final placement = PreparedPlacement(
          PreparedFormat.appOpen,
          service: GoogleAdsService(),
          session: session,
        );
        placement.start();
        await tester.pump();
        final id = ids['loadAppOpenAd']!;
        await event(tester, id, 'onAdFailedToLoad', {
          'loadAdError': LoadAdError(3, 'test', 'No fill', null),
        });
        await tester.pump(const Duration(seconds: 29));
        expect(loads.length, 1);
        await tester.pump(const Duration(seconds: 1));
        expect(loads.length, 2);
        final late = ids['loadAppOpenAd']!;
        placement.dispose();
        await event(tester, late, 'onAdLoaded');
        expect(shows, 0);
        expect(placement.ready, isFalse);
        await tester.pump(const Duration(minutes: 5));
        expect(loads.length, 2);
      },
    );
    testWidgets(
      'native loads with SDK template, retries no fill and disposes on removal',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: OptionalNativeAd())),
        );
        await tester.pump();
        expect(loads, ['loadNativeAd']);
        await event(tester, ids['loadNativeAd']!, 'onAdFailedToLoad', {
          'loadAdError': LoadAdError(3, 'test', 'No fill', null),
        });
        await tester.pump(const Duration(seconds: 30));
        expect(loads.length, 2);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(minutes: 5));
        expect(loads.length, 2);
      },
    );
  }, skip: !liveAdsEnabled);
}
