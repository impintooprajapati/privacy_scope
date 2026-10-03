import 'package:meta/meta.dart';
import 'privacy_policy.dart';

/// Represents the current resolved privacy state managed by the system.
@immutable
class PrivacyState {
  /// The currently active effective [PrivacyPolicy].
  final PrivacyPolicy activePolicy;

  /// Whether native screenshot protection is currently requested/enabled.
  final bool screenshotProtectionEnabled;

  /// The active app switcher protection policy.
  final AppSwitcherPolicy appSwitcherPolicy;

  /// Whether active screen capture (such as iOS screen recording or mirroring) is currently detected.
  final bool isCaptured;

  /// Creates a new [PrivacyState] snapshot.
  const PrivacyState({
    required this.activePolicy,
    required this.screenshotProtectionEnabled,
    required this.appSwitcherPolicy,
    this.isCaptured = false,
  });

  /// Default baseline state before any restrictive scopes are registered.
  const PrivacyState.initial()
      : activePolicy = const PrivacyPolicy.standard(),
        screenshotProtectionEnabled = false,
        appSwitcherPolicy = AppSwitcherPolicy.allow,
        isCaptured = false;

  /// Creates a copy of this [PrivacyState] with optional overridden values.
  PrivacyState copyWith({
    PrivacyPolicy? activePolicy,
    bool? screenshotProtectionEnabled,
    AppSwitcherPolicy? appSwitcherPolicy,
    bool? isCaptured,
  }) {
    return PrivacyState(
      activePolicy: activePolicy ?? this.activePolicy,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
      appSwitcherPolicy: appSwitcherPolicy ?? this.appSwitcherPolicy,
      isCaptured: isCaptured ?? this.isCaptured,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyState &&
          runtimeType == other.runtimeType &&
          activePolicy == other.activePolicy &&
          screenshotProtectionEnabled == other.screenshotProtectionEnabled &&
          appSwitcherPolicy == other.appSwitcherPolicy &&
          isCaptured == other.isCaptured;

  @override
  int get hashCode => Object.hash(
        activePolicy,
        screenshotProtectionEnabled,
        appSwitcherPolicy,
        isCaptured,
      );

  @override
  String toString() =>
      'PrivacyState(activePolicy: $activePolicy, screenshotProtection: $screenshotProtectionEnabled, appSwitcher: ${appSwitcherPolicy.name}, isCaptured: $isCaptured)';
}
