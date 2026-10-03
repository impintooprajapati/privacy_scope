import 'package:meta/meta.dart';

/// Sealed class representing events sent from the native platform layer.
@immutable
sealed class PrivacyPlatformEvent {
  const PrivacyPlatformEvent();
}

/// Native platform notified that screen capture / recording started.
@immutable
final class PlatformScreenCaptureStarted extends PrivacyPlatformEvent {
  const PlatformScreenCaptureStarted();
}

/// Native platform notified that screen capture / recording stopped.
@immutable
final class PlatformScreenCaptureStopped extends PrivacyPlatformEvent {
  const PlatformScreenCaptureStopped();
}
