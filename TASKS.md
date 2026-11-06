# UntungKu Pro v2 implementation tracker

Source of acceptance criteria: [ENHANCEMENT_SPEC](docs/enhancement/ENHANCEMENT_SPEC.md). A checked box requires implementation and executed relevant validation. Baseline: 1.1.0+5; all pre-existing uncommitted changes retained.

### PHASE 0 — AUDIT
- [x] AUD-001 Repository inspection
- [x] AUD-002 Existing architecture analysis
- [x] AUD-003 Database schema analysis
- [x] AUD-004 Baseline test execution
- [x] AUD-005 AdMob and signing audit
- [x] AUD-006 Migration risk assessment

### PHASE 1 — FOUNDATION
- [x] FND-001 Database migration framework — v1 fixture upgrade/reopen, fresh-v2 schema parity, v2 snapshot; targeted validation 2026-11-04 (15 passed, analyzer clean)
- [x] FND-002 Financial ledger architecture — serialized cash posting, durable checkout retry keys, isolated expense compensation; 26 targeted tests passed and analyzer clean (2026-11-04)
- [x] FND-003 Inventory movement architecture — structured stock references, retry-safe adjustments; 16 inventory/foundation/return tests passed (2026-11-04)
- [x] FND-004 Shared validation components — shared bounded integer parser and IntegerField adopted in purchase/cash/opname forms; input/widget checks passed (2026-11-04)
- [x] FND-005 New navigation structure — management navigation verified for all seven foundation destinations (2026-11-04)
- [x] FND-006 Legacy regression tests — full regression 72 passed, 4 live-adapter tests skipped in offline configuration (2026-11-04)

### PHASE 2 — CUSTOMERS
- [x] CUS-001 Customer database — 27 combined customer/supplier/migration/receivable/foundation checks passed (2026-11-04)
- [x] CUS-002 Customer CRUD — 27 combined customer/supplier/migration/receivable/foundation checks passed (2026-11-04)
- [x] CUS-003 Customer-sales integration — 27 combined customer/supplier/migration/receivable/foundation checks passed (2026-11-04)
- [x] CUS-004 Receivables integration — 27 combined customer/supplier/migration/receivable/foundation checks passed (2026-11-04)
- [x] CUS-005 Legacy migration tests — 27 combined customer/supplier/migration/receivable/foundation checks passed (2026-11-04)

### PHASE 3 — SUPPLIERS
- [x] SUP-001 Supplier database — supplier identity/CRUD, receiving/payments and grouped payables verified in 27 combined checks (2026-11-04)
- [x] SUP-002 Supplier CRUD — supplier identity/CRUD, receiving/payments and grouped payables verified in 27 combined checks (2026-11-04)
- [x] SUP-003 Purchase transactions — supplier identity/CRUD, receiving/payments and grouped payables verified in 27 combined checks (2026-11-04)
- [x] SUP-004 Inventory receiving — supplier identity/CRUD, receiving/payments and grouped payables verified in 27 combined checks (2026-11-04)
- [x] SUP-005 Supplier payments — supplier identity/CRUD, receiving/payments and grouped payables verified in 27 combined checks (2026-11-04)
- [x] SUP-006 Payables reporting — supplier identity/CRUD, receiving/payments and grouped payables verified in 27 combined checks (2026-11-04)

### PHASE 4 — CASHFLOW
- [x] CSH-001 Cash accounts — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] CSH-002 Cash movement ledger — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] CSH-003 Sales settlement integration — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] CSH-004 Receivable payment integration — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] CSH-005 Supplier payment integration — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] CSH-006 Cashflow reports — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] CSH-007 Closing reports — cash account settlement, immutable ledger and scoped cashflow/closing CSV/PDF; full regression 87 passed, 4 offline skips (2026-11-04)

### PHASE 5 — INVENTORY
- [x] INV-001 Stock opname sessions — stock sessions, differences, atomic postings, return dispositions/refunds and reconciliation; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] INV-002 Difference validation — stock sessions, differences, atomic postings, return dispositions/refunds and reconciliation; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] INV-003 Stock adjustment posting — stock sessions, differences, atomic postings, return dispositions/refunds and reconciliation; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] INV-004 Sales returns — stock sessions, differences, atomic postings, return dispositions/refunds and reconciliation; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] INV-005 Refund integration — stock sessions, differences, atomic postings, return dispositions/refunds and reconciliation; full regression 87 passed, 4 offline skips (2026-11-04)
- [x] INV-006 Inventory reconciliation tests — stock sessions, differences, atomic postings, return dispositions/refunds and reconciliation; full regression 87 passed, 4 offline skips (2026-11-04)

