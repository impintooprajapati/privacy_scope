## 0.1.0

- Initial release.
- Added `PrivacyScope` declarative widget for screen and subtree privacy scoping.
- Added configurable `PrivacyPolicy` with `ScreenshotPolicy` and `AppSwitcherPolicy`.
- Added `PrivacyPolicy.standard()` and `PrivacyPolicy.strict()` presets.
- Added `PrivacyController` managing scope stack, depth prioritization, deduplication, and automatic policy restoration.
- Added Android screenshot blocking and recent-tasks protection via `FLAG_SECURE`.
- Added iOS app-switcher privacy overlay (`blur` and `hide` modes).
- Added iOS screen recording / capture detection and event stream (`UIScreen.capturedDidChangeNotification`).
- Added nested scope handling and automatic restoration upon unmounting or navigation pop.
- Added zero-dependency architecture (completely state-management independent).
- Added interactive Material 3 example application with live Privacy HUD.
- Added comprehensive unit and widget test suite.
