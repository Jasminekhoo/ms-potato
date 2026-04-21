import 'package:flutter_test/flutter_test.dart';

import 'package:ai_rent_advisor/app.dart';

void main() {
  testWidgets('App renders home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const AiRentAdvisorApp());
    await tester.pumpAndSettle();

    expect(find.text('AI Rent Advisor'), findsOneWidget);
  });
}
