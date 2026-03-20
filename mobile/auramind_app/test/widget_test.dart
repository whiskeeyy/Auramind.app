// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auramind_app/main.dart';

class MockLocalStorage extends LocalStorage {
  const MockLocalStorage();
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() async => null;
  @override
  Future<bool> hasAccessToken() async => false;
  @override
  Future<void> removePersistedSession() async {}
  @override
  Future<void> persistSession(String session) async {}
}

void main() {
  setUpAll(() async {
    // Initialize Supabase with dummy values for testing
    // We use pkce flow and disable session persistence to avoid MissingPluginException (shared_preferences)
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholder-anon-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
      ),
    );
  });

  testWidgets('App starts at Login screen when not authenticated', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuramindApp());
    await tester.pumpAndSettle(); // Wait for navigation/auth check logic

    // Since we aren't authenticated in the mock environment, 
    // AuthWrapper should show the Login Screen.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    
    // Verify logo/title exists
    expect(find.text('AuraMind'), findsOneWidget);
  });
}
