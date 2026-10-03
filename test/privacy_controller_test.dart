import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_scope/privacy_scope.dart';
import 'mocks/test_platform.dart';

void main() {
  group('PrivacyController', () {
    late TestPrivacyPlatform platform;
    late PrivacyController controller;

    setUp(() {
      platform = TestPrivacyPlatform();
      controller = PrivacyController(platform: platform);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state defaults to standard policy', () {
      expect(controller.state.activePolicy,
          equals(const PrivacyPolicy.standard()));
      expect(controller.state.screenshotProtectionEnabled, isFalse);
      expect(
          controller.state.appSwitcherPolicy, equals(AppSwitcherPolicy.allow));
      expect(controller.activeRegistrations, isEmpty);
    });

    test('registering a scope applies policy and updates state', () async {
      final events = <PrivacyEvent>[];
      final sub = controller.events.listen(events.add);

      const strictPolicy = PrivacyPolicy.strict();
      final reg = controller.registerScope(policy: strictPolicy);

      expect(controller.activeRegistrations.length, equals(1));
      expect(controller.state.activePolicy, equals(strictPolicy));
      expect(controller.state.screenshotProtectionEnabled, isTrue);
      expect(
          controller.state.appSwitcherPolicy, equals(AppSwitcherPolicy.hide));

      // Check platform call
      expect(platform.appliedPolicies.length, equals(1));
      expect(platform.appliedPolicies.first, equals(strictPolicy));

      // Wait a microtask for broadcast stream
      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(
        events.first,
        equals(
          const PrivacyPolicyChanged(
            previous: PrivacyPolicy.standard(),
            current: strictPolicy,
          ),
        ),
      );

      await sub.cancel();
      controller.unregisterScope(reg);
    });

    test('unregistering scope restores previous baseline policy', () {
      const strictPolicy = PrivacyPolicy.strict();
      final reg = controller.registerScope(policy: strictPolicy);

      expect(controller.state.activePolicy, equals(strictPolicy));

      controller.unregisterScope(reg);

      expect(controller.activeRegistrations, isEmpty);
      expect(controller.state.activePolicy,
          equals(const PrivacyPolicy.standard()));
      expect(controller.state.screenshotProtectionEnabled, isFalse);
      expect(
          controller.state.appSwitcherPolicy, equals(AppSwitcherPolicy.allow));

      // Platform was called twice: once for strict, once to restore standard
      expect(platform.appliedPolicies.length, equals(2));
      expect(platform.appliedPolicies.last,
          equals(const PrivacyPolicy.standard()));
    });

    test('nested scope with higher depth takes priority over parent scope', () {
      const parentPolicy = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      const childPolicy = PrivacyPolicy.strict();

      final parentReg =
          controller.registerScope(policy: parentPolicy, depth: 0);
      expect(controller.state.activePolicy, equals(parentPolicy));

      final childReg = controller.registerScope(policy: childPolicy, depth: 1);
      expect(controller.state.activePolicy, equals(childPolicy));

      // Unregister child -> restores parent policy
      controller.unregisterScope(childReg);
      expect(controller.state.activePolicy, equals(parentPolicy));

      // Unregister parent -> restores standard
      controller.unregisterScope(parentReg);
      expect(controller.state.activePolicy,
          equals(const PrivacyPolicy.standard()));
    });

    test(
        'multiple scopes at same depth resolve by latest registration sequence',
        () {
      const policy1 = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      const policy2 = PrivacyPolicy.strict();

      final reg1 = controller.registerScope(policy: policy1, depth: 0);
      expect(controller.state.activePolicy, equals(policy1));

      final reg2 = controller.registerScope(policy: policy2, depth: 0);
      expect(controller.state.activePolicy, equals(policy2));

      // Unregistering latest scope reg2 restores reg1
      controller.unregisterScope(reg2);
      expect(controller.state.activePolicy, equals(policy1));

      controller.unregisterScope(reg1);
      expect(controller.state.activePolicy,
          equals(const PrivacyPolicy.standard()));
    });

    test('dynamic updateScope updates policy and recomputes effective policy',
        () {
      const initialPolicy = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      const updatedPolicy = PrivacyPolicy.strict();

      final reg = controller.registerScope(policy: initialPolicy);
      expect(controller.state.activePolicy, equals(initialPolicy));

      controller.updateScope(reg, updatedPolicy);
      expect(controller.state.activePolicy, equals(updatedPolicy));

      // Updating with identical policy does not trigger platform
      final callCount = platform.appliedPolicies.length;
      controller.updateScope(reg, updatedPolicy);
      expect(platform.appliedPolicies.length, equals(callCount));
    });

    test('does not reapply identical effective policy (deduplication)', () {
      // Registering a scope that equals the current policy (standard) shouldn't invoke platform
      const standard = PrivacyPolicy.standard();
      final reg = controller.registerScope(policy: standard);

      expect(platform.appliedPolicies, isEmpty);

      controller.unregisterScope(reg);
      expect(platform.appliedPolicies, isEmpty);
    });

    test('receives platform events and updates isCaptured state', () async {
      final events = <PrivacyEvent>[];
      final sub = controller.events.listen(events.add);

      platform.emitEvent(const PlatformScreenCaptureStarted());
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isCaptured, isTrue);
      expect(events.any((e) => e is ScreenCaptureDetected), isTrue);
      expect(events.any((e) => e is ScreenCaptureStarted), isTrue);

      platform.emitEvent(const PlatformScreenCaptureStopped());
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isCaptured, isFalse);
      expect(events.any((e) => e is ScreenCaptureStopped), isTrue);

      await sub.cancel();
    });

    test('refresh applies current effective policy to platform', () async {
      const strict = PrivacyPolicy.strict();
      controller.registerScope(policy: strict);

      expect(platform.appliedPolicies.length, equals(1));
      await controller.refresh();
      expect(platform.appliedPolicies.length, equals(2));
      expect(platform.appliedPolicies.last, equals(strict));
    });
  });
}
