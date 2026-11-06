# UntungKu Pro 1.1.0 (build 5)

Prepared on 3 November 2026. The public privacy page was updated on 3 November 2026 (website commit 77df8e9). Production submission status and exact bundle hash are recorded in play-release-1.1.0.json.

## Product changes

- Neutral surfaces, consistent buttons and inputs, smaller header, and quick sale/expense actions.
- Revenue chart, global outstanding receivables, and period-specific sales receipts. Receipts include payments against older credit sales and do not count them as new revenue.
- Product identity, pricing, and stock sections; stock badges; optional calculator and transaction charges collapsed into expandable sections.
- Full sale detail page, credit customer, optional due date, initial payment, installment history, active/overdue/settled filters.
- Backup format 2 and extra CSV columns for customer, status, paid amount, outstanding amount, due date, and payment history. Restore accepts format 1 and 2.

## Production data compatibility

SQLite schema stays at version 1: sale payloads already store JSON, and the new fields are additive. Old records without these fields stay fully paid. No database deletion, reset, or destructive SQL migration is introduced. The restart test opens a real existing schema-1 database containing a legacy payload before writing and reopening new credit-sale records.

Payments are written atomically using a stable payment ID. Retrying the same payment is idempotent, overpayment is rejected, and a stale sale edit cannot overwrite a newer settlement. Installments never move stock or add revenue. Cancellation retains payment history and restores stock once; any customer refund is handled separately outside the app. Customer and due-date metadata are fixed after sale creation in this release.

## Ads configuration

The existing owner profile in `config/admob-release.json` already supplies the banner and interstitial unit IDs; no new ID is required. Default development builds remain offline/mock. Only `config/google-test.json` is used for real-SDK device tests, never owner inventory.

The persistent banner remains above the bottom navigation. Completion interstitials are eligible only after successful new sales, new expenses, or receivable payments. The success confirmation is shown after persistence; pressing **Selesai** is the transition where an already-loaded interstitial may appear.

Shared limits across these placements:

- At least three completed tasks since the previous impression.
- At least two minutes since the session started.
- At least three minutes between impressions.
- At most five interstitial impressions per app session.

Missing, failed, expired, non-consented, and background ads are skipped. Loading never causes a later unsolicited display. Cache expiry is 55 minutes; retry backoff is 30–300 seconds. Privacy-option changes invalidate the cache. Edits, errors, cancellation, restore, startup, and navigation do not trigger completion ads. Rewarded, native, and app-open have no new product placement; their configured IDs do not automatically enable them.

Implementation references: https://developers.google.com/admob/flutter/interstitial and https://support.google.com/admob/answer/6201350.

## Verification

- `flutter analyze --no-pub`: clean.
- `flutter test --no-pub`: 44 passed, 4 live-SDK tests intentionally skipped under offline defaults.
- `flutter test test/ads_consent_test.dart --no-pub --dart-define=ADMOB_ENABLED=true --dart-define=ADMOB_USE_MOCK=false`: 4 passed using mocked native responses, including prepared-only completion display, consent denial, background suppression, cooldown, dismissal, and preload renewal.
- `python3 -m unittest discover -s tool -p 'test_*.py'`: 4 passed.
- Android emulator business integration: passed.
- Widgets cover creation of a credit sale through full settlement plus 320px light/dark layouts.

Google test ads on the Android emulator: both banner loading after UMP permission and interstitial preloading without startup display passed (2 tests). These use Google sample unit IDs; no owner inventory was requested. Owner live serving and physical-device coverage remain unverified. The signed production bundle and new store assets are prepared; submission status is recorded in play-release-1.1.0.json.

## Review build

Debug APK with Google sample ads: `build/review-1.1.0/UntungKu-Pro-1.1.0-test-ads.apk`. This is for a test device, not a signed production update. SHA-256: `d8f012bacf34aba1855ec173e8ccdc0e981513d67ec2bbeb0c8042d65d9943ed`. The screenshots under `build/review-1.1.0/` are captured from the running emulator and are review material, not refreshed Play Store screenshots.

## Google Play submission — 3 November 2026

Version 1.1.0 (code 5) and five listing updates were submitted together. Play Console confirms **Perubahan yang sedang ditinjau** with automatic quick checks running before review. Managed publishing is disabled for this app so the approved update publishes automatically, at 100% of the existing country targeting. No live-approval claim is made. The exact production bundle, asset counts and submission record are in [play-release-1.1.0.json](play-release-1.1.0.json).
