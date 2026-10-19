# Architecture and data invariants

`lib/domain`: immutable sale/product snapshots and exact integer Rupiah arithmetic. Rates are basis points. Fees round half up once per transaction, after seller discount. Line costs are captured at sale time so changes to product cost do not rewrite history. Packaging and per-unit additional costs are separate from COGS. Expenses are subtracted once in dashboard period totals.

`lib/data`: Drift SQLite database, private application-support directory. Version 1 uses separate product, sale, sale-item relationship, expense, stock-movement, and settings tables. Immutable snapshots are JSON payloads; sale-item and movement relationships additionally use SQL foreign keys, with foreign-key enforcement enabled on every open. Future schema changes must ship tested migrations; no released upgrade path exists yet. No mutable revenue/profit totals are stored.

Inventory uses product stock plus an append-only stock ledger. Changes and ledger entries commit inside SQLite transactions. Backup validation reconciles ledger totals with stock. Negative inventory is rejected. Sale edits reverse the old stock effect before applying the new quantities in one transaction. A failure rolls back reversals and new effects. Voids are idempotent. Partial returns are represented by editing quantities; full cancellation restores quantities. Damaged/unresellable returns require an explicit negative correction with reason after cancellation.

Product archive retains history and prevents new sales. Editing a sale uses its original cost snapshot. Adjustments require reasons. Initial stock and form edits create ledger records. Hard product deletion is intentionally unavailable when historical relationships exist.

`lib/features`: Material 3 screens, Riverpod change notifications, Indonesian integer amount input and formatting, adaptive wrapping and scrollable forms. UI delegates financial arithmetic to the domain layer and persistence to Store. Dashboard local date intervals are half open and exclude voids. Weekly/monthly windows are rolling 7/30 local calendar days.

Backups are versioned JSON, validated in memory before any write; size is limited to 20 MB. Restore occurs in a database transaction. UI additionally writes a recovery snapshot into application support before restore. Export JSON to an external location before uninstall; internal recovery files are lost on uninstall. CSV quotes every field, doubles quotes, includes UTF-8 BOM and CRLF row boundaries. Exported cells are data; spreadsheet users should import text fields as text rather than evaluate untrusted formulas.

Ads are disabled by default, and mock states have deterministic success/failure tests. The live SDK adapter is isolated but production rewarded placements and consent are blocked pending implementation and device validation. No SDK initialization occurs in normal app startup. Development manifest uses Google's sample application ID, never a production ID.

Supported baseline: Android API 24+, Java 17; pinned Flutter SDK and dependencies in CI. Release signing uses an externally supplied keystore and environment values. Release build never falls back to debug signing. APK debug and signed AAB are distinct artifacts.
