# LarisKas development release report — 28 Oktober 2026

- App: **LarisKas**, Android `id.untungku.untungku_pro`, `1.0.1` (versionCode 3).
- Repository: `https://github.com/ahmadhamdani-L/untungku`, branch `feature/lariskas-rebranding`.
- Completed this iteration: blue brand/icon/splash; bundled privacy and listing copy; local financial and inventory summary report; in-flow adaptive banners on dashboard, products, reports, and settings; stock/product save confirmations; shared AdManager; ten-minute and three-per-day persisted interstitial cap on explicit report exit; production unit guard in nonrelease builds.
- Offline/data: existing SQLite schema v1, file path, Android package, and backup format marker are unchanged. No database migration was required for these changes. An installed old-version upgrade test has not been executed.
- CodeGraph: v1.6.2 installed locally; Dart indexed (46 files, 742 nodes, 1,710 edges at last status). Shell query works; MCP requires agent restart and project trust to be verified.
- Tests: analyzer clean; 35 Flutter tests, 5 Python tests, 1 offline Android workflow, and 1 Google sample inline banner test passed. See `TEST_REPORT.md`.
- Signed AAB: `build/app/outputs/bundle/release/app-release.aab`, SHA-256 `bb2644d0035f1827078966728e6a5b15884fdc295125b2a72eaa60524f069550`; bundletool and jarsigner passed.
- Signed APK: `build/app/outputs/flutter-apk/app-release.apk`, SHA-256 `0e555e42bdde911c1f88c2100aa63eec862d84dade519fb400379a746545fb15`; APK Signature Scheme v2 verified.
- Upload certificate SHA-256: `54BC4EE0815329CD03067FD65B069B1E496D244ACE5AFA213E5D42F51CBA5C33`, matching the prior release report.
- AdMob: owner App ID and units preserved; public `app-ads.txt` returns publisher `pub-6953774620667597`. AdMob Console status, app verification, unit type, and serving restrictions remain unverified. Native/rewarded/app-open UI is inactive.
- Play: current public listing still says UntungKu Pro, and its linked privacy page still says UntungKu Pro. No Play service account or connected Play Console capability was found. Internal Testing upload is not claimed.
- Production readiness: **not ready**. Remaining modules in the master prompt, migration testing, final populated screenshots, public privacy/listing update, AdMob Console review, and Play testing upload are outstanding.
