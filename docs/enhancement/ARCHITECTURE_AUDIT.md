# v2 architecture audit — 3 November 2026

## Verified baseline

1.1.0+5, Flutter 3.47.7 stable, Dart 3.13.5; declared Dart SDK ^3.11.0. Java 17, Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20, Android min 24/target 36. No product flavors; Dart define profiles select ads. Package and namespace `id.untungku.untungku_pro`. Release signing references existing external credentials; no fallback to debug signing. Existing upload key available outside Git; do not print credentials. Last submitted release code 5, per local submission receipt; code 6 must be rechecked before final artifacts.

## Architecture and files

`lib/features/app.dart` imports domain/Store and owns Riverpod ChangeNotifier provider, localized formatting, theme, navigation and shared widgets; other primary screens are Dart parts. `main.dart` opens SQLite via application support. `lib/data/store.dart` supplies business repository equivalents. `lib/domain/models.dart`, money.dart, dates.dart, reporting.dart hold snapshots and deterministic calculations. Keep them operational while new modules are separated by domain/data/UI boundaries.

SQLite Drift schema 1: product_rows(id,payload); sale_rows(id,payload); sale_item_rows(sale_id,line_index,product_id); expense_rows(id,payload); movement_rows(id,product_id,payload); setting_rows(id,payload). Foreign keys are enabled. No upgrade migration currently exists. Historical sale items are JSON snapshots plus SQL product links. Baseline snapshot: test/schema/drift_schema_v1.json (must not regenerate over it).

All amounts use integer Rupiah, max 10^12, percent basis points. Sale revenue is gross less seller discount; marketplace fee rounds once half-up on revenue. Gross profit subtracts snapshotted cost; net subtracts packaging/extra, transaction fixed charges and marketplace fee. Dashboard subtracts operating expenses once. Sales recognized before credit collection; legacy cash sales have implicit full payment, credit sales contain dated payment records. No cash accounts/ledger or supplier purchasing exist. No exact historical account allocation can be inferred.

Product stock and append-only movement deltas are updated in DB transactions. Sale edit first reverses old quantities then posts new; void is idempotent and restores once. Negative stock requires explicit settings and cannot be disabled while stock remains negative. Product changes check stale updated timestamp. Existing full cancellation preserves payment history; refunds are outside the old app.

Backups: JSON payload versions 1/2 with all existing arrays/settings, source length cap 20M chars, in-memory references/dates/payment/stock reconciliation validation, atomic replacement. UI creates recovery file. CSV includes BOM, quoting, CRLF, formula-prefix defense. No encryption or PIN currently.

Ads: google_mobile_ads 9.1.0; existing owner profile unchanged. UMP before initialization/requests, persistent banner above navigation, preloaded completion interstitials after successful new sales/expenses/payments; three successes, two-minute grace, three-minute interval, five/session. Default dev offline/mock, sample IDs for SDK tests. Rewarded adapter has no product placement. Production permissions: Internet; AD_ID explicitly removed; Android backup disabled. Camera/Bluetooth permissions and adapters absent.

## Executed baseline checks

- `flutter analyze --no-pub`: exit 0, clean (3.2 seconds).
- `flutter test --no-pub`: exit 0, 44 passed, 4 consent cases skipped under offline defaults (4 seconds).
- Logs: /tmp/untungku-v2-baseline-analyze.log and /tmp/untungku-v2-baseline-tests.log.
- Existing tests: money/reporting/store/persistence/privacy/widgets/receivables/ads; device business, Google test ads and listing captures. Prior device results do not substitute for v2 testing.

## Risks and approach

Dirty baseline contains previous authorized v1.1 work plus screenshots/docs; preserved in build/v2-baseline and not reset. Existing Store loads entire database; large-volume performance needs measured indexing/pagination, not invented claims. JSON schema additions alone do not provide entity referential integrity: new typed Drift tables and explicit FK links are preferable. New schema must use additive v1→v2 migration; no SQL rewriting of old financial payloads. Customer text stays unlinked until explicitly linked. Legacy settlements must be unallocated, clearly distinguished from known cash. Returns must allocate discounts/fees deterministically and preserve original sale snapshots. Purchase WAC must handle negative-stock policy explicitly. Old sale-edit/cancel pathways need safe guards once dependent return/cash records exist.

Exact likely change files: lib/data/database.dart, generated database.g.dart, store.dart; lib/domain/models.dart and money.dart; lib/features/app.dart, products.dart, transactions.dart, receivables.dart, settings.dart, dashboard.dart; lib/main.dart; AndroidManifest.xml and MainActivity.kt (printer bridge if required); pubspec.yaml/lock; tool/validate_release.py. New modular domain/data/UI files under customers, suppliers/purchasing, cashflow/reports, stock_opname/returns, barcode/sales, receipts, csv_import, business_insights, core/security/backup. Regression tests and synthetic migration fixtures required for each boundary.
