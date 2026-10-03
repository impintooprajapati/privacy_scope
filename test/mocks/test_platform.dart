import 'dart:async';
import 'package:privacy_scope/privacy_scope.dart';

/// In-memory mock platform for testing without native dependencies.
class TestPrivacyPlatform extends PrivacyPlatform {
  final List<PrivacyPolicy> appliedPolicies = [];
  final StreamController<PrivacyPlatformEvent> eventController =
      StreamController<PrivacyPlatformEvent>.broadcast();

  bool captured = false;
  bool isDisposed = false;

  @override
  Future<void> applyPolicy(PrivacyPolicy policy) async {
    appliedPolicies.add(policy);
  }

  @override
  Stream<PrivacyPlatformEvent> get events => eventController.stream;

  @override
  Future<bool> isScreenCaptured() async {
    return captured;
  }

  void emitEvent(PrivacyPlatformEvent event) {
    eventController.add(event);
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await eventController.close();
  }
}
