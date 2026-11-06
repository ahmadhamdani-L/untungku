# MASTER PROMPT — UNTUNGKU PRO v2.0.0
## FULL ENHANCEMENT IMPLEMENTATION — PRODUCTION READY

You are an autonomous senior Flutter engineer, Android engineer, software architect, database engineer, QA automation engineer, UI/UX designer, and release engineer.

Your mission is to upgrade the EXISTING UntungKu Pro Android application from v1.1.0 (versionCode 5) into a significantly more capable, professional, production-ready offline-first UMKM business management application.

**THIS IS AN IMPLEMENTATION TASK, NOT A PLANNING-ONLY TASK.**

You must inspect the existing repository, understand its architecture, implement all requested functionality, write migrations, maintain backward compatibility, run tests, fix errors, and produce a verified Android release candidate.

Do not stop after creating documentation, mockups, placeholder screens, or a partially working MVP.

You have permission to create and modify application files, install necessary project dependencies, create local branches, run tests, and perform local builds.

Do not publish to Google Play, push to remote repositories, expose credentials, delete user data, or perform destructive operations without explicit authorization.

## 1. NON-NEGOTIABLE RULES

1. Work inside the existing UntungKu Pro repository.
2. Do not create a new application project.
3. Preserve the existing Android applicationId and package identity.
4. Preserve the existing signing configuration and signing identity.
5. Preserve the existing AdMob App ID, publisher identity, and production ad units.
6. Never replace production AdMob credentials with invented values.
7. Never enable production advertisements in development or automated tests.
8. Preserve every existing business feature.
9. Preserve all user data during application upgrades.
10. Preserve existing backup compatibility for format versions 1 and 2.
11. Keep all core business functionality operational without internet.
12. Do not introduce mandatory registration, login, cloud, or backend servers.
13. Do not replace the existing database unless technically essential and migration safety is demonstrated.
14. Never silently reset, drop, or overwrite production user data.
15. Never silently modify historical financial transactions.
16. Use transactional database operations for critical financial and inventory changes.
17. Follow the established repository architecture where feasible.
18. Avoid unnecessary dependencies and large architectural rewrites.
19. Provide complete implementation, not pseudocode.
20. Do not introduce fake data into production workflows.
21. Never claim a test or build passed without actually executing it.
22. Never mark functionality complete if only its interface exists.
23. Do not introduce paid APIs or mandatory external infrastructure.
24. Design all screens for Indonesian users.
25. Optimize for affordable Android devices.
26. Ensure that ads never block critical business operations.
27. Do not delete existing features to simplify implementation.
28. Treat security, data consistency, and data preservation as release blockers.

## 2. EXISTING APPLICATION BASELINE

Application: UntungKu Pro
Platform: Android
Framework: Flutter, subject to repository verification
Current version: 1.1.0
Current versionCode: 5
Primary language: Indonesian
Developer: Lelouch D — PT DDD DREAM DEVELOP DIGITAL

The application already includes:

- Business dashboard
- Revenue and profit estimates
- Product catalog and SKU
- Product categories
- Product cost and selling price
- Inventory management
- Stock adjustments and stock movement history
- Sales with multiple items
- Discounts and marketplace fees
- Cash, bank transfer, QRIS, and other recorded payment methods
- Credit sales and customer receivables
- Partial customer payments
- Sales cancellation and inventory reversal
- Expense tracking
- Transaction history
- Profit calculator
- JSON backup and restore
- CSV transaction export
- Light and dark themes
- Business settings
- Google AdMob banner and interstitial
- Google UMP consent handling
- Offline local storage

Existing business logic must remain operational.

Current AdMob behavior includes:

- Banner positioned above main navigation.
- Interstitial at eligible completed business-operation boundaries.
- Three successful records minimum before eligibility.
- Two-minute initial session grace period.
- Three-minute interval between interstitials.
- Maximum five interstitial impressions per session.
- Graceful fallback when advertisements are unavailable.
- Consent checks before eligible ad requests.

Preserve existing safeguards unless a change is required to comply with current policies.

## 3. REPOSITORY AUDIT — REQUIRED FIRST STEP

Before implementing anything:

Inspect:

- pubspec.yaml
- Flutter and Dart versions
- Android Gradle configuration
- applicationId
- package namespace
- build flavors
- signing configuration
- existing database technology
- database schema and migrations
- repositories
- domain models
- navigation
- state management
- services
- existing tests
- AdMob implementation
- Google UMP integration
- backup and restore implementation
- application permissions
- Android minSdk and targetSdk
- existing release scripts

Do not assume the project uses a particular database or state-management library.

Produce:

docs/enhancement/ARCHITECTURE_AUDIT.md

Include:

- Current architecture.
- Existing database schema.
- Existing financial calculations.
- Existing stock movement behavior.
- Existing backup formats.
- Existing AdMob configuration.
- Existing tests and baseline results.
- Identified risks.
- Recommended implementation approach.
- Exact files likely to require changes.

