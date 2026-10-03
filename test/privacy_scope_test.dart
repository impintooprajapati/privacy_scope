import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_scope/privacy_scope.dart';
import 'mocks/test_platform.dart';

void main() {
  group('PrivacyScope Widget', () {
    late TestPrivacyPlatform platform;
    late PrivacyController controller;

    setUp(() {
      platform = TestPrivacyPlatform();
      controller = PrivacyController(platform: platform);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('registers policy on mount and unregisters on dispose',
        (WidgetTester tester) async {
      const strictPolicy = PrivacyPolicy.strict();

      await tester.pumpWidget(
        MaterialApp(
          home: PrivacyScope(
            controller: controller,
            policy: strictPolicy,
            child: const Text('Sensitive Content'),
          ),
        ),
      );

      expect(controller.state.activePolicy, equals(strictPolicy));
      expect(platform.appliedPolicies.last, equals(strictPolicy));

      // Remove the widget by pumping another one
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('Non-sensitive Content'),
        ),
      );

      // Policy restored to standard
      expect(controller.state.activePolicy,
          equals(const PrivacyPolicy.standard()));
      expect(platform.appliedPolicies.last,
          equals(const PrivacyPolicy.standard()));
    });

    testWidgets('updates policy when widget updates',
        (WidgetTester tester) async {
      const policy1 = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      const policy2 = PrivacyPolicy.strict();

      await tester.pumpWidget(
        MaterialApp(
          home: PrivacyScope(
            controller: controller,
            policy: policy1,
            child: const Text('Content'),
          ),
        ),
      );

      expect(controller.state.activePolicy, equals(policy1));

      // Update widget with policy2
      await tester.pumpWidget(
        MaterialApp(
          home: PrivacyScope(
            controller: controller,
            policy: policy2,
            child: const Text('Content'),
          ),
        ),
      );

      expect(controller.state.activePolicy, equals(policy2));
      expect(platform.appliedPolicies.last, equals(policy2));
    });

    testWidgets('nested scopes take priority and restore parent on disposal',
        (WidgetTester tester) async {
      const parentPolicy = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      const childPolicy = PrivacyPolicy.strict();

      bool showChild = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return PrivacyScope(
                controller: controller,
                policy: parentPolicy,
                child: Column(
                  children: [
                    const Text('Parent Area'),
                    if (showChild)
                      PrivacyScope(
                        controller: controller,
                        policy: childPolicy,
                        child: const Text('Child Area'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Child policy should be active
      expect(controller.state.activePolicy, equals(childPolicy));

      // Hide child
      showChild = false;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return PrivacyScope(
                controller: controller,
                policy: parentPolicy,
                child: Column(
                  children: [
                    const Text('Parent Area'),
                    if (showChild)
                      PrivacyScope(
                        controller: controller,
                        policy: childPolicy,
                        child: const Text('Child Area'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Parent policy should be restored
      expect(controller.state.activePolicy, equals(parentPolicy));
    });

    testWidgets('PrivacyScope.of and maybeOf return nearest policy',
        (WidgetTester tester) async {
      const outerPolicy = PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      );
      const innerPolicy = PrivacyPolicy.strict();

      PrivacyPolicy? resolvedOuter;
      PrivacyPolicy? resolvedInner;
      PrivacyPolicy? resolvedOutside;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolvedOutside = PrivacyScope.maybeOf(context);
              return PrivacyScope(
                controller: controller,
                policy: outerPolicy,
                child: Builder(
                  builder: (innerContext) {
                    resolvedOuter = PrivacyScope.of(innerContext);
                    return PrivacyScope(
                      controller: controller,
                      policy: innerPolicy,
                      child: Builder(
                        builder: (deepContext) {
                          resolvedInner = PrivacyScope.of(deepContext);
                          return const Text('Deep');
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(resolvedOutside, isNull);
      expect(resolvedOuter, equals(outerPolicy));
      expect(resolvedInner, equals(innerPolicy));
    });

    testWidgets('navigation push and pop automatically updates active policy',
        (WidgetTester tester) async {
      const homePolicy = PrivacyPolicy.standard();
      const secretPolicy = PrivacyPolicy.strict();

      await tester.pumpWidget(
        MaterialApp(
          home: PrivacyScope(
            controller: controller,
            policy: homePolicy,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PrivacyScope(
                          controller: controller,
                          policy: secretPolicy,
                          child: const Scaffold(
                            body: Text('Secret Screen'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Secret'),
                );
              },
            ),
          ),
        ),
      );

      expect(controller.state.activePolicy, equals(homePolicy));

      // Push secret screen
      await tester.tap(find.text('Open Secret'));
      await tester.pumpAndSettle();

      expect(controller.state.activePolicy, equals(secretPolicy));
      expect(find.text('Secret Screen'), findsOneWidget);

      // Pop secret screen
      final navigatorState =
          tester.state<NavigatorState>(find.byType(Navigator));
      navigatorState.pop();
      await tester.pumpAndSettle();

      expect(controller.state.activePolicy, equals(homePolicy));
    });
  });
}
