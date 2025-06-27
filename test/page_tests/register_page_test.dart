import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/pages/register_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the generated mocks file
import 'register_page_test.mocks.dart';

// Generate mocks for Firebase Auth classes
@GenerateMocks([FirebaseAuth, User, UserCredential])

// A helper function to wrap widgets in a MaterialApp for testing
Widget createTestableWidget({required Widget child}) {
  return MaterialApp(
    // Mock CustomSnackBar's scaffold messenger
    scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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

    // Default mock behavior for a successful registration
    when(mockAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async {
      // Add a small delay to simulate a network call
      // This ensures the loading indicator is visible before the mock completes.
      await Future.delayed(const Duration(milliseconds: 50));
      when(mockUser.sendEmailVerification()).thenAnswer((_) async {});
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
      when(mockUserCredential.user).thenReturn(mockUser);
      return mockUserCredential;
    });

    // Mock the signOut method
    when(mockAuth.signOut()).thenAnswer((_) async {});
  });

  // Helper function to find text fields by hint text
  Finder findTextField(String hint) => find.widgetWithText(MyTextField, hint);

  group('RegisterPage UI & Interaction', () {
    testWidgets('renders all initial widgets correctly',
        (WidgetTester tester) async {
      // Pass the mockAuth instance
      await tester.pumpWidget(createTestableWidget(
          child: RegisterPage(
        auth: mockAuth,
      )));

      expect(find.text('Sign Up'), findsNWidgets(2));
      expect(find.text('Sync your notes across devices'), findsOneWidget);
      expect(findTextField('Username'), findsOneWidget);
      expect(findTextField('Email'), findsOneWidget);
      expect(findTextField('Password'), findsOneWidget);
      expect(findTextField('Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text(' Login here'), findsOneWidget);
      
      // Use a more robust finder for the RichText widget
      expect(
          find.byWidgetPredicate((widget) =>
              widget is RichText &&
              widget.text.toPlainText().startsWith('By signing up')),
          findsOneWidget);
    });

    testWidgets('clears error states when user types in fields',
        (WidgetTester tester) async {
      // Arrange: Start with an error state by triggering multiple errors
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'weak-password'));

      // Pass the mockAuth instance
      await tester.pumpWidget(createTestableWidget(
          child: RegisterPage(
        auth: mockAuth,
      )));

      // Add a username so validation proceeds to the password check
      await tester.enterText(findTextField('Username'), 'testuser');
      await tester.enterText(findTextField('Password'), '123');
      await tester.enterText(findTextField('Confirm Password'), '456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Assert: Verify fields have errors (Password error is now correctly set)
      expect(
          tester.widget<MyTextField>(findTextField('Username')).hasError, isFalse); // Username is valid
      expect(
          tester.widget<MyTextField>(findTextField('Password')).hasError, isTrue);
      expect(
          tester.widget<MyTextField>(findTextField('Confirm Password')).hasError,
          isTrue);

      // Act & Assert: Type in password field to clear password errors
      await tester.enterText(findTextField('Password'), 'b');
      await tester.pump();
      expect(
          tester.widget<MyTextField>(findTextField('Password')).hasError, isFalse);
      expect(
          tester.widget<MyTextField>(findTextField('Confirm Password')).hasError,
          isFalse);
    });

    testWidgets('focus moves correctly between fields on submit',
        (WidgetTester tester) async {
      // Pass the mockAuth instance
      await tester.pumpWidget(createTestableWidget(
          child: RegisterPage(
        auth: mockAuth,
      )));

      final usernameField = findTextField('Username');
      final emailField = findTextField('Email');
      final passwordField = findTextField('Password');
      final confirmPasswordField = findTextField('Confirm Password');

      // Helper to check focus
      bool hasFocus(Finder finder) =>
          tester.widget<MyTextField>(finder).focusNode?.hasFocus ?? false;

      // From Username to Email
      await tester.tap(usernameField);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(hasFocus(emailField), isTrue);

      // From Email to Password
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(hasFocus(passwordField), isTrue);

      // From Password to Confirm Password
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(hasFocus(confirmPasswordField), isTrue);
    });
  });

  group('Registration Logic with Mocks', () {
    testWidgets('shows error and highlights field for empty username',
        (WidgetTester tester) async {
      // Pass the mockAuth instance
      await tester.pumpWidget(createTestableWidget(
          child: RegisterPage(
        auth: mockAuth,
      )));

      // Act
      await tester.enterText(findTextField('Email'), 'test@test.com');
      await tester.enterText(findTextField('Password'), 'password123');
      await tester.enterText(findTextField('Confirm Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Username cannot be empty'), findsOneWidget);
      expect(tester.widget<MyTextField>(findTextField('Username')).hasError, isTrue);
      verifyNever(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'), password: anyNamed('password')));
    });

    testWidgets('shows error and highlights fields for non-matching passwords',
        (WidgetTester tester) async {
      // Pass the mockAuth instance
      await tester.pumpWidget(createTestableWidget(
          child: RegisterPage(
        auth: mockAuth,
      )));

      // Act
      await tester.enterText(findTextField('Username'), 'testuser');
      await tester.enterText(findTextField('Email'), 'test@test.com');
      await tester.enterText(findTextField('Password'), 'password123');
      await tester.enterText(findTextField('Confirm Password'), 'password456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(
          tester.widget<MyTextField>(findTextField('Password')).hasError, isTrue);
      expect(
          tester.widget<MyTextField>(findTextField('Confirm Password')).hasError,
          isTrue);
      verifyNever(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'), password: anyNamed('password')));
    });

    // Test each Firebase Auth error code and the corresponding UI response
    for (var error in [
      {
        'code': 'invalid-email',
        'message': 'The email address is badly formatted.',
        'field': 'Email'
      },
      {
        'code': 'email-already-in-use',
        'message':
            'The email address is already in use by another account.',
        'field': 'Email'
      },
      {
        'code': 'weak-password',
        'message': 'The password provided is too weak.',
        'field': 'Password'
      },
    ]) {
      testWidgets('shows error state and snackbar for ${error['code']}',
          (WidgetTester tester) async {
        final errorCode = error['code']!;
        final errorMessage = error['message']!;
        final errorField = error['field']!;

        // Arrange: Set up the mock to throw the specific error
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(code: errorCode, message: errorMessage));

        // Pass the mockAuth instance
        await tester.pumpWidget(createTestableWidget(
            child: RegisterPage(
          auth: mockAuth,
        )));

        // Act
        await tester.enterText(findTextField('Username'), 'testuser');
        await tester.enterText(findTextField('Email'), 'test@test.com');
        await tester.enterText(findTextField('Password'), '123456');
        await tester.enterText(findTextField('Confirm Password'), '123456');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
        await tester.pumpAndSettle();

        // Assert: Check for the snackbar message
        expect(find.text(errorMessage), findsOneWidget);

        // Assert: Check that the UI shows the correct error state
        if (errorField == 'Email') {
          expect(tester.widget<MyTextField>(findTextField('Email')).hasError, isTrue);
        } else if (errorField == 'Password') {
          expect(tester.widget<MyTextField>(findTextField('Password')).hasError, isTrue);
           expect(tester.widget<MyTextField>(findTextField('Confirm Password')).hasError, isTrue);
        }
      });
    }

    testWidgets('successful registration pops page',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  // Pass the mockAuth instance
                  builder: (_) => RegisterPage(auth: mockAuth),
                )),
                child: const Text('Go to Register'),
              ),
            ),
          ),
        ),
      ));

      // Navigate to the register page so there's a route to pop
      await tester.tap(find.text('Go to Register'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);

      // Act: Enter valid data and tap sign up
      const username = ' newuser ';
      const email = 'new@example.com';
      const password = 'password123';

      await tester.enterText(findTextField('Username'), username);
      await tester.enterText(findTextField('Email'), email);
      await tester.enterText(findTextField('Password'), password);
      await tester.enterText(findTextField('Confirm Password'), password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));

      // Assert: loading circle is shown. Pump a frame to show the dialog.
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let all animations and futures complete for the registration itself
      await tester.pumpAndSettle();

      // Assert: Verify correct methods were called
      verify(mockAuth.createUserWithEmailAndPassword(email: email, password: password)).called(1);
      verify(mockUser.sendEmailVerification()).called(1);
      verify(mockUser.updateDisplayName(username.trim())).called(1);
      // --- FIXED: Verify that signOut is now called ---
      verify(mockAuth.signOut()).called(1);
      
      // --- FIXED: Remove check for snackbar that no longer exists ---
      
      // Assert: We are back on the initial page, meaning RegisterPage was popped.
      // The pumpAndSettle above is enough since there is no longer a delay.
      expect(find.byType(RegisterPage), findsNothing);
      expect(find.text('Go to Register'), findsOneWidget);
    });
  });
}