If the repository contains uncommitted changes, preserve them. Do not overwrite unrelated work.

Run existing analyzer and tests before modifications and record actual results.

## 4. TARGET ARCHITECTURE

Prefer the current architecture rather than forcing a rewrite.

Use modular feature boundaries:

lib/
  core/
    database/
    security/
    backup/
    services/
    errors/
    utils/
    widgets/
  features/
    dashboard/
    products/
    inventory/
    sales/
    receivables/
    expenses/
    customers/
    suppliers/
    purchasing/
    stock_opname/
    returns/
    receipts/
    barcode/
    cashflow/
    reports/
    csv_import/
    business_insights/
    settings/

This structure is a reference, not permission to move all existing files unnecessarily.

Each new module should separate:

- Presentation
- Business/domain logic
- Data access
- Persistent models
- Validation
- Tests

Use repositories or existing equivalent abstractions.

Avoid tight coupling between UI widgets and SQL/database implementation.

Important invariant:

The same business transaction must not independently update sales, inventory, receivables, and cash balances without an atomic transaction boundary.

Use unique operation identifiers to prevent duplicate posting.

## 5. FEATURE A — DIGITAL RECEIPTS AND BLUETOOTH PRINTING

Implement fully functional digital sales receipts.

### Receipt contents

- Business name
- Optional business address
- Optional business phone
- Optional business logo
- Receipt number
- Transaction date and time
- Customer name when available
- Product details
- Quantity
- Unit price
- Line subtotal
- Discount
- Transaction fees when relevant
- Grand total
- Recorded payment method
- Amount received
- Remaining receivable when applicable
- Optional footer message

### Supported outputs

1. Receipt preview in-app.
2. PDF receipt export.
3. Share PDF through Android share sheet.
4. Share receipt image through Android share sheet.
5. Bluetooth thermal printer output.

### Bluetooth printer requirements

- Support common ESC/POS-compatible thermal printers.
- Support 58 mm and 80 mm receipt layouts.
- Offer configurable paper width.
- Support paired-device discovery.
- Handle Android Bluetooth runtime permissions correctly.
- Display printer connection status.
- Save preferred printer locally.
- Provide a printer test page.
- Support printing without internet.
- Support retry after printer failure.
- Prevent accidental duplicate sales when printing is retried.

Do not assume every Bluetooth printer supports the same ESC/POS commands.

Handle unsupported printers gracefully.

Use Indonesian currency formatting and proper alignment.

Provide readable text output even when a printer does not support images or logos.

Receipt generation must not change sales or inventory records.

### Acceptance criteria

- Receipt PDF works offline.
- Android share sheet works.
- Receipt totals match saved transaction totals.
- Bluetooth printing supports tested printer protocols.
- Printer failure does not invalidate a sale.
- Printing the same receipt twice does not create another transaction.
- Receipt from historical sales remains consistent with saved transaction snapshots.

## 6. FEATURE B — BARCODE AND FAST CASHIER

Implement an optimized POS checkout workflow.

### Barcode capabilities

- Scan product barcode using smartphone camera.
- Support common retail barcode formats, including EAN-13, EAN-8, UPC-A, and Code 128 where supported by the selected scanning library.
- Associate barcode with product records.
- Detect duplicate barcode assignments.
- Provide manual barcode input.
- Support products without barcode.
- Display a clear message when a barcode is not registered.
- Allow users to select an existing product or register a new product.
- Operate offline after application installation and local dependencies are available.

### Fast cashier interface

Create a dedicated cashier screen optimized for minimal interaction:

- Product search
- Barcode scan button
- Product favorites
- Product categories
- Fast add-to-cart
- Quantity adjustment
- Item removal
- Subtotal
- Discounts
- Transaction fees
- Payment selection
- Optional customer selection
- Partial payment
- Outstanding receivable
- Checkout confirmation
- Receipt preview after successful save

Support repeated barcode scanning of the same product by increasing the quantity.

Validate inventory using existing negative-stock settings.

Do not silently bypass current stock rules.

### Important transaction rules

- The same checkout operation must not produce duplicate sales.
- Stock deduction must occur exactly once.
- Failed transactions must roll back.
- Financial totals must be calculated by domain logic, not duplicated in UI.
- Product pricing at transaction time must be snapshotted.
- Existing sales workflow must remain available.

### Acceptance criteria

- Scan to cart works offline.
- Products can be sold without barcode.
- Duplicate checkout requests do not duplicate sales.
- Existing stock validation works.
- Checkout remains functional if camera permissions are denied.

## 7. FEATURE C — CUSTOMER DATABASE

Replace free-text-only customer relationships with reusable customer entities while preserving legacy data.

### Customer information

- Unique customer ID
- Name
- Optional phone number
- Optional address
- Optional notes
- Creation date
- Updated date
- Active or archived status

### Customer management

- Add customer
- Edit customer
- Search customer
- Archive customer
- Restore archived customer
- Select customer when creating a sale
- View customer transaction history
- View outstanding receivables
- View payment history
- View total recorded purchases
- View overdue balances

