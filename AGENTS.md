# UntungKu Pro

Offline Indonesian Android bookkeeping for UMKM. Existing Flutter Material 3 / Riverpod `Store` / Drift SQLite / integer Rupiah architecture is the baseline; retain existing feature files and add modular features without a wholesale move.

- Identity MUST stay `id.untungku.untungku_pro`; retain upload key, production AdMob App ID and ad units in `config/admob-release.json`.
- User authorization 2026-11-06 explicitly permits Git push, signed builds and Google Play production upload/release for this task, superseding the earlier no-publication instruction. Preserve hardware verification limits; never expose secrets or perform destructive resets. Use the existing upload key and production AdMob profile.
- Preserve all pre-existing dirty work (v1.1.0 changes). Snapshot: `build/v2-baseline/source-1.1.0.zip`, `pre-v2.diff`.
- Money is integer Rupiah, rates basis points; never recalculate old sale cost snapshots. Partial payment is cash, not new revenue. Purchases aren't operating expenses. Transfers aren't income.
- Financial and stock postings must be atomic, auditable, and idempotent. Do not erase historical audit events.
- Additive, explicit migrations only; retain schema v1 fixture and test reopening representative v1.1 databases. Backups v1/v2 must remain readable; new backup payload/envelope have distinct versions.
- Never merge customers by name. Legacy cash stays explicitly unallocated; never manufacture account allocations.
- Development/tests use offline or Google sample units only. Preserve UMP, preload-only completion boundaries, caps and cooldowns. No ad during critical operations.
- Core: `lib/domain`, `lib/data`; UI: `lib/features`; ads: `lib/services/ads.dart`; release: `tool` and `android`; tests: `test`, `integration_test`.
- Validation: `dart format lib test integration_test test_driver`; `flutter analyze --no-pub`; `flutter test --no-pub`; adapter: `flutter test test/ads_consent_test.dart --no-pub --dart-define=ADMOB_ENABLED=true --dart-define=ADMOB_USE_MOCK=false`.
- Dependency changes need pub get; regenerate Drift with `dart run build_runner build` and preserve migration snapshots. Run Android integration and local signed release builds before declaring release ready. Hardware mocks do not prove physical camera/printer support.

## Resume

Read `PROGRESS.md`, active `TASKS.md` phase, then `git status --short`. Inspect only active files. Continue implementation, not planning-only. After milestones run targeted checks, update evidence and next exact action. Leave incomplete boxes unchecked. Specification and documentation index: `docs/enhancement/ENHANCEMENT_SPEC.md` (sections 5–18), audit, migration, financial rules, security design, test plan, release checklist, implementation notes in the same folder. Do not duplicate the entire specification.