### PHASE 6 — BARCODE AND POS
- [x] POS-001 Barcode model — 3 POS model/concurrency/denied-camera checkout tests passed (2026-11-04); physical scanner validation pending
- [ ] POS-002 Barcode scanning — 4 POS tests passed and targeted analyzer clean (2026-11-05); always-visible manual exit, duplicate/disposed callback guard verified. Android debug build and 1 native scanner/manual-exit smoke test passed on Untungku_Test (2026-11-05); barcode recognition/physical scan pending
- [x] POS-003 Fast cashier UI — 3 POS model/concurrency/denied-camera checkout tests passed (2026-11-04); physical scanner validation pending
- [x] POS-004 Cart management — 3 POS model/concurrency/denied-camera checkout tests passed (2026-11-04); physical scanner validation pending
- [x] POS-005 Checkout integration — 3 POS model/concurrency/denied-camera checkout tests passed (2026-11-04); physical scanner validation pending
- [x] POS-006 Offline and duplicate-operation tests — 3 POS model/concurrency/denied-camera checkout tests passed (2026-11-04); physical scanner validation pending

### PHASE 7 — RECEIPTS
- [x] RCP-001 Receipt templates — saved snapshot/partial credit/refund/void templates and 58/80 mm previews verified; 2 receipt tests previously passed plus 3 new edge-case tests passed, targeted analyzer clean (2026-11-05)
- [x] RCP-002 PDF generation — offline PDF/PNG 58/80 mm; 100 long-name items span multiple PDF pages, continuation identity/page numbers, oversized PNG directs to PDF, invalid widths rejected; 3 new edge-case tests passed, targeted analyzer clean (2026-11-05)
- [x] RCP-003 Android sharing — metadata/content, save success/cancel/failure and share failure recovery verified in 1 widget test; 1 Android native test passed for save/share cancellation and saving PDF to Download (2026-11-05); sale/ledger unchanged, targeted analyzer clean
- [ ] RCP-004 Printer integration — native Classic SPP/ESC-POS text adapter, CONNECT permission and 15s socket deadline implemented; paired/error native paths and text tests passed; physical printer protocol/output validation unavailable
- [x] RCP-005 Printer settings — preferred paired printer and 58/80mm width survive Store reload; optional address/phone/footer/PNG logo; printer settings widget test passed (2026-11-05)
- [x] RCP-006 Printing error handling — native unpaired/permission errors and mocked disconnect/retry verified; UI recovers and no sale/ledger posting occurs (2026-11-05); physical disconnect/timeout remains device validation

### PHASE 8 — CSV IMPORT
- [x] CSV-001 CSV template
- [x] CSV-002 Parsing
- [x] CSV-003 Validation
- [x] CSV-004 Preview
- [x] CSV-005 Duplicate handling
- [x] CSV-006 Transactional import

CSV evidence (2026-11-05): existing modular implementation retained; targeted feature run passed (15 combined security/printer/CSV/insight tests). CSV cases cover quoting/BOM/mapping, row errors, identity policies, cancellation, rollback, retry after reopen and unchanged historical cost. UI preview native checks remain in QA.

### PHASE 9 — SMART ASSISTANT
- [x] INS-001 Insight calculation engine
- [x] INS-002 Sales trend analysis
- [x] INS-003 Stock depletion estimation
- [x] INS-004 Margin analysis
- [x] INS-005 Receivable alerts
- [x] INS-006 Insight dashboard

INS evidence (2026-11-05): existing deterministic engine/dashboard retained; 15 combined targeted tests passed, including sparse/empty data, period comparisons, return-adjusted units, future records and snooze controls. Device-scale performance checked separately in QA.

### PHASE 10 — SECURITY
- [x] SEC-001 PIN design
- [x] SEC-002 PIN setup and unlock
- [x] SEC-003 Secure credential storage
- [x] SEC-004 Encrypted backup
- [x] SEC-005 Legacy backup compatibility
- [x] SEC-006 Restore security tests

SEC evidence (2026-11-05): SECURITY_DESIGN.md records recovery and parameters. PIN salted verifier/secure storage/lockout/change/disable and concurrent background-lock completion tests passed; setup confirmation and idle/background root gate UI passed. AEAD wrong password/tamper/KDF metadata and encrypted clean restore passed. Native secure storage persistence passed. Legacy v1/v2, migration and interrupted atomic restore covered by full regression (128 passed, 4 offline adapter skips).