Add a customer detail dashboard.

### Legacy migration

Existing sales may contain customer names without customer IDs.

Implement a safe migration strategy.

Never automatically merge different people solely because they have the same name.

Preserve historical customer-name snapshots.

Where identity is ambiguous, leave legacy sales unlinked and provide an optional manual linking workflow.

Customers must not be deleted in ways that break historical transactions.

### Acceptance criteria

- Existing receivables remain readable.
- All historical balances remain unchanged.
- Customer records survive backup and restore.
- Sales can still be recorded without selecting a customer, except where existing credit-sale rules require identification.

## 8. FEATURE D — SUPPLIERS AND PURCHASING

Implement supplier management and inventory purchasing.

### Supplier data

- Supplier ID
- Supplier name
- Phone
- Address
- Notes
- Active status
- Creation date

### Purchasing

Create purchase records containing:

- Purchase number
- Supplier
- Purchase date
- Product list
- Quantity
- Unit purchase cost
- Discounts
- Additional purchasing costs
- Total
- Amount paid
- Outstanding payable
- Payment method
- Notes
- Purchase status

### Supported workflows

- Create purchase draft
- Confirm purchase
- Receive inventory
- Record supplier payments
- View purchase history
- View purchase details
- View supplier payables
- Record partial supplier payments
- Cancel eligible purchase records using reversal entries
- Track received quantities
- Avoid receiving inventory twice

### Cost accounting

The current system snapshots product cost during sales.

Preserve historical cost snapshots.

Define a consistent inventory valuation policy and document it.

For the first enhancement, prefer an explicit weighted-average-cost approach where compatible with existing assumptions.

If existing cost accounting uses another established method, assess compatibility before changing it.

Do not retroactively recalculate historical sales profits.

Purchase expenses used for inventory acquisition must not automatically be counted a second time as operating expenses.

Supplier debt settlement must be represented separately from the acquisition of inventory.

### Acceptance criteria

- Confirmed stock receipt increases inventory exactly once.
- Supplier payment reduces outstanding payable.
- Duplicate purchase confirmations do not duplicate inventory.
- Purchase reversal preserves audit history.
- Cost calculations are deterministic.

## 9. FEATURE E — STOCK OPNAME AND SALES RETURNS

### Stock opname

Provide an inventory-counting workflow.

Features:

- Create stock opname session
- Select products
- Display current recorded stock
- Enter physically counted quantity
- Calculate stock differences
- Enter adjustment reason
- Review differences
- Confirm adjustments
- Preserve complete audit history

Do not update stock before confirmation.

After confirmation, create corresponding inventory movement records.

Handle concurrent or intervening stock changes using version checks, locks, or another safe mechanism.

### Sales returns

Implement:

- Full return
- Partial return
- Return quantity validation
- Return reason
- Return date
- Refund amount
- Refund method
- Return history
- Return receipt or confirmation

### Inventory behavior

Returned merchandise can be:

- Restocked
- Marked damaged
- Marked non-resellable

Only restock when appropriate.

Prevent returning more units than the net quantity sold.

### Financial behavior

A return must correctly reverse the relevant net revenue, cost of goods sold, and receivable where appropriate.

Cash refunds must reduce cash balance.

Returns without immediate cash refunds must record refund liability or an explicitly defined pending settlement.

Account for already received partial payments.

Keep return records distinct from deletion or cancellation of original sales.

Never delete original transactions.

### Acceptance criteria

- Stock movements are auditable.
- Partial returns cannot exceed remaining eligible quantities.
- Refunds cannot be recorded twice.
- Financial reports reflect returns accurately.
- Returned damaged goods do not increase sellable inventory.

## 10. FEATURE F — CASH FLOW AND FINANCIAL REPORTS

This feature must correct a critical conceptual distinction:

**Revenue, profit, receivables, inventory purchases, and cash receipts are not the same thing.**

Implement a dedicated cash movement ledger.

### Cash accounts

Support local business cash accounts such as:

- Cash
- Bank transfer account
- QRIS settlement account
- Other configured account types

These are recording accounts only.

The app must not claim to perform actual bank transfers, payment settlement, or live QRIS processing.

### Cash movement categories

- Customer payment receipt
- Receivable collection
- Supplier payment
- Operational expense payment
- Customer refund
- Owner capital contribution
- Owner withdrawal
- Transfer between local cash accounts
- Manual opening balance adjustment

### Ledger rules

- Every cash movement has a stable reference.
- Operations must be idempotent.
- Transfers between accounts must not inflate total cash.
- Owner capital contributions are not sales revenue.
- Owner withdrawals are not operating expenses.
- Receiving payment against an old receivable is not new revenue.
- Purchasing inventory changes asset composition; it must not be double-counted in operating profit.
- Credit sales may contribute recognized revenue before cash is collected, according to the existing sales recognition approach.

### Reports

Build:

