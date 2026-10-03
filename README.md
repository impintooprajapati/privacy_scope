# privacy_scope

[![pub package](https://img.shields.io/pub/v/privacy_scope.svg)](https://pub.dev/packages/privacy_scope)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/impintooprajapati/privacy_scope/blob/main/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/impintooprajapati/privacy_scope/pulls)

Context-aware privacy protection for Flutter apps. Apply screenshot protection, app-switcher privacy overlays, and sensitive-screen policies only where your app needs them.

---

## Why privacy_scope?

Most privacy plugins enforce security **globally across the entire application**. If an app needs to protect sensitive credit card details on a checkout screen, developers are often forced to disable screenshots everywhere, ruining the user experience on shareable screens like referral codes, order receipts, or public articles.

`privacy_scope` solves this by introducing a **declarative, context-aware privacy layer**. You declare privacy requirements around specific screens or widget subtrees:

```dart
PrivacyScope(
  policy: PrivacyPolicy.strict(),
  child: const PaymentScreen(),
)
```

When the user enters the screen, privacy protections are automatically applied. When they navigate away or close the screen, previous policies are seamlessly restored.

---

## Features

- 🎯 **Per-Screen & Subtree Scoping**: Protect only sensitive widgets, dialogs, or routes.
- 🔄 **Automatic Policy Restoration**: Seamlessly falls back to previous policies when scopes unmount or routes pop.
- 🌳 **Nested Scope Hierarchy**: Inner scopes intelligently override parent scopes without race conditions or fragile global booleans.
- ⚡ **Zero External State Dependencies**: 100% independent of BLoC, Riverpod, or Provider.
- 🛡️ **Android `FLAG_SECURE`**: Strictly prevents screenshots, screen recordings, and obscures recent-task previews in the system app switcher.
- 👁️ **iOS Privacy Overlays**: Obscures app snapshots in the iOS app switcher with native blur or opaque backgrounds.
- 📹 **iOS Screen Capture Detection**: Detects and notifies when AirPlay mirroring or screen recording starts or stops.
- 🧪 **Fully Testable**: Decoupled platform interface with in-memory test doubles for deterministic unit and widget tests.

---

## Installation

Add `privacy_scope` to your `pubspec.yaml`:

```yaml
dependencies:
  privacy_scope: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

Wrap any sensitive route or widget subtree in a `PrivacyScope`:

```dart
import 'package:flutter/material.dart';
import 'package:privacy_scope/privacy_scope.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrivacyScope(
      policy: const PrivacyPolicy.strict(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(
          child: Text('Credit card details protected from capture.'),
        ),
      ),
    );
  }
}
```

---

## Custom Policies

Customize screenshot protection and app-switcher behavior using `ScreenshotPolicy` and `AppSwitcherPolicy`:

```dart
PrivacyScope(
  policy: const PrivacyPolicy(
    screenshot: ScreenshotPolicy.allow,
    appSwitcher: AppSwitcherPolicy.blur,
  ),
  child: const ProfileScreen(),
)
```

### Predefined Presets

- **`PrivacyPolicy.standard()`**: Baseline preset. Screenshots and standard app switcher previews are allowed.
- **`PrivacyPolicy.strict()`**: High-security preset. Screenshots are blocked where supported, and the app switcher is hidden.

---

## Platform Support

We believe in **technical honesty**. Different mobile platforms provide fundamentally different privacy capabilities through their public APIs:

| Feature | Android | iOS |
| :--- | :---: | :---: |
| **Screenshot Blocking** | ✅ Yes (`FLAG_SECURE`) | ❌ No public API |
| **Recent Tasks / App Switcher Masking** | ✅ Yes (`FLAG_SECURE`) | ✅ Yes (Native blur / opaque overlay) |
| **Screen Recording / Capture Detection** | ✅ Via window security | ✅ Yes (`UIScreen.capturedDidChangeNotification`) |
| **Per-Screen & Route Scoping** | ✅ Yes | ✅ Yes |
| **Nested Scope Prioritization** | ✅ Yes | ✅ Yes |

> **Note on iOS Screenshots**: Apple does not provide a public API equivalent to Android's `FLAG_SECURE` for forbidding user screenshots. Any package claiming to completely block user screenshots on iOS either relies on private APIs (causing App Store rejection) or misrepresents screen recording detection. `privacy_scope` protects recent-task snapshots in the app switcher and provides screen recording notifications.

---

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                       Widget Tree                           │
│                                                             │
│   HomeScreen (Policy: standard)                             │
│     └─► Navigator.push(PaymentScreen)                       │
│           └─► PrivacyScope (Policy: strict) [Active Scope]  │
└──────────────────────────────┬──────────────────────────────┘
                               │ registers / unregisters
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    PrivacyController                        │
│                                                             │
│   • Manages Scope Stack & Hierarchy Depth                   │
│   • Resolves Effective Policy (Deepest / Highest Sequence)  │
│   • Deduplicates calls (no redundant channel invocations)   │
└──────────────────────────────┬──────────────────────────────┘
                               │ applyPolicy(effectivePolicy)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Native Platform Plugins                     │
│                                                             │
│   Android: WindowManager.LayoutParams.FLAG_SECURE           │
│   iOS: UIBlurEffect / Opaque Overlay & UIScreen Observer    │
└─────────────────────────────────────────────────────────────┘
```

