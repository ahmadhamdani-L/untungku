# Test report — 28 Oktober 2026

| Check | Result |
| --- | --- |
| `dart format lib test integration_test` | Completed |
| `flutter analyze --no-pub` | Passed, no issues |
| `flutter test --no-pub` | 35 unit/widget tests passed |
| `python3 -m unittest discover -s tool -p 'test_*.py'` | 5 release-guard tests passed |
| `integration_test/business_flow_test.dart`, Android 17 emulator `Untungku_Test`, Wi-Fi and mobile data disabled | 1 passed: product, sale, stock, expense, backup/restore |
| `integration_test/google_ads_test.dart`, Android 17 emulator, `config/google-test.json` | 1 passed: UMP and Google sample inline adaptive banner |
| `bundletool 1.18.3 validate`, AAB | Passed |
| `jarsigner -verify`, AAB | Passed |
| `apksigner verify --verbose`, APK | Passed, v2 signature |

Five actual 1080×1920 emulator captures are stored under `docs/store-screenshots/` with `lariskas` in their names.

Ad placement widget test verifies that the home screen has no `BottomSheet`, the local reports screen opens and changes to inventory, and report exit returns to home. Frequency-cap unit test covers cooldown, three displays per day, restore, and next-day reset. No production ad was requested in tests.

Limitations: live owner ad serving, native-unit format, EEA consent screen, account restrictions, Play processing, migration from an installed prior version, and broad device-layout coverage have not been verified. The full master-prompt feature set is not yet implemented.
