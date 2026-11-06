# Local v2 release checklist — 2026-11-06

- [ ] All TASKS.md physical feature acceptance complete — POS-002/RCP-004/physical QA-005 open.
- [x] Existing data migration, reopen and backups v1/v2 verified by regression.
- [x] Return/refund, cash and stock reconciliation tests pass.
- [x] PIN and encrypted-backup security tests pass; recovery/threat limits documented.
- [x] UI/light-dark/responsive/accessibility and measured host/emulator read performance verified; physical budget-phone measurement not claimed.
- [x] Formatter, analyzer and full tests pass — 128 passed, 4 offline skips covered by separate 4-case adapter run.
- [x] Android software integration/permission paths, receipt save/share and sample-ad runtime verified.
- [x] Bluetooth/camera physical-device limits explicitly reported.
- [ ] Confirm unused next monotonic Play version code before selecting v2 version. Current local validation artifacts remain 1.1.0+5.
- [x] Local signed APK and AAB built using existing upload identity; not a publishable new v2 version.
- [x] Package/SDKs/signatures/production AdMob app + active units/optional hardware/no dev plugin verified.
- [x] Artifact paths, source digest, SHA-256 and genuine blockers recorded in FINAL_IMPLEMENTATION_REPORT.md and build/v2-validation/artifacts.json.
- [x] No remote push, Play upload or publication performed for v2.

Overall readiness: **blocked by physical camera/printer acceptance and actual next-version-code confirmation**. See TASKS.md, FINAL_IMPLEMENTATION_REPORT.md and PROGRESS.md. Do not check unverified tasks or publish these validation artifacts.
