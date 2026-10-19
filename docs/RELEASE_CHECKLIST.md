# Release gate

- [ ] Review all automated test and build runs at the exact release commit.
- [ ] Run end-to-end integration test and visual checks on a physical Android device or emulator (small/large, keyboard, dark/light, TalkBack).
- [ ] Capture real app screenshots; do not present generated mockups as screenshots.
- [ ] Review current Play target API requirement, developer-account testing eligibility and signing requirements directly in Play Console and official documentation.
- [ ] Set immutable Android application ID and owner-controlled versioning.
- [ ] Supply upload keystore through GitHub environment `release` secrets, retaining a secure offline copy.
- [ ] Fill privacy policy owner/contact, publish policy URL, and complete Data safety accurately.
- [ ] Verify icon (512px PNG provided), feature graphic if required, and screenshot dimensions against current Play listing requirements.
- [ ] Keep production ads disabled until consent, placements, callbacks, test ad/device configuration, and privacy declarations pass device review.
- [ ] Test external backup export and restore after app restart.
- [ ] Review accessibility, restore recovery and migration plans before shipping.

No workflow automatically publishes to Google Play. A signed AAB alone is not proof of Play eligibility or approval.

Official references checked 19 October 2026:

- [Target API requirement](https://support.google.com/googleplay/android-developer/answer/11926878?hl=id): new apps/updates require API 36 starting 31 August 2026. Project target is explicitly 36.
- [Store assets](https://support.google.com/googleplay/android-developer/answer/9866151): app icon 512×512, feature graphic 1024×500. Review phone screenshot rules before submission.
- [Personal developer testing](https://support.google.com/googleplay/android-developer/answer/14151465): affected new personal accounts need 12 opted-in testers for 14 consecutive days before production access application. Account-specific requirements remain for the owner to verify.