1. Sales report
2. Profit estimate report
3. Expense report
4. Cash flow report
5. Receivables aging report
6. Supplier payables report
7. Inventory valuation report
8. Top-selling products report
9. Product profitability report
10. Daily store-closing report

### Filters

- Today
- Yesterday
- Last 7 days
- Last 30 days
- This month
- Custom range

### Export

Support CSV and PDF exports for relevant reports.

Keep reports available offline.

### Legacy financial migration

Existing historical sales and payments may have incomplete settlement-account metadata.

Do not invent bank account allocations for historical transactions.

Use an explicit legacy/unallocated state where necessary.

Document the distinction between known, derived, and unknown historical cash balances.

Do not manufacture exact cash balances from insufficient historical information.

### Acceptance criteria

- Sale on credit does not create fictitious cash.
- Payment of existing receivable creates cash movement without new sales revenue.
- Customer refund reduces cash where applicable.
- Supplier payment reduces cash and payable.
- Transfers do not change consolidated total cash.
- Reports reconcile with underlying records.

## 11. FEATURE G — CSV PRODUCT IMPORT

Implement a safe offline bulk-import workflow.

### Input support

- CSV UTF-8
- Standard CSV quoting rules
- Escaped quotation marks
- Commas inside quoted fields
- Indonesian number formatting where unambiguous
- Optional UTF-8 BOM

### Import columns

- Product name
- SKU
- Barcode
- Category
- Cost
- Selling price
- Packaging cost
- Additional unit cost
- Initial stock
- Low-stock threshold

### Import experience

1. Download or create CSV template.
2. Select local CSV file.
3. Detect and preview columns.
4. Map CSV columns to application fields.
5. Validate rows.
6. Show valid and invalid row counts.
7. Display detailed validation errors.
8. Let user choose duplicate-handling policy.
9. Preview final changes.
10. Confirm import.
11. Execute import safely.
12. Show summary and error report.

### Duplicate policies

- Skip duplicate
- Update existing matching product
- Create only new products

Never identify products solely by display name when uniqueness is not guaranteed.

When updating existing products, do not silently overwrite historical transaction values.

### Large file handling

Use efficient parsing and batched database operations where appropriate.

Avoid blocking the Flutter UI.

### Acceptance criteria

- Invalid rows are reported clearly.
- Import does not corrupt existing inventory.
- Duplicate barcode and SKU rules are enforced.
- Imported data survives restart and backup.
- Cancellation before commit does not create partial unexpected changes.

## 12. FEATURE H — OFFLINE SMART BUSINESS ASSISTANT

Create a local rule-based business intelligence system.

No cloud AI API.

No mandatory internet connection.

No external inference subscription.

The feature should be marketed and implemented as intelligent local business insights, not as an online generative AI service.

### Insight types

1. Revenue growth or decline.
2. Low-stock alerts.
3. Stock depletion estimates.
4. Slow-moving products.
5. Best-selling products.
6. High-revenue but low-margin products.
7. Overdue customer receivables.
8. Unusual expense increases.
9. Negative or declining estimated profit.
10. Products needing restocking.

### Example output

"Pendapatan 7 hari terakhir turun 12% dibandingkan 7 hari sebelumnya."

"Stok Kopi Susu diperkirakan habis dalam 4 hari berdasarkan rata-rata penjualan terbaru."

"Produk A memiliki penjualan tinggi tetapi margin keuntungan relatif rendah."

"Anda memiliki 3 tagihan pelanggan yang telah melewati jatuh tempo."

### Calculation principles

- Use deterministic formulas.
- Display calculation periods.
- Display relevant values.
- Avoid false precision.
- Do not extrapolate from insufficient data.
- Explain why an insight was generated.
- Allow users to open the relevant underlying report.
- Avoid claiming causation when only correlation exists.
- Avoid unnecessary alerts.

### Stock depletion

Use recent valid sales velocity with configurable windows.

Handle:

- Products without sufficient sales
- New products
- Seasonal variations
- Zero stock
- Negative stock
- Returns
- Sales cancellations

Do not produce unreliable predictions as guaranteed outcomes.

### Insight dashboard

- Summary cards
- Severity levels
- Actionable recommendations
- Dismiss or snooze controls
- Relevant links to business modules

### Acceptance criteria

- All calculations work offline.
- Deterministic tests cover insight rules.
- Empty datasets do not generate misleading warnings.
- Performance remains acceptable on affordable Android phones.

## 13. FEATURE I — PIN SECURITY AND ENCRYPTED BACKUP

### Application PIN

Implement optional application PIN protection.

Requirements:

- 4–6 digit PIN
- First-time setup
- PIN confirmation
- Unlock screen
- Change PIN
- Disable PIN after verification
- Automatic lock after configurable inactivity
- Secure handling of failed attempts
- No plaintext PIN storage
- No PIN exposure through logs
- No hardcoded recovery PIN

Store PIN verification material securely using suitable password-based derivation and secure storage.

Use appropriate secure randomness, salts, and constant-time verification where feasible.

Do not implement reversible PIN encryption.

Do not silently erase business data when PIN attempts fail.

