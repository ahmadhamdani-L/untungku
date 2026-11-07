# LabaRapi visual refresh — 2026-11-06

Initial refresh checkpoint. The subsequent user-authorized activation of all five formats supersedes the inactive-format rows below: see [ALL_AD_FORMATS](ALL_AD_FORMATS.md).

User reference: “Poster Aplikasi LabaRapi untuk UMKM Indonesia.png”. Adopt the blue/white visual direction and LabaRapi display name, keeping `id.untungku.untungku_pro`, Store/Riverpod, Drift schema, all financial rules, upload key, and production ad configuration unchanged.

## Implemented

- Blue primary palette, pale blue backgrounds, outlined white cards, coordinated navy dark mode, rounded controls and blue report charts.
- LabaRapi wordmark/display name in home, PIN, settings and Android launcher. Flutter code-drawn growth mark and Android vector launcher/splash mark; historical raster/store artwork retained.
- Bottom navigation: Beranda, Transaksi, Laporan, Produk, Lainnya. Dedicated report hub retains calculator access and links to existing reports, inventory, receivables and insights.
- Dashboard quick actions open existing cashier, product and expense flows. Existing reported figures and explanatory accounting labels retained. No example balances, invented customer names or growth percentages inserted into real user data.
- Poster marketing text is a visual reference, not a feature specification: no automatic cloud-sync claim; data remains local with existing explicit backups.

## Ad placements

Production App ID and all five unit IDs in `config/admob-release.json` match the user-supplied values; that file is unchanged.

| Format | Current behavior |
| --- | --- |
| Banner /7589954559 | Only at the top of Beranda, outside scrolling business content, with an “Iklan” label, vertical spacing and bottom border. Removed from the bottom navigation region. Live builds reserve loading space; offline/mock builds reserve none. No banner in cashier/form routes or other main tabs; overview banners are hidden while a modal route covers the page. |
| Interstitial /9420454707 | Existing preloaded completion boundary, UMP, caps and cooldowns retained. No new startup, tab-switch or in-progress-operation trigger. |
| Rewarded /3650709544 | Retain existing configuration/adapter; no new placement or reward gate. User paste calls the link “Native advanced” but reports its format as “Iklan Reward”; do not reinterpret it as native. |
| Native /8813950043 | Configuration retained, no native placement activated by this refresh. |
| App open /3753195059 | Configuration retained, no startup placement activated by this refresh. |

Placement references: [recommended banner implementations](https://support.google.com/admob/answer/6275335), [banner guidance](https://support.google.com/admob/answer/6128877), [interstitial guidance](https://support.google.com/admob/answer/6066980). These inform implementation; they do not establish account approval or guarantee ad fill. Development and verification use offline mode or Google sample units, never the production units.

## Validation

Evidence and remaining action are recorded in PROGRESS.md and TASKS.md. This UI refresh does not establish physical camera/printer acceptance or production release readiness. Existing signed 2.0.0 artifacts predate the refresh and do not contain these changes.

Executed evidence: full suite 129 passed/4 offline skips; focused ads/navigation/accessibility 7 passed/4 offline skips; live-consent adapter 4 passed; Android business flow 1 passed; eight-screen capture navigation passed. Logs: build/labarapi-preview/logs. Final home preview: build/labarapi-preview/00-home-native.png, captured losslessly with adb and isolated example data. The preview capture uses `LABARAPI_PREVIEW_ONLY=true` and `--no-enable-impeller` to avoid emulator capture artifacts; production rendering configuration is unchanged.
