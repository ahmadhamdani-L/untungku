# LabaRapi 2.1.0+7 — production and store listing

Verified on 2026-11-07 in the authenticated Play Console for `id.untungku.untungku_pro`: release **2.1.0 - LabaRapi Kasir dan Usaha**, code **7**, is **Tersedia di Google Play**, released **7 Nov 05.17** as displayed, covering **178 countries**. The continuation found this release already active and did not upload the same code again.

The default listing already contained the new name, icon, feature graphic, description and phone captures. Its old tablet captures were replaced. The existing custom listing for 177 countries still had the previous brand and features; all its text and graphics were updated while preserving its targeting and 100% rollout.

Both listings now contain the LabaRapi icon, feature graphic, and eight ordered phone plus eight ordered 7-inch-tablet captures: dashboard, insights, cashier, products, transactions, receivables, reports and backup. Screenshots use clearly identified isolated example data from the running app. Descriptions highlight offline bookkeeping, inventory, cash accounts, receivables/payables, reports, digital receipts, CSV import, PIN and encrypted backup. No automatic cloud sync or physically verified camera/printer claim was added.

**Nine listing changes have been submitted**. Play Console shows **Perubahan yang sedang ditinjau**, with Google quick checks pending. Managed publishing was disabled after confirming there were no unrelated ready-to-publish items; the updates will publish automatically after Google approval. The active app release and pending listing review are separate statuses. Approval and propagation are controlled by Google.

## Validation and artifacts

- Formatter: 96 Dart files unchanged; analyzer clean; full suite 131 passed/10 offline adapter skips; release guards 4 passed.
- Ad adapters: 11 passed/1 offline-only skip; Android Google sample units: 5 passed across all formats. Production units were not requested in development.
- Phone and tablet capture navigation both passed with current LabaRapi branding.
- Current signed APK rebuilt using the original upload key and unchanged production AdMob profile. APK/AAB signatures, package, 2.1.0+7, SDK24/36, optional camera/Bluetooth, disabled Android backup, all five compiled unit IDs and absence of the integration test plugin verified.
- The APK and AAB have identical arm64 Dart runtime, bundled privacy policy and brand icon bytes. Existing AAB matches the code verified by the rebuilt APK; no duplicate version was uploaded.
- Archived signed files: `build/labarapi-play-release/labarapi-2.1.0+7.apk` and `.aab`; SHA-256 and checks in `artifacts.json`; runtime equality in `runtime-parity.json`; executed logs in `logs/`.

Console evidence and artifact hashes: [production evidence](play-release-labarapi-production.json). The verifier's `publicationPerformed: false` means that the local verification tool does not publish; it does not override the independently observed production status above. Physical camera/printer and budget-phone acceptance remain unverified.
