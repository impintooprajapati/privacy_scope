import '../core/privacy_policy.dart';
import 'privacy_method_channel.dart';
import 'privacy_platform_event.dart';

/// The interface that platform-specific implementations of `privacy_scope` must implement.
abstract class PrivacyPlatform {
  static PrivacyPlatform _instance = MethodChannelPrivacyPlatform();

  /// The default instance of [PrivacyPlatform] to use.
  static PrivacyPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PrivacyPlatform] when they register themselves.
  static set instance(PrivacyPlatform instance) {
    _instance = instance;
  }

  /// Applies the effective [PrivacyPolicy] to the native platform.
  Future<void> applyPolicy(PrivacyPolicy policy);

  /// Stream of native privacy events (e.g. screen recording/capture triggers).
  Stream<PrivacyPlatformEvent> get events;

  /// Returns whether screen capture or recording is currently active on the device.
  Future<bool> isScreenCaptured();

  /// Releases resources held by the platform implementation.
  Future<void> dispose();
}
