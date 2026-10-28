# Implementation plan

1. Preserve package/signing/SQLite and backup compatibility; keep schema v1 until a migration and upgrade fixture are tested.
2. Rebrand visible Flutter and Android surfaces, icon, splash, privacy copy, and accurate store listing.
3. Build safe AdMob placements and test loading/frequency; use sample units on devices.
4. Expand offline modules in dependency order: onboarding and business settings; product and inventory; cashier/payments; customers/suppliers/purchases; debts; cashbook; receipt/export; detailed reports.
5. Add accounting and migration tests for each new module, run offline Android workflows, and capture real screenshots.
6. Build signed AAB/APK, validate artifacts, push reviewed branch, then upload to Play Internal Testing when Play access and listing/privacy review are confirmed.

Only steps implemented and verified in `PROGRESS.md` are complete.
