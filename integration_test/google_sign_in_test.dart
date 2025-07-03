import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lournal/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:lournal/firebase_options.dart';
import 'package:lournal/auth/google_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Ensure Firebase is initialized
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Google Sign-In Service
    await AuthService.instance.initialize();
    // Sign out any existing user to ensure a clean state
    await FirebaseAuth.instance.signOut();
  });

  testWidgets('Google Sign-In Flow', (WidgetTester tester) async {
    // 1. Start the app
    app.main();
    await tester.pumpAndSettle();

    // App should start on StartPage because the user is signed out.
    // 2. Navigate from StartPage to LoginPage
    final getStartedButton = find.widgetWithText(ElevatedButton, 'Get Started');
    expect(getStartedButton, findsOneWidget);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    // We are now on the LoginPage.
    // 3. Find and tap the "Continue with Google" button
    final googleSignInButton = find.widgetWithText(ElevatedButton, 'Continue with Google');
    expect(googleSignInButton, findsOneWidget);
    
    // This will trigger the native Google Sign-In UI.
    // In a test environment, this may auto-succeed or require manual interaction
    // if run on a real device. The test will wait for the result.
    await tester.tap(googleSignInButton);

    // 4. Wait for the sign-in process to complete and the UI to update.
    // We expect to be navigated to the NotesPage upon success.
    // We'll wait for a reasonable amount of time for the async operation to finish.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // 5. Verify that we have landed on the NotesPage.
    // We can check for a widget that is unique to the NotesPage, like the profile button.
    final profileButton = find.byKey(const Key('profile_button'));
    expect(profileButton, findsOneWidget, reason: "Should navigate to NotesPage after successful Google Sign-In");

    // Optional: Sign out to leave the app in a clean state
    await FirebaseAuth.instance.signOut();
    await tester.pumpAndSettle();
  });
}
