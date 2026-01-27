// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:auramind_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuramindApp());

    // Verify that our initial screen is the Daily Check-in screen.
    expect(find.text('Daily Check-in'), findsOneWidget);
    expect(find.text('How are you feeling?'), findsOneWidget);

    // Verify that the navigation bar labels are present.
    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
