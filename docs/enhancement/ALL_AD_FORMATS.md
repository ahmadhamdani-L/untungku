# All five AdMob formats — 2026-11-06

User explicitly requested enabling native, rewarded and app-open, then confirmed all five formats must be used. Production IDs in `config/admob-release.json`, Android package and signing material are unchanged. No dependency or database changes.

| Format | Placement / boundaries |
| --- | --- |
| Banner | Existing isolated top-of-Beranda slot; hidden under form/modal routes and during rewarded quiet time. |
| Interstitial | Existing preloaded success-completion boundary, 3 completions, 2-minute initial delay, 3-minute cooldown, maximum 5/session. Now also respects shared fullscreen exclusion and quiet time. |
| Native | SDK small native template below the report-hub links. Clearly labelled Iklan; SDK owns attribution/AdChoices/click handling. Instantiated only on the selected report tab and screens at least 360 logical pixels wide, preserving the template's recommended minimum width after page padding. No concurrent banner on this tab. Hidden under modal routes and quiet time. |
| Rewarded | Explicit opt-in card in Settings: finish an ad for 30 minutes without any ads in the current process/session. Features remain available without watching. Reward only on the SDK earned callback, once per presentation. Dismissal/failure earns nothing. Disabled until preloaded; no-fill has bounded retry backoff. Restarting the app ends session-only quiet time, as disclosed in the UI. |
| App open | Warm return only, from an opaque loading overlay that preserves the underlying widget state. First two qualifying returns skipped. A return qualifies after at least 30 seconds backgrounded, only on Beranda with no pushed route/modal, keyboard or PIN enabled. Preloaded only; no wait for fill and no late popup. Maximum 2/session, 10-minute own cooldown, cache expires at 4 hours. Cold start does not display it. |

All fullscreen formats share exclusion and a 3-minute automatic-display spacing rule. A user's explicit rewarded opt-in may bypass the automatic spacing, but never another fullscreen or active quiet time. Consent, foreground and safe-route conditions are checked again immediately before showing. Consent/privacy changes invalidate pending loads, and late callbacks after disposal cannot show. Reward quiet time hides banner/native, stops automatic fullscreen, and expires after 30 minutes or process termination. No financial or stock posting is involved.

Implementation: `lib/services/ad_placements.dart` is a part of the existing ads service; Home handles safe warm-return presentation; existing feature modules remain. `config/google-test.json` supplies all five Google sample units for development. Tests never request owner production units.

References: [native templates](https://developers.google.com/admob/flutter/native/templates), [app-open guidance](https://developers.google.com/admob/flutter/app-open), [rewarded units](https://support.google.com/admob/answer/7372450). These inform implementation, not an account-approval or ad-fill guarantee.

Executed checks: formatter 96 files unchanged; analyzer clean; full regression 131 passed/10 offline skips; separate live adapter suite 11 passed/1 offline-only skip; Android Google sample-unit suite 5 passed (all formats loaded, native rendered). Evidence: build/labarapi-all-ads/logs; checkpoints in PROGRESS.md and TASKS.md. Signed release artifacts from earlier milestones do not contain this work; no publication performed by this change.
