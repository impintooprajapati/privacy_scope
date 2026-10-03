import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Renders PrivacyScopeExampleApp and HomeScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PrivacyScopeExampleApp());
    expect(find.text('PrivacyScope Demo'), findsOneWidget);
    expect(find.text('Select a Demo Scenario:'), findsOneWidget);
  });
}
