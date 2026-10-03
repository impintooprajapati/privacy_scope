import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_scope/privacy_scope.dart';

void main() {
  group('PrivacyPolicy', () {
    test('default constructor creates allow/allow policy', () {
      const policy = PrivacyPolicy();
      expect(policy.screenshot, equals(ScreenshotPolicy.allow));
      expect(policy.appSwitcher, equals(AppSwitcherPolicy.allow));
      expect(policy.hasRestrictions, isFalse);
    });

    test('standard constructor creates allow/allow policy', () {
      const policy = PrivacyPolicy.standard();
      expect(policy.screenshot, equals(ScreenshotPolicy.allow));
      expect(policy.appSwitcher, equals(AppSwitcherPolicy.allow));
      expect(policy.hasRestrictions, isFalse);
    });

    test('strict constructor creates block/hide policy', () {
      const policy = PrivacyPolicy.strict();
      expect(policy.screenshot, equals(ScreenshotPolicy.block));
      expect(policy.appSwitcher, equals(AppSwitcherPolicy.hide));
      expect(policy.hasRestrictions, isTrue);
    });

    test('custom values and hasRestrictions reflect accurately', () {
      const policy1 = PrivacyPolicy(
        screenshot: ScreenshotPolicy.block,
        appSwitcher: AppSwitcherPolicy.allow,
      );
      expect(policy1.hasRestrictions, isTrue);

      const policy2 = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      expect(policy2.hasRestrictions, isTrue);
    });

    test('equality and hashCode work as expected', () {
      const standard1 = PrivacyPolicy.standard();
      const standard2 = PrivacyPolicy();
      const strict = PrivacyPolicy.strict();

      expect(standard1, equals(standard2));
      expect(standard1.hashCode, equals(standard2.hashCode));
      expect(standard1, isNot(equals(strict)));
    });

    test('copyWith updates specified fields correctly', () {
      const initial = PrivacyPolicy.standard();

      final updatedScreenshot =
          initial.copyWith(screenshot: ScreenshotPolicy.block);
      expect(updatedScreenshot.screenshot, equals(ScreenshotPolicy.block));
      expect(updatedScreenshot.appSwitcher, equals(AppSwitcherPolicy.allow));

      final updatedAppSwitcher =
          initial.copyWith(appSwitcher: AppSwitcherPolicy.blur);
      expect(updatedAppSwitcher.screenshot, equals(ScreenshotPolicy.allow));
      expect(updatedAppSwitcher.appSwitcher, equals(AppSwitcherPolicy.blur));

      final unchanged = initial.copyWith();
      expect(unchanged, equals(initial));
    });

    test('toString formats meaningfully', () {
      const policy = PrivacyPolicy.strict();
      expect(policy.toString(), contains('screenshot: block'));
      expect(policy.toString(), contains('appSwitcher: hide'));
    });
  });

  group('PrivacyState', () {
    test('initial state defaults correctly', () {
      const state = PrivacyState.initial();
      expect(state.activePolicy, equals(const PrivacyPolicy.standard()));
      expect(state.screenshotProtectionEnabled, isFalse);
      expect(state.appSwitcherPolicy, equals(AppSwitcherPolicy.allow));
      expect(state.isCaptured, isFalse);
    });

    test('copyWith and equality operate correctly', () {
      const state = PrivacyState.initial();
      final updated = state.copyWith(
        activePolicy: const PrivacyPolicy.strict(),
        screenshotProtectionEnabled: true,
        appSwitcherPolicy: AppSwitcherPolicy.hide,
        isCaptured: true,
      );

      expect(updated.screenshotProtectionEnabled, isTrue);
      expect(updated.appSwitcherPolicy, equals(AppSwitcherPolicy.hide));
      expect(updated.isCaptured, isTrue);
      expect(updated, isNot(equals(state)));
      expect(updated.toString(), contains('screenshotProtection: true'));
    });
  });

  group('PrivacyEvent', () {
    test('PrivacyPolicyChanged equality and properties', () {
      const event1 = PrivacyPolicyChanged(
        previous: PrivacyPolicy.standard(),
        current: PrivacyPolicy.strict(),
      );
      const event2 = PrivacyPolicyChanged(
        previous: PrivacyPolicy.standard(),
        current: PrivacyPolicy.strict(),
      );

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
      expect(event1.toString(), contains('previous'));
    });

    test('ScreenCapture event strings', () {
      expect(const ScreenCaptureDetected().toString(),
          equals('ScreenCaptureDetected()'));
      expect(const ScreenCaptureStarted().toString(),
          equals('ScreenCaptureStarted()'));
      expect(const ScreenCaptureStopped().toString(),
          equals('ScreenCaptureStopped()'));
    });
  });
}
