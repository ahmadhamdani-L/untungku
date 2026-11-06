# Implementation evidence

## Audit baseline

3 November 2026: read actual Flutter/Android/Drift/Store/models/screens/ads/backup/release configuration and full supplied specification. Baseline analyzer exit 0, 44 unit/widget tests pass, 4 SDK-consent cases intentionally skipped offline. Preserved dirty baseline in ignored build/v2-baseline source zip and binary diff. No v2 business code or migrations implemented at this checkpoint.

Subsequent milestones append concise decisions, changed files and executed validation here; PROGRESS.md remains the compact resume pointer. No unexecuted feature is marked complete.


### FND-002 evidence — 2026-11-04

Cash posting serializes its existing-ID comparison and insert in one SQLite transaction (nested under business transactions where applicable). Exact retries preserve the original row even after account archival; conflicting payloads fail. Checkout no-op retries also persist their operation key. Expense reversal includes only expense and compensation categories, preserving other movements sharing the business reference.

`test/financial_ledger_test.dart` uses temporary file databases, SQLite abort triggers, and reopening to prove rollback of business records, stock, cash and operation markers at intermediate failure points. Covers transfer, checkout, receivable collection, supplier payment and expense revision, plus durable retry/conflict behavior and concurrent duplicate direct posting. Combined ledger/foundation/receivables/returns checks: 26 passed; analyzer clean. These checks validate the foundation; later cashflow/reporting, inventory and release acceptance remain separate tasks.


### Foundation completion — 2026-11-04

FND-003: stock audit payloads now include optional structured business reference/operation ID. Adjustments accept an operation key retained by the stock dialog. Existing payloads remain readable. File-backed tests inject second-item failures for receipts/opname/returns, reopen, retry and reconcile stock against movement sums without changing historical sale bytes.

FND-004: shared plain-integer parsing and IntegerField reject decimals, separators, exponent notation, missing values and out-of-range amounts. Purchase, receiving, supplier-payment, cash and opname forms use shared validation. Contact fields provide inline required-name/length feedback. Existing domain money/date guards remain authoritative.

FND-005/006: management menu routes tested across customers, suppliers, purchases, cash, opname, receivables and settings, including returning without losing local state. Legacy cancelled-sale rejection type preserved. Full foundation regression: 72 passed, 4 live-adapter skips in offline configuration.


### Customers, purchasing, cashflow and inventory — 2026-11-04

Customer selection uses explicit IDs; manual linking records operation events while preserving original sale payloads. Tests cover CRUD/search/archive/restore, duplicate names, stale edits, invalid-customer rollback and backup balances. Supplier payables aggregate only confirmed purchases, retain unassigned supplier grouping and subtract partial payments without creating expenses. Combined validation: 27 passed.

Cashflow reads the cash ledger, separates transfer net from other inflows/outflows, uses exclusive date-range ends and supports each account, consolidated accounts and explicit unallocated history. CSV and offline PDF exports include reconciliation summaries. Daily counted cash is a comparison, not an automatic adjustment. Expense account changes use compensation; original ledger rows remain intact. Partial return UI records resellable/damaged/non-resellable condition and keeps refunds separate. Full regression at this milestone: 87 passed, 4 offline live-adapter skips. PDF dependency: [pdf](https://pub.dev/packages/pdf).

POS uses a dedicated cart/catalog and the existing SaleForm/Store checkout transaction. Manual barcode repeats aggregate quantity; transaction-level product barcode uniqueness also protects concurrent saves and malformed restores. Camera failures leave manual selection operational. [mobile_scanner](https://pub.dev/packages/mobile_scanner) uses the bundled Android model; camera is optional in the manifest. Three POS targeted checks passed, including a denied-camera adapter test. This does not establish physical camera support; POS-002 remains open pending native/hardware evidence.


## 2026-11-05 — full v2 continuation

Added native Bluetooth Classic SPP method channel with paired discovery, Android 12+ CONNECT permission, serialized 15-second bounded socket writes and clean closure; basic ESC/POS text profile never forwards user control bytes or requires image/cut support. Preferred printer/paper width and offline test/retry UI added. Physical camera/printer validation remains unavailable.

CSV UI regression exposed isolate closure capture of Riverpod/Store state (pure domain tests did not exercise this boundary). Replaced UI closures with top-level `compute` callbacks and immutable request data. Existing CSV quoting, row validation, policies, audit/atomic commit/retry implementation retained. Insight engine/dashboard retained and tests executed.

PIN and encrypted-backup implementations/parameters/recovery limits are documented in SECURITY_DESIGN.md. Native end-to-end v2 test passed (2 cases), including secure-storage persistence and unpaired printer error. Root lock screen uses an isolated nested Navigator/HeroControllerScope so text editing works above all application routes. Idle/background lock UI test passed. No PIN verifier is exported in business backups.

Measured read-path benchmark: 1,000 products, 10,000 movements, 300 customers, 100 suppliers. Host: 10,000 sales load 107 ms / insight 175 ms / RSS 232 MiB; 50,000 sales 270 ms / 662 ms / 278 MiB. Untungku_Test Android emulator: 10,000 sales 131 ms / 236 ms / 436 MiB. In-memory synthetic read fixture, not a write-posting benchmark, physical budget-phone measurement or memory guarantee. Raw logs in /tmp/untungku-performance-{host,native}.log.

UI layouts at widths 360 and 1024, text 1.3x, light/dark passed; Home labeled targets, Android touch sizes and text contrast passed. Blue Material 3 seed now follows v2 visual direction. Dashboard receipt amount now comes from the cash audit ledger instead of recomputing historical cash from return-adjusted revenue; supplier payable and local-insight links added. Optional PNG logo/phone/address/footer supported for digital outputs; printer always retains readable text fallback.

No publication, remote push, destructive reset, key rotation or production AdMob configuration change. Local signing validation uses existing external upload key. Version code remains 1.1.0+5 until unused Play version code is actually confirmed; locally signed validation artifacts are not an approved publishable v2 release.


## 2026-11-06 — final local validation

New password-confirmation widget test caught premature controller disposal during dialog exit animation. Replaced delayed manual disposal with a dedicated stateful dialog lifecycle; mismatch, acceptance and cancellation now pass. PIN setup is exercised through the actual settings form, including recovery acknowledgement, matching confirmation, timeout selection and root-gate unlock/idle/background behavior. A lock-generation regression verifies that background lock wins over in-flight verification.

Final Google sample-unit native test passed 2 cases: UMP-permitted banner load and interstitial preload with zero startup displays. Final receipt native test passed cancellation of picker/PDF share/PNG share, saving the PDF and unchanged sale/ledger. Host live-adapter tests passed 4 cases. Native legacy/scanner/v2 workflow run passed 4 cases. No production ad unit was requested by development tests. Layout matrix now includes 320/360/1024 widths, light/dark and 1.3x text (6 passed).

Local artifact verifier checks APK/AAB upload certificate/signatures, package/version agreement, SDK24/36, bounded legacy Bluetooth permissions/CONNECT/camera, optional camera/Bluetooth features, allowBackup=false, explicit production AdMob app ID and active banner/interstitial units, and absence of the integration-test plugin in release dex. Verifier reports releaseReady=false until physical camera/printer and actual unused version-code evidence exist. Final source version remains 1.1.0+5; local artifacts are validation-only, not an approved new Play release.
