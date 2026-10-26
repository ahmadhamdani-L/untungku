import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// The SDK's platform codec is required to simulate native responses.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:untungku_pro/services/ads.dart';

class OfflineConsent extends ConsentInformation {
  bool allowed = true;
  int updates = 0;
  @override
  void requestConsentInfoUpdate(
    ConsentRequestParameters params,
    OnConsentInfoUpdateSuccessListener successListener,
    OnConsentInfoUpdateFailureListener failureListener,
  ) {
    updates++;
    failureListener(FormError(errorCode: 1, message: 'Offline'));
  }

  @override
  Future<bool> canRequestAds() async => allowed;
  @override
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async =>
      PrivacyOptionsRequirementStatus.required;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalConsent = ConsentInformation.instance;
  late OfflineConsent consent;
  var sdkInitializations = 0;
  final channel = MethodChannel(
    'plugins.flutter.io/google_mobile_ads',
    StandardMethodCodec(AdMessageCodec()),
  );

  setUp(() {
    consent = OfflineConsent();
    ConsentInformation.instance = consent;
    sdkInitializations = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'MobileAds#initialize') {
            sdkInitializations++;
            return InitializationStatus(<String, AdapterStatus>{});
          }
          return null;
        });
  });
  tearDown(() {
    ConsentInformation.instance = originalConsent;
    adPrivacyRequired.value = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('live consent adapter', () {
    test(
      'uses valid previous consent after update fails and initializes once',
      () async {
        final service = GoogleAdsService();
        await Future.wait([service.initialize(), service.initialize()]);
        await service.initialize();
        expect(service.ready, isTrue);
        expect(consent.updates, 1);
        expect(sdkInitializations, 1);
        expect(adPrivacyRequired.value, isTrue);
      },
    );

    test(
      'blocks SDK without consent and permits retry after failure',
      () async {
        consent.allowed = false;
        final service = GoogleAdsService();
        await expectLater(service.initialize(), throwsStateError);
        expect(service.ready, isFalse);
        expect(sdkInitializations, 0);
        expect(await service.loadBanner(), isNull);
        consent.allowed = true;
        await service.initialize();
        expect(service.ready, isTrue);
        expect(consent.updates, 2);
        expect(sdkInitializations, 1);
      },
    );
    testWidgets('no fill retries with backoff and stops when removed', (
      tester,
    ) async {
      var loads = 0;
      var lastAdId = -1;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'MobileAds#initialize') {
          return InitializationStatus(<String, AdapterStatus>{});
        }
        if (call.method == 'loadBannerAd') {
          loads++;
          lastAdId = (call.arguments as Map)['adId'] as int;
        }
        return null;
      });
      Future<void> noFill() async {
        await messenger.handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            MethodCall('onAdEvent', {
              'adId': lastAdId,
              'eventName': 'onAdFailedToLoad',
              'loadAdError': LoadAdError(
                3,
                'com.google.android.gms.ads',
                'No fill.',
                null,
              ),
            }),
          ),
          (_) {},
        );
        await tester.pump();
      }

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OptionalAdBanner())),
      );
      await tester.pump();
      expect(loads, 1);
      expect(find.text('Pilihan privasi iklan'), findsNothing);
      await noFill();
      await tester.pump(const Duration(seconds: 29));
      expect(loads, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(loads, 2);
      await noFill();
      await tester.pump(const Duration(seconds: 59));
      expect(loads, 2);
      await tester.pump(const Duration(seconds: 1));
      expect(loads, 3);
      await noFill();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 120));
      expect(loads, 3);
    });
  }, skip: !liveAdsEnabled);
}
