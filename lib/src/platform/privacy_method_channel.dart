import 'dart:async';
import 'package:flutter/services.dart';
import '../core/privacy_policy.dart';
import 'privacy_platform.dart';
import 'privacy_platform_event.dart';

/// An implementation of [PrivacyPlatform] that uses method and event channels.
class MethodChannelPrivacyPlatform extends PrivacyPlatform {
  /// The method channel used to interact with the native platform.
  final MethodChannel methodChannel;

  /// The event channel used to receive platform notifications.
  final EventChannel eventChannel;

  Stream<PrivacyPlatformEvent>? _eventStream;

  /// Creates a [MethodChannelPrivacyPlatform] instance.
  MethodChannelPrivacyPlatform({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : methodChannel =
            methodChannel ?? const MethodChannel('privacy_scope/methods'),
        eventChannel =
            eventChannel ?? const EventChannel('privacy_scope/events');

  @override
  Future<void> applyPolicy(PrivacyPolicy policy) async {
    await methodChannel.invokeMethod<void>('applyPolicy', {
      'screenshot': policy.screenshot.name,
      'appSwitcher': policy.appSwitcher.name,
    });
  }

  @override
  Stream<PrivacyPlatformEvent> get events {
    _eventStream ??= eventChannel
        .receiveBroadcastStream()
        .map<PrivacyPlatformEvent>((dynamic event) {
      if (event == 'capture_started') {
        return const PlatformScreenCaptureStarted();
      } else if (event == 'capture_stopped') {
        return const PlatformScreenCaptureStopped();
      }
      return const PlatformScreenCaptureStarted();
    });
    return _eventStream!;
  }

  @override
  Future<bool> isScreenCaptured() async {
    try {
      final captured =
          await methodChannel.invokeMethod<bool>('isScreenCaptured');
      return captured ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _eventStream = null;
  }
}
