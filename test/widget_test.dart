import 'package:flutter_test/flutter_test.dart';
import 'package:swiggy_ui/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that login screen is shown (Foodora text exists)
    expect(find.text('Foodora'), findsOneWidget);
    expect(find.text('LOGIN / SIGN UP'), findsOneWidget);
  });
}
