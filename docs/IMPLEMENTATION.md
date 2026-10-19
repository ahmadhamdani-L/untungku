# Milestones and acceptance criteria

- M0 Environment: inspect empty workspace, Git status/remotes, Flutter/Dart, JDK, Android SDK/emulator, and GitHub app installation. Never print credentials.
- M1 Architecture: separate domain arithmetic, Drift repository, Riverpod state, and Material 3 presentation. Main navigation and skippable onboarding work with an empty database.
- M2 Branding: original generated growth mark in all launcher densities, adaptive vector, splash, and in-app brand. Inspect on emulator; capture real screenshots.
- M3 Persistence: relational SQLite tables with foreign keys, atomic writes, stable UUIDs and cost snapshots. Reject broken backup relationships.
- M4 Calculator: exact integer Rupiah and basis points, discounts, fixed/variable costs, target margin/profit, denominator edge cases. Unit tests must pass.
- M5 Operations: products, archive, stock correction with reason, multi-product sale, expense, edit/void and transaction history. Regression tests must cover rollback and repeated voids.
- M6 Reports/files: actual stored totals, local day windows, low stock/best sellers, search/filter, quoted CSV, versioned backup validation/transactional restore and recovery copy.
- M7 Ads: offline safe defaults and deterministic mock states. Isolated Google SDK with consent/reward callback adapter; no production monetization claim without device validation.
- M8 Git workflow: feature branch to develop to main only after checks. Preserve history and user work. No forced pushes.
- M9 Automated builds: CI analysis/tests, debug APK with required artifact, manual signed AAB with external secrets. Confirm remote run result and artifact before reporting successful delivery.
- M10 Verification: automated tests, integration on Android, visual inspection, documented privacy and owner release gates. Honest status report separates verified local/remote work and remaining owner requirements.

Actual check results are recorded after execution; this document is acceptance criteria, not a claim that all checks passed.
