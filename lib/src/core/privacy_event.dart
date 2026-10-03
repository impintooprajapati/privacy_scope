import 'package:meta/meta.dart';
import 'privacy_policy.dart';

/// Sealed base class representing privacy-related system and controller events.
@immutable
sealed class PrivacyEvent {
  const PrivacyEvent();
}

/// Emitted when the resolved active [PrivacyPolicy] changes.
@immutable
final class PrivacyPolicyChanged extends PrivacyEvent {
  /// The previously active policy.
  final PrivacyPolicy previous;

  /// The newly active policy.
  final PrivacyPolicy current;

  /// Creates a [PrivacyPolicyChanged] event.
  const PrivacyPolicyChanged({
    required this.previous,
    required this.current,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyPolicyChanged &&
          runtimeType == other.runtimeType &&
          previous == other.previous &&
          current == other.current;

  @override
  int get hashCode => Object.hash(previous, current);

  @override
  String toString() =>
      'PrivacyPolicyChanged(previous: $previous, current: $current)';
}

/// Emitted when screen recording, AirPlay mirroring, or external screen capture is detected.
@immutable
final class ScreenCaptureDetected extends PrivacyEvent {
  /// Creates a [ScreenCaptureDetected] event.
  const ScreenCaptureDetected();

  @override
  String toString() => 'ScreenCaptureDetected()';
}

/// Emitted when screen recording or capture has begun.
@immutable
final class ScreenCaptureStarted extends PrivacyEvent {
  /// Creates a [ScreenCaptureStarted] event.
  const ScreenCaptureStarted();

  @override
  String toString() => 'ScreenCaptureStarted()';
}

/// Emitted when screen recording or capture has stopped.
@immutable
final class ScreenCaptureStopped extends PrivacyEvent {
  /// Creates a [ScreenCaptureStopped] event.
  const ScreenCaptureStopped();

  @override
  String toString() => 'ScreenCaptureStopped()';
}
