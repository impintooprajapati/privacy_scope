import 'package:meta/meta.dart';

/// Defines the policy for screenshot and screen recording protection.
enum ScreenshotPolicy {
  /// Screenshots and screen recording are allowed.
  allow,

  /// Screenshots and screen recording are blocked on platforms where supported
  /// (e.g. Android FLAG_SECURE). On iOS, public APIs do not allow direct blocking
  /// of user screenshots, but screen recording can be detected and notified.
  block,
}

/// Defines the policy for obscuring app content in the system app switcher / recent tasks.
enum AppSwitcherPolicy {
  /// The app switcher displays standard live or snapshot app content.
  allow,

  /// The app switcher snapshot is obscured using a blur effect when inactive.
  blur,

  /// The app switcher snapshot is hidden behind an opaque privacy overlay.
  hide,
}

/// Defines the privacy rules applied while a `PrivacyScope` is active.
///
/// Instances are immutable. Predefined standard configurations are available:
/// - [PrivacyPolicy.standard] (no restrictions)
/// - [PrivacyPolicy.strict] (screenshots blocked, app switcher hidden)
@immutable
class PrivacyPolicy {
  /// The screenshot policy to apply.
  final ScreenshotPolicy screenshot;

  /// The app switcher policy to apply.
  final AppSwitcherPolicy appSwitcher;

  /// Creates a new [PrivacyPolicy] with custom policies.
  const PrivacyPolicy({
    this.screenshot = ScreenshotPolicy.allow,
    this.appSwitcher = AppSwitcherPolicy.allow,
  });

  /// Standard policy: screenshots and app switcher previews are permitted.
  const PrivacyPolicy.standard()
      : screenshot = ScreenshotPolicy.allow,
        appSwitcher = AppSwitcherPolicy.allow;

  /// Strict policy: screenshots are blocked where supported, and app switcher is hidden.
  const PrivacyPolicy.strict()
      : screenshot = ScreenshotPolicy.block,
        appSwitcher = AppSwitcherPolicy.hide;

  /// Returns true if any privacy restrictions (screenshot blocking or app switcher obscuring) are active.
  bool get hasRestrictions =>
      screenshot != ScreenshotPolicy.allow ||
      appSwitcher != AppSwitcherPolicy.allow;

  /// Creates a copy of this [PrivacyPolicy] with optional overridden values.
  PrivacyPolicy copyWith({
    ScreenshotPolicy? screenshot,
    AppSwitcherPolicy? appSwitcher,
  }) {
    return PrivacyPolicy(
      screenshot: screenshot ?? this.screenshot,
      appSwitcher: appSwitcher ?? this.appSwitcher,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyPolicy &&
          runtimeType == other.runtimeType &&
          screenshot == other.screenshot &&
          appSwitcher == other.appSwitcher;

  @override
  int get hashCode => Object.hash(screenshot, appSwitcher);

  @override
  String toString() =>
      'PrivacyPolicy(screenshot: ${screenshot.name}, appSwitcher: ${appSwitcher.name})';
}