1. When a `PrivacyScope` is mounted, it registers its policy and hierarchy depth with `PrivacyController`.
2. `PrivacyController` calculates the active effective policy across the scope stack.
3. If the effective policy changed, the native platform applies the required flags or lifecycle observers.
4. When the widget is disposed (e.g. `Navigator.pop()`), the previous policy is automatically restored.

---

## Nested Scopes

Inner scopes take precedence over parent scopes. When an inner scope unmounts, the parent policy is seamlessly restored:

```dart
PrivacyScope(
  policy: const PrivacyPolicy(
    screenshot: ScreenshotPolicy.allow,
    appSwitcher: AppSwitcherPolicy.blur,
  ),
  child: Column(
    children: [
      const Text('Parent Area: Screenshots allowed, Switcher blurred'),
      
      // Nested sensitive widget
      PrivacyScope(
        policy: const PrivacyPolicy.strict(),
        child: const SecretVaultWidget(), // Overrides parent with strict policy
      ),
    ],
  ),
)
```

---

## Privacy Events

Subscribe to system and privacy events without introducing state management packages:

```dart
final controller = PrivacyController.instance;

final subscription = controller.events.listen((event) {
  switch (event) {
    case PrivacyPolicyChanged(:final previous, :final current):
      debugPrint('Policy changed from $previous to $current');
    case ScreenCaptureStarted():
      debugPrint('Warning: Screen recording or AirPlay mirroring started!');
    case ScreenCaptureStopped():
      debugPrint('Screen recording stopped.');
    case ScreenCaptureDetected():
      debugPrint('Screen capture detected.');
  }
});
```

---

## Example Application

The repository includes a complete Material 3 example app located in `example/`:

- **Home Screen**: Demonstrates standard unconstrained baseline.
- **Profile Screen**: Demonstrates app-switcher blur protection while keeping screenshots enabled.
- **Payment Screen**: Demonstrates strict protection with dummy financial cards.
- **Private Notes Screen**: Demonstrates nested scopes with an interactive toggleable secret vault.
- **Live Privacy HUD**: An expandable debug overlay displaying the active policy, platform, and scope stack in real-time.

To run the example:

```bash
cd example
flutter run
```

---

## Security Notice

> **Important**: `privacy_scope` improves on-device UI privacy against casual shoulder surfing, accidental screenshots, and app switcher exposure. It is **not** a comprehensive security solution.
>
> It does **not** replace:
> - Hardware-backed secure storage (`flutter_secure_storage`)
> - Robust backend authorization & authentication
> - End-to-end data encryption
> - Protection against compromised / rooted / jailbroken devices

---

## Contributing

Contributions, feature requests, and bug reports are welcome! Please open an issue or pull request on [GitHub](https://github.com/impintooprajapati/privacy_scope).

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
