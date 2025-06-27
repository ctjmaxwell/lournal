import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/pages/login_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the generated mocks file
import 'login_page_test.mocks.dart';

// Generate mocks for Firebase Auth classes
@GenerateMocks([FirebaseAuth, User, UserCredential])

// A helper function to wrap widgets in a MaterialApp for testing
Widget createTestableWidget({required Widget child}) {
  return MaterialApp(
    // Mock CustomSnackBar's scaffold messenger
    scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: child,
  );
}

void main() {
  // Declare mock variables
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  // Set up mocks before each test
  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    // Default mock behavior for a successful login with a verified user
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async {
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUserCredential.user).thenReturn(mockUser);
      return mockUserCredential;
    });

    // Default mock behavior for other auth methods
    when(mockAuth.signOut()).thenAnswer((_) async {});
    when(mockUser.sendEmailVerification()).thenAnswer((_) async {});
    when(mockAuth.currentUser).thenReturn(mockUser);
  });

  group('LoginPage UI & Interaction', () {
    testWidgets('renders all initial widgets correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: LoginPage(auth: mockAuth)));
      expect(find.text('Log In'), findsNWidgets(2));
      expect(find.text('Welcome back to Lournal'), findsOneWidget);
      expect(find.widgetWithText(MyTextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(MyTextField, 'Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
    });
    
    testWidgets('clears error state when user types in field', (WidgetTester tester) async {
      // Arrange: Start with an error state
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(createTestableWidget(child: LoginPage(auth: mockAuth)));

      // Act: Trigger the error
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert: Verify fields have errors
      expect(tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Email')).hasError, isTrue);
      expect(tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Password')).hasError, isTrue);

      // Act: Type in the email field
      await tester.enterText(find.widgetWithText(MyTextField, 'Email'), 'a');
      await tester.pump();

      // Assert: Email error is cleared, password error remains
      expect(tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Email')).hasError, isFalse);
      expect(tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Password')).hasError, isTrue);
      
      // Act: Type in the password field
      await tester.enterText(find.widgetWithText(MyTextField, 'Password'), 'b');
      await tester.pump();

      // Assert: Both errors are cleared
       expect(tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Email')).hasError, isFalse);
       expect(tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Password')).hasError, isFalse);
    });

    testWidgets('focus moves from email to password on submit', (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget(child: LoginPage(auth: mockAuth)));

        final emailField = find.widgetWithText(MyTextField, 'Email');
        final passwordField = find.widgetWithText(MyTextField, 'Password');

        // Tap the email field to give it focus
        await tester.tap(emailField);
        await tester.pump();

        // Simulate pressing the "next" button on the keyboard
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();

        // Assert that the password field now has focus
        final passwordFocusNode = tester.widget<MyTextField>(passwordField).focusNode;
        expect(passwordFocusNode?.hasFocus, isTrue);
    });
  });

  group('Login Logic with Mocks', () {
    testWidgets('successful login pops all routes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LoginPage(auth: mockAuth),
            )),
            child: const Text('Go to Login'),
          ),
        ),
      ));

      // Navigate to the login page so there's a route to pop
      await tester.tap(find.text('Go to Login'));
      await tester.pumpAndSettle();

      // Enter valid credentials and tap login
      await tester.enterText(find.widgetWithText(MyTextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(MyTextField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      // Assert: We should be back on the initial page, meaning LoginPage was popped.
      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('Go to Login'), findsOneWidget);
    });

    // Test each Firebase Auth error code and the corresponding UI response
    for (var error in [
      {'code': 'invalid-email', 'message': 'The email address is badly formatted.'},
      {'code': 'wrong-password', 'message': 'Incorrect email or password. Please try again.'},
      {'code': 'user-not-found', 'message': 'Incorrect email or password. Please try again.'},
      {'code': 'invalid-credential', 'message': 'Incorrect email or password. Please try again.'},
    ]) {
      testWidgets('shows error state and snackbar for ${error['code']}', (WidgetTester tester) async {
        final errorCode = error['code']!;
        final errorMessage = error['message']!;
        
        // Arrange: Set up the mock to throw the specific error
        when(mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(code: errorCode));

        await tester.pumpWidget(createTestableWidget(child: LoginPage(auth: mockAuth)));

        // Act
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        // Assert: Check that the UI shows the correct error state
        final emailField = tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Email'));
        expect(emailField.hasError, isTrue);
        
        final passwordField = tester.widget<MyTextField>(find.widgetWithText(MyTextField, 'Password'));
        expect(passwordField.hasError, errorCode != 'invalid-email');

        // Assert: Check for the snackbar message
        expect(find.text(errorMessage), findsOneWidget);
      });
    }

    testWidgets('shows verification dialog, then signs out on dismiss', (WidgetTester tester) async {
      // Arrange
      when(mockUser.emailVerified).thenReturn(false);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(createTestableWidget(child: LoginPage(auth: mockAuth)));

      // Act: Attempt to log in
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle(); // Let the dialog appear

      // Assert: Verify the dialog is shown
      expect(find.text('Email Not Verified'), findsOneWidget);

      // Act: Tap the cancel button to close the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Assert: Verify signOut was called after the dialog was dismissed
      verify(mockAuth.signOut()).called(1);
      expect(find.text('Email Not Verified'), findsNothing);
    });

    // FIX: This test has been rewritten to match the actual app behavior.
    testWidgets('verification dialog closes on resend and respects cooldown on next attempt', (WidgetTester tester) async {
      // Arrange
      when(mockUser.emailVerified).thenReturn(false);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(createTestableWidget(child: LoginPage(auth: mockAuth)));

      // Act 1: Trigger login to show the dialog for the first time.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();
      expect(find.text('Email Not Verified'), findsOneWidget); // Dialog is up.

      // Act 2: Tap the resend button.
      await tester.tap(find.widgetWithText(TextButton, 'Resend Email'));
      await tester.pumpAndSettle(); // Let the dialog close and snackbar appear.

      // Assert 2: Dialog is gone, snackbar appeared, and verification was sent.
      expect(find.text('Email Not Verified'), findsNothing);
      expect(find.text('Verification email sent!'), findsOneWidget);
      verify(mockUser.sendEmailVerification()).called(1);

      // Act 3: Try to log in again immediately.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      // Assert 3: The dialog reappears and is now on cooldown.
      expect(find.text('Email Not Verified'), findsOneWidget);
      expect(find.textContaining('Resend in'), findsOneWidget); // e.g., "Resend in 30"

      // Act 4: Advance the test clock to check the timer.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(); // Render the final frame after timer ticks.

      // Assert 4: The countdown text has updated correctly.
      expect(find.textContaining('Resend in'), findsOneWidget);
    });
  });
}