### Recovery policy

Design and clearly document a safe recovery mechanism before enabling PIN protection.

If local PIN recovery is impossible without destroying protected data, inform the user clearly during setup.

Do not introduce secret developer bypasses or weak security questions.

### Encrypted backup

Extend current JSON backup functionality.

Requirements:

- Password-protected export
- Password confirmation
- Authenticated encryption
- Unique salt per backup
- Unique nonce per encryption operation
- Strong password-based key derivation
- Versioned envelope format
- Integrity verification
- Clear wrong-password/error behavior
- Restore preview
- Confirmation before replacement
- Temporary-file cleanup
- No password logging

Use reviewed, maintained cryptographic libraries.

Prefer an established authenticated cipher such as AES-256-GCM with appropriate key derivation.

Use Argon2id where compatible and practical; alternatively use a suitably configured PBKDF2 implementation with documented parameters.

Do not invent custom cryptographic algorithms.

### Backup compatibility

Continue to support:

- Existing backup format v1
- Existing backup format v2

Create a newer versioned backup format to support additional entities.

Differentiate backup payload schema version from encrypted envelope version.

Support appropriate unencrypted legacy backup imports.

Never confuse an encrypted backup with a corrupt JSON backup.

### Restore safeguards

- Validate before replacing data.
- Verify encryption authentication before parsing records.
- Check reference integrity.
- Check schema compatibility.
- Show affected record counts.
- Create an internal recovery snapshot where feasible.
- Restore atomically.
- Roll back on failure.
- Prevent partially restored database states.

### Acceptance criteria

- Correct password restores backup.
- Incorrect password does not alter current data.
- Tampered encrypted backup is rejected.
- Interrupted restore preserves database consistency.
- Legacy backup formats remain importable.
- New backup contains all new business entities.

## 14. DATABASE DESIGN AND MIGRATION

Create a migration plan based on the actual existing schema.

Potential new entities include:

- customers
- suppliers
- purchases
- purchase_items
- purchase_payments
- inventory_receipts
- stock_opname_sessions
- stock_opname_items
- sales_returns
- sales_return_items
- refund_records
- cash_accounts
- cash_movements
- product_barcodes
- receipt_settings
- printer_preferences
- business_insights
- insight_dismissals
- security_settings

These names are suggestions, not mandatory replacements for existing entities.

### Migration requirements

- Preserve all existing products.
- Preserve historical sales.
- Preserve cost snapshots.
- Preserve expenses.
- Preserve inventory history.
- Preserve outstanding receivables.
- Preserve payment histories.
- Preserve current settings.
- Preserve AdMob configuration.
- Preserve negative-stock behavior.

Create explicit schema migration versions.

Never implement migrations by blindly recreating existing tables.

Test migration from a representative v1.1.0 database.

### Historical-data requirements

Create fixtures for:

- Fully paid sale
- Partial payment
- Unpaid credit sale
- Canceled sale
- Sale containing multiple products
- Sales with discounts
- Sales with marketplace fees
- Negative-stock product
- Archived product
- Existing inventory adjustment
- Existing customer text name
- Legacy backup v1
- Legacy backup v2

Use sanitized or synthetic fixtures; do not commit real customer data or production secrets.

### Database invariants

- Referential integrity remains valid.
- Monetary values use a consistent, safe numeric representation.
- Avoid floating-point inaccuracies for money.
- Every stock-changing event has an audit reference.
- Every cash-changing event has an audit reference.
- Critical writes are transactional.
- Repeated operations with the same idempotency key do not double-post.
- Historical audit events are not silently deleted.
- Reconciliation queries produce consistent totals.

Prefer integer minor units or an explicitly documented decimal strategy, compatible with existing data.

## 15. UI/UX REDESIGN

The application should look modern, professional, polished, and appropriate for Indonesian small-business users.

### Visual direction

- Modern Android design
- Clean typography
- Professional blue-centric theme
- Clear financial information
- Spacious but efficient layouts
- Consistent cards and form fields
- Light mode
- Dark mode
- Responsive layouts
- Readable on budget devices
- No unnecessary heavy animations

### Navigation

Organize the new feature set without creating an overloaded bottom navigation.

Suggested primary navigation:

1. Beranda
2. Kasir
3. Produk
4. Transaksi
5. Lainnya

Additional management modules can be reached from grouped menus.

Do not hide frequent operations behind excessive navigation.

### Dashboard

Display:

- Revenue
- Estimated profit
- Cash received
- Outstanding receivables
- Supplier payables
- Low stock
- Sales trend
- Actionable business insights

Do not overload the first screen with excessive financial cards.

### Design consistency

Create or extend reusable components for:

- Metric cards
- Empty states
- Error states
- Loading states
- Confirmation dialogs
- Search and filter
- Currency input
- Date selection
- Transaction status badges
- Primary buttons
- Destructive actions
- Form validation

All visible text should use natural Indonesian.

Do not mix English labels into user-facing screens without a clear reason.

## 16. ADMOB PRESERVATION AND SAFETY

