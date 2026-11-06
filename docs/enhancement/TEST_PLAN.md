# Validation plan

Baseline executed results: ARCHITECTURE_AUDIT.md. Detailed acceptance: specification §17. No future test result is implied here.

1. Add targeted unit/database tests alongside each domain operation, including rollback and duplicate-reference conflicts.
2. Preserve synthetic schema-1 products, snapshots, cancelled and partially paid sales, negative/archived stock, discounts/fees and ledger movements. Verify bytes/balances after migration and legacy backup round trips.
3. Widgets for every new module; light/dark/320px/tablet layouts and meaningful validation.
4. Android integration: supplier→purchase→receipt→barcode/manual POS→credit sale→collection→receipt/share→partial return/refund→encrypted backup→clean restore→reconciliation.
5. Security: wrong PIN/password, lockout, tampered AEAD metadata/ciphertext, malformed CSV/JSON and rollback.
6. Actual timed synthetic 1k-product/10k-sale and practical 50k-sale runs; record memory/device/dataset/time, do not infer numbers.
7. Bluetooth and camera mocks/emulator checks distinguished from physical hardware execution.
8. Full formatter/analyzer/tests, Google sample-ad tests and signed local APK/AAB identity verification before any release-ready claim. No Play upload for v2 task.
