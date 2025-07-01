import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'test_helpers.dart'; // Import the helpers

void main() async {
  await dotenv.load(fileName: ".env");
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    // testWidgets('logs in successfully and displays the notes screen',
    //     (WidgetTester tester) async {
    //   // This test confirms the login function works as expected.
    //   await performLogin(tester);
    // });

    // --- YOUR NEW LOGOUT TEST ---
    testWidgets('logs out successfully and returns to the start screen',
        (WidgetTester tester) async {
      // First, log in to get to the notes screen.
      await performLogin(tester);

      // Now, perform and verify the logout action.
      await performLogout(tester);
    });
  });
}