Preserve the current AdMob integration.

Important:

- Preserve existing application ID.
- Preserve publisher ID.
- Preserve production ad-unit identity.
- Preserve Google UMP.
- Preserve existing consent flow.
- Keep test ads in development builds.
- Keep production ads for appropriately configured release builds.
- Do not display advertisements during critical payment and inventory operations.
- Do not position banners over actionable controls.
- Do not allow banner overlays to obstruct navigation.
- Never block business operations while loading an ad.
- Respect frequency caps and cooldowns.
- Review placements against current Google Play and AdMob policies before release.

Suggested eligible interstitial boundaries:

- Successful new sale completion
- Successful expense recording
- Successful receivable collection

Do not add an interstitial after every interaction.

No forced rewarded advertisement to unlock essential bookkeeping features.

Ensure that all features work when ads fail or network is unavailable.

Create or update automated release guards preventing accidental production ad-unit use in development/test configurations.

## 17. TESTING STRATEGY

Testing is mandatory.

### Unit tests

Cover:

- Sales calculations
- Purchase calculations
- Weighted average cost or selected valuation logic
- Receivable calculations
- Supplier payable calculations
- Stock movements
- Stock opname differences
- Sales returns
- Refund calculations
- Cash ledger calculations
- Profit and margin calculations
- Barcode duplicate validation
- CSV validation
- Business insight rules
- PIN validation
- Backup encryption/decryption

### Database tests

Cover:

- Fresh installation
- Upgrade from v1.1.0
- Existing receivables after migration
- Existing negative stock
- Existing archived products
- Historical canceled sales
- Duplicate transaction prevention
- Transaction rollback
- Reference integrity
- Legacy backup restoration
- New backup restoration

### Widget tests

Cover:

- Fast cashier
- Customer management
- Supplier management
- Purchasing
- Stock opname
- Sales returns
- Cashflow dashboard
- CSV import preview
- Receipt preview
- PIN setup and unlock

### Integration tests

Cover end-to-end:

1. Add product.
2. Add supplier.
3. Purchase inventory.
4. Receive purchased inventory.
5. Scan barcode.
6. Add product to cart.
7. Select customer.
8. Complete partial-payment sale.
9. Verify stock deduction.
10. Verify outstanding receivable.
11. Collect remaining payment.
12. Verify cash ledger.
13. Generate and share receipt.
14. Return part of the sale.
15. Verify refund and inventory movement.
16. Export encrypted backup.
17. Restore backup on a clean test database.
18. Verify all balances and records.

### Security tests

Cover:

- Incorrect PIN
- Repeated PIN failures
- Incorrect backup password
- Tampered backup ciphertext
- Malformed backup metadata
- Malformed CSV
- Unsupported file types
- Interrupted restore
- Duplicate operation retries

### Performance tests

Create realistic synthetic datasets.

Target scenarios:

- 1,000 products
- 10,000 transactions
- 50,000 transactions where practical
- Thousands of inventory movements
- Hundreds of customers
- Hundreds of suppliers

Measure actual performance and memory behavior.

Do not invent benchmark results.

## 18. BUILD AND RELEASE

Inspect the project configuration before building.

Target a new application version such as:

versionName: 2.0.0
versionCode: 6

Only if the actual repository and Play release history confirm code 6 is unused.

Otherwise choose the next valid monotonically increasing versionCode.

The Android package must remain unchanged.

### Required commands or repository equivalents

- flutter pub get
- dart format
- flutter analyze
- flutter test
- flutter build apk --release
- flutter build appbundle --release

Use the correct project-specific commands and flavors.

### Release verification

Confirm:

- Correct package identity
- Correct app version
- Correct signing configuration
- Appropriate Android SDK targets
- No production secrets exposed
- Proper Bluetooth permissions
- Proper camera permissions
- File picker behavior
- Offline business workflow
- AdMob configuration
- UMP behavior
- Database migration
- Backup compatibility
- No critical analyzer errors
- No failing tests

Do not upload to Play Console automatically.

If the signing key is unavailable, produce a clearly labeled unsigned or non-production artifact and report the release blocker.

## 19. DOCUMENTATION FILES

Create:

docs/enhancement/ARCHITECTURE_AUDIT.md
docs/enhancement/ENHANCEMENT_SPEC.md
docs/enhancement/DATABASE_MIGRATION.md
docs/enhancement/FINANCIAL_RULES.md
docs/enhancement/SECURITY_DESIGN.md
docs/enhancement/TEST_PLAN.md
docs/enhancement/RELEASE_CHECKLIST.md
docs/enhancement/IMPLEMENTATION_NOTES.md

Also create at the repository root:

TASKS.md
AGENTS.md
PROGRESS.md

Do not duplicate entire specifications in multiple files.

Use cross-references instead.

## 20. TASKS.MD — MANDATORY IMPLEMENTATION TRACKER

Create a task list with stable task IDs.

Use this structure:

### PHASE 0 — AUDIT
- [ ] AUD-001 Repository inspection
- [ ] AUD-002 Existing architecture analysis
- [ ] AUD-003 Database schema analysis
- [ ] AUD-004 Baseline test execution
- [ ] AUD-005 AdMob and signing audit
- [ ] AUD-006 Migration risk assessment

### PHASE 1 — FOUNDATION
- [ ] FND-001 Database migration framework
- [ ] FND-002 Financial ledger architecture
- [ ] FND-003 Inventory movement architecture
- [ ] FND-004 Shared validation components
- [ ] FND-005 New navigation structure
- [ ] FND-006 Legacy regression tests

### PHASE 2 — CUSTOMERS
- [ ] CUS-001 Customer database
- [ ] CUS-002 Customer CRUD
- [ ] CUS-003 Customer-sales integration
- [ ] CUS-004 Receivables integration
- [ ] CUS-005 Legacy migration tests

### PHASE 3 — SUPPLIERS
- [ ] SUP-001 Supplier database
- [ ] SUP-002 Supplier CRUD
- [ ] SUP-003 Purchase transactions
- [ ] SUP-004 Inventory receiving
- [ ] SUP-005 Supplier payments
- [ ] SUP-006 Payables reporting

### PHASE 4 — CASHFLOW
- [ ] CSH-001 Cash accounts
- [ ] CSH-002 Cash movement ledger
- [ ] CSH-003 Sales settlement integration
- [ ] CSH-004 Receivable payment integration
- [ ] CSH-005 Supplier payment integration
- [ ] CSH-006 Cashflow reports
- [ ] CSH-007 Closing reports

### PHASE 5 — INVENTORY
- [ ] INV-001 Stock opname sessions
- [ ] INV-002 Difference validation
- [ ] INV-003 Stock adjustment posting
- [ ] INV-004 Sales returns
- [ ] INV-005 Refund integration
- [ ] INV-006 Inventory reconciliation tests

### PHASE 6 — BARCODE AND POS
- [ ] POS-001 Barcode model
- [ ] POS-002 Barcode scanning
- [ ] POS-003 Fast cashier UI
- [ ] POS-004 Cart management
- [ ] POS-005 Checkout integration
- [ ] POS-006 Offline and duplicate-operation tests

### PHASE 7 — RECEIPTS
- [ ] RCP-001 Receipt templates
- [ ] RCP-002 PDF generation
- [ ] RCP-003 Android sharing
- [ ] RCP-004 Printer integration
- [ ] RCP-005 Printer settings
- [ ] RCP-006 Printing error handling

### PHASE 8 — CSV IMPORT
- [ ] CSV-001 CSV template
- [ ] CSV-002 Parsing
- [ ] CSV-003 Validation
- [ ] CSV-004 Preview
- [ ] CSV-005 Duplicate handling
- [ ] CSV-006 Transactional import

### PHASE 9 — SMART ASSISTANT
- [ ] INS-001 Insight calculation engine
- [ ] INS-002 Sales trend analysis
- [ ] INS-003 Stock depletion estimation
- [ ] INS-004 Margin analysis
- [ ] INS-005 Receivable alerts
- [ ] INS-006 Insight dashboard

### PHASE 10 — SECURITY
- [ ] SEC-001 PIN design
- [ ] SEC-002 PIN setup and unlock
- [ ] SEC-003 Secure credential storage
- [ ] SEC-004 Encrypted backup
- [ ] SEC-005 Legacy backup compatibility
- [ ] SEC-006 Restore security tests

### PHASE 11 — POLISH AND QA
- [ ] QA-001 UI consistency
- [ ] QA-002 Dark mode
- [ ] QA-003 Tablet layout
- [ ] QA-004 Existing feature regression
- [ ] QA-005 Full integration tests
- [ ] QA-006 Performance verification
- [ ] QA-007 Accessibility verification
- [ ] QA-008 AdMob verification

### PHASE 12 — RELEASE
- [ ] REL-001 Analyzer pass
- [ ] REL-002 Tests pass
- [ ] REL-003 Migration verification
- [ ] REL-004 APK build
- [ ] REL-005 AAB build
- [ ] REL-006 Package identity check
- [ ] REL-007 Release checklist
- [ ] REL-008 Final implementation report

Each task must include or reference:

- Acceptance criteria
- Relevant files
- Test requirements
- Dependencies
- Completion evidence

A task is complete only when functionality and relevant tests pass.

## 21. TOKEN-EFFICIENT RESUME SYSTEM

This section is extremely important.

AI coding sessions may end because of token limits, usage limits, interruptions, or context resets.

The project must be resumable without reading the entire repository or repeating completed work.

### Create AGENTS.md

Keep AGENTS.md concise.

It must explain:

- Project purpose
- Main architecture
- Important directories
- Non-negotiable invariants
- Exact package identity preservation requirement
- Data migration rules
- AdMob safety
- Test commands
- Documentation index
- Resume instructions

### Create PROGRESS.md

Maintain a compact checkpoint with:

- Current phase
- Current task ID
- Last completed task
- Active files
- Recent modifications
- Tests last executed
- Test results
- Known blockers
- Next exact action
- Relevant architecture decisions

Keep PROGRESS.md concise, ideally below approximately 150 lines.

Do not append unlimited historical logs.

Move older details into IMPLEMENTATION_NOTES.md when necessary.

### Session startup procedure

At the beginning of every resumed AI coding session:

1. Read AGENTS.md.
2. Read PROGRESS.md.
3. Read the active section of TASKS.md.
4. Check git status.
5. Inspect only files relevant to the current task.
6. Continue from the last verified checkpoint.

Do not reread the entire repository.

Do not regenerate the entire plan.

Do not reimplement completed modules.

Do not perform broad full-repository searches unless required by the current task or an architectural conflict.

### Checkpoint rules

After each meaningful implementation milestone:

1. Run targeted validation.
2. Update task status.
3. Record changed files.
4. Record test outcomes.
5. Record outstanding issues.
6. Update the next actionable task.
7. Save concise architecture decisions.

If work is incomplete, retain the task as unchecked.

### Important

Never claim that a checkpoint proves correctness without validation.

Do not mark incomplete implementation as finished to reduce token usage.

### Resume command

When instructed:

"CONTINUE UNTUNGKU PRO"

Immediately:

- Read AGENTS.md.
- Read PROGRESS.md.
- Read current TASKS.md section.
- Check git status.
- Resume the active task.
- Continue implementation.

Do not ask the user to provide the original master prompt again unless project checkpoint files are missing or corrupted.

## 22. DEVELOPMENT EXECUTION STRATEGY

This is ONE complete enhancement project containing all requested features.

Use multiple internal implementation phases because financial and database dependencies require a safe build order.

Do not interpret phases as permission to stop after the MVP.

Execute in this order:

1. Audit and baseline
2. Migration framework
3. Financial and inventory consistency foundation
4. Customer management
5. Supplier purchasing
6. Cash ledger
7. Stock opname and returns
8. Fast POS and barcode
9. Receipts and printing
10. CSV import
11. Business insights
12. PIN and encrypted backup
13. UI polish
14. Complete regression testing
15. Release builds

Use small, focused changes and targeted tests during implementation.

Use broader tests at integration milestones and before release.

Do not refactor unrelated modules without a demonstrated need.

If a tool, dependency, platform SDK, printer, or hardware device is unavailable, document the exact blocker and continue tasks that do not depend on it.

For hardware-dependent behavior, distinguish mock or adapter tests from tests on actual physical devices.

Never claim physical printer or camera verification without executing it on real supported hardware.

## 23. COMPLETION DEFINITION

The project is complete only if:

- All nine enhancement groups are implemented.
- Existing features remain available.
- Existing user data upgrades correctly.
- Legacy backups remain importable.
- Inventory operations reconcile.
- Financial operations reconcile.
- Customer receivables remain correct.
- Supplier payables remain correct.
- Stock opname and returns work.
- Barcode checkout works.
- Receipts export correctly.
- Bluetooth printing implementation is integrated.
- CSV import works.
- Business insights calculate offline.
- PIN protection works.
- Encrypted backup works.
- AdMob remains correctly configured.
- Core application functionality works offline.
- Relevant automated tests pass.
- Analyzer passes.
- Release builds complete or genuine environmental blockers are explicitly documented.

Do not use the words "production ready" if unresolved critical functional, migration, accounting, or security defects remain.

## 24. FINAL REPORT FORMAT

At the end, report:

### IMPLEMENTATION SUMMARY
- Completed modules
- Incomplete modules
- Important architecture decisions

### DATABASE
- Schema changes
- Migration tests
- Compatibility status
- Outstanding data risks

### VALIDATION
- Analyzer results
- Unit test results
- Widget test results
- Integration test results
- Build results
- Physical hardware validation status

### SECURITY
- PIN implementation
- Backup encryption implementation
- Security test outcomes

### ADMOB
- Existing configuration preservation
- Consent compatibility
- Test and production unit safeguards

### RELEASE
- Version name
- Version code
- Package identity
- APK path
- AAB path
- Remaining release blockers

### NEXT STEPS
List only remaining concrete items.

Do not fabricate results or claim unexecuted checks passed.

## 25. BEGIN EXECUTION NOW

Start immediately.

First inspect the repository, verify the actual technology and state, create or update AGENTS.md, TASKS.md, PROGRESS.md, and the architecture audit.

Then proceed with implementation.

Do not stop at the documentation stage.

Do not ask unnecessary questions for ordinary technical choices.

Choose maintainable solutions independently, document important decisions, and continue.

Your priority is:

DATA SAFETY > FINANCIAL CORRECTNESS > EXISTING FEATURE COMPATIBILITY > SECURITY > FUNCTIONAL COMPLETENESS > PERFORMANCE > VISUAL POLISH.

Build the complete UntungKu Pro enhancement as a single coordinated implementation project.

**START WORKING NOW.**