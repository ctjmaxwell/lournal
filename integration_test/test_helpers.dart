import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lournal/main.dart' as app;
import 'package:lournal/components/my_textfield.dart';

// Your reusable login function now lives here
Future<void> performLogin(WidgetTester tester) async {
  final email = dotenv.env['TEST_USER_EMAIL'];
  final password = dotenv.env['TEST_USER_PASSWORD'];

  if (email == null || password == null) {
    throw Exception("Test credentials not found in .env file.");
  }

  app.main();
  await tester.pumpAndSettle();

  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(MyTextField, 'Email'), email);
  await tester.enterText(find.widgetWithText(MyTextField, 'Password'), password);

  final logInButton = find.descendant(
    of: find.byType(ElevatedButton),
    matching: find.text('Log In'),
  );
  await tester.tap(logInButton);

  await tester.pumpAndSettle(const Duration(seconds: 5));
  expect(find.text('Search your Lournals…'), findsOneWidget);
}


// 🚀 NEW REUSABLE LOGOUT FUNCTION
// This function handles the entire logout flow.
Future<void> performLogout(WidgetTester tester) async {
  // Add a final pump to ensure the UI is 100% stable before we search.
  await tester.pump(const Duration(seconds: 10)); 

  // 1. On the NotesPage, find the profile icon and tap it to open the bottom sheet.
  await tester.tap(find.byKey(const Key('profile_button')));
  // Wait for the bottom sheet to animate into view.
  await tester.pumpAndSettle();

  // 2. In the bottom sheet, find the "Log Out" button and tap it.
  await tester.tap(find.text('Log Out'));
  // Wait for sign-out and navigation back to the AuthPage, which shows the StartPage.
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // 3. Verify that the logout was successful by checking for the "Get Started" button.
  expect(find.text('Get Started'), findsOneWidget);
  // Also, verify that a widget from the notes page is no longer visible.
  expect(find.text('Search your Lournals…'), findsNothing);
}