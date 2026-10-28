# LarisKas working context — 28 Oktober 2026

Branch `feature/lariskas-rebranding` from `main` in `ahmadhamdani-L/untungku`. User requested full transformation and approved safe AdMob placements. Preserve Android `applicationId` `id.untungku.untungku_pro`, existing upload signing key, owner AdMob publisher `pub-6953774620667597`, SQLite file `untungku.sqlite`, and versioned backup marker `untungku-pro`. Existing branch began with user edits in `pubspec.yaml` and `lib/services/ads.dart`; retain them.

CodeGraph v1.6.2 is installed locally and indexes Dart. Use `npx --yes @colbymchenry/codegraph explore 'query'`; `.codegraph/` is ignored. Flutter 3.47.7 / Dart 3.13.5. Current supported screens are onboarding, dashboard, products/stock, sales/expenses, calculator, settings, and newly added local financial/inventory reports. The rest of the master prompt remains work, not a claim of completion.

AdMob owner IDs are in `config/admob-release.json`. Google sample IDs are in `config/google-test.json`. SDK is disabled in `config/development.json`. `AdManager` handles shared initialization, inline adaptive banners, and a preloaded interstitial at explicit report exit. Native ad unit exists in config but its format is unverified; no native UI. Consent and app verification need owner AdMob Console access. Public `app-ads.txt` currently matches owner publisher.