### PHASE 11 — POLISH AND QA
- [x] QA-001 UI consistency
- [x] QA-002 Dark mode
- [x] QA-003 Tablet layout
- [x] QA-004 Existing feature regression
- [ ] QA-005 Full integration tests — native legacy/scanner/v2 flow 4 passed, receipt save/share 1 passed, Google sample ads 2 passed; physical barcode recognition and printer end-to-end acceptance remain unverified
- [x] QA-006 Performance verification
- [x] QA-007 Accessibility verification
- [x] QA-008 AdMob verification — 4 live-consent adapter unit cases + 2 native Google sample-unit cases passed (2026-11-06), including preload without startup display

QA evidence (2026-11-06): 6 layout cases at 320/360/1024px, 1.3x text, light/dark; Home label/tap-target/contrast passed. Host 10k/50k and emulator 10k measured with documented memory/device limits. Final regression 128 passed/4 offline skips; separate required adapter run 4 passed. Native software checks passed 7 cases across three runs. Physical barcode/printer and budget-phone performance not claimed. Full details: docs/enhancement/FINAL_IMPLEMENTATION_REPORT.md.

### PHASE 12 — RELEASE
- [x] REL-001 Analyzer pass
- [x] REL-002 Tests pass
- [x] REL-003 Migration verification
- [x] REL-004 APK build — signed local validation APK 1.1.0+5; original upload certificate, identity/SDK/config verified (2026-11-06)
- [x] REL-005 AAB build — signed local validation AAB 1.1.0+5; original upload certificate, manifest/config verified (2026-11-06)
- [x] REL-006 Package identity check
- [ ] REL-007 Release checklist — local checks passed; actual unused next Play version code and physical camera/printer acceptance unconfirmed; no v2 release readiness/publication
- [x] REL-008 Final implementation report — docs/enhancement/FINAL_IMPLEMENTATION_REPORT.md; genuine blockers and SHA-256 recorded (2026-11-06)


## Task evidence and execution contracts

AUD-001–006: completed; evidence in docs/enhancement/ARCHITECTURE_AUDIT.md. Analyzer clean; 44 baseline unit/widgets passed, four consent adapter cases skipped in offline configuration.

Every task inherits its feature acceptance criteria, dependencies, file scope and tests from this table. Individual completion evidence is recorded here or in IMPLEMENTATION_NOTES.md before checking its box.

| Task prefix | Spec sections / acceptance | Files | Required tests | Depends on |
| --- | --- | --- | --- | --- |
| FND | 4, 14: additive migrations, atomic idempotent postings | lib/data, lib/domain, lib/core | migration, rollback, legacy regression | AUD |
| CUS | 7: CRUD, explicit legacy links, unchanged balances | lib/features/customers, lib/data, lib/domain | customer Store and widget tests | FND |
| SUP | 8: drafts, receipts, weighted costs, payments, reversals | lib/features/purchasing, lib/features/suppliers, lib/data, lib/domain | receiving retries, payable, cancellation | FND, CUS |
| CSH | 10: cash ledger distinct from revenue; unallocated history | lib/features/cashflow, lib/features/reports, lib/data | transfers, settlements, reconciled reports | FND, SUP |
| INV | 9: checked counts, partial returns, refund liabilities | lib/features/stock_opname, lib/features/returns, lib/domain | concurrency, return limits, refund retries | CSH |
| POS | 6: offline camera/manual checkout and stable operation ID | lib/features/barcode, lib/features/sales | widget, inventory and retry tests | CUS, INV |
| RCP | 5: offline PDF/image/sharing/ESC-POS; no sale mutation | lib/features/receipts, android | receipt snapshots, printer adapter and device tests | POS |
| CSV | 11: quoted parsing, mapping, preview and atomic commit | lib/features/csv_import | malformed input, duplicates and rollback | FND, POS |
| INS | 12: deterministic explained local rules and snooze | lib/features/business_insights | empty, sparse, return-adjusted data | CSH, INV |
| SEC | 13: derived PIN, secure storage, AEAD, legacy recovery | lib/core/security, lib/core/backup | wrong PIN/password, tamper, atomic restore | all entity modules |
| QA | 15–17: existing features, light/dark/tablet/accessibility | lib/features, test, integration_test | full suite, device and actual benchmarks | all feature phases |
| REL | 18, 23: verified local artifacts; no remote publication | pubspec, android, tool, docs | format/analyze/tests/build/identity | QA |
