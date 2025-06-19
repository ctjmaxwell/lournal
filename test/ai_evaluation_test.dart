// Import the Flutter test framework
import 'package:flutter_test/flutter_test.dart';

// Import the Firebase packages we need
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:lournal/firebase_options.dart';

// Import our list of test cases!
import 'ai_test_cases.dart';
void main() {
  // ADD THIS LINE! This is the fix.
  // It "turns on the power" for the test environment.
  TestWidgetsFlutterBinding.ensureInitialized();
  // This special function runs ONCE before all tests in this file.
  // It's crucial for initializing services like Firebase.
  setUpAll(() async {
    // We must initialize the Firebase app before we can use its services.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  // Group our AI tests together for clean output
  group('AI Cloud Function Evaluation', () {
    // HERE IS THE LOOP YOU ASKED FOR!
    // This code iterates through every test case in your list.
    for (final testCase in aiTestCases) {

      // 'test' defines a single, runnable test.
      // We use the description from our test case to know which one is running.
      test('should handle: ${testCase['description']}', () async {

        // Get the 'input' data and 'expected' outcomes for this specific test run.
        final inputData = testCase['input'] as Map<String, dynamic>;
        final expectedOutcomes = testCase['expected'] as Map<String, dynamic>;

        // We wrap the function call in a try/catch block so our test runner
        // can handle both successful calls and EXPECTED failures gracefully.
        try {
          // --- THIS IS YOUR EXACT LOGIC ---
          final HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable('processNoteWithAI');
          final result = await callable.call(inputData);
          // ---------------------------------

          // If we are here, the function call succeeded.
          // Let's check if it was SUPPOSED to fail.
          if (expectedOutcomes['shouldFail'] == true) {
            // If it was supposed to fail but didn't, we force the test to fail.
            fail('Test was expected to fail, but it succeeded.');
          }

          // --- ASSERTIONS FOR A SUCCESSFUL CALL ---
          // Now we check the actual data returned from the function.
          final responseData = result.data;

          if (expectedOutcomes['translation'] != null) {
            expect(responseData['translation'], equals(expectedOutcomes['translation']['exact']));
          }
          if (expectedOutcomes['feedback'] != null) {
            expect(responseData['feedback'].toLowerCase(), contains(expectedOutcomes['feedback']['contains']));
          }
          if (expectedOutcomes['score'] != null) {
            final score = int.parse(responseData['score']);
            if (expectedOutcomes['score']['isAbove'] != null) {
              expect(score, greaterThan(expectedOutcomes['score']['isAbove']));
            }
            if (expectedOutcomes['score']['isBelow'] != null) {
              expect(score, lessThan(expectedOutcomes['score']['isBelow']));
            }
          }

        } on FirebaseFunctionsException catch (e) {
          // If we are here, the function call threw an error.
          
          // First, let's check if this test was EXPECTED to fail.
          if (expectedOutcomes['shouldFail'] != true) {
            // If it failed unexpectedly, we fail the test and report the error.
            fail('Test failed unexpectedly with error: ${e.code} - ${e.message}');
          }

          // --- ASSERTIONS FOR AN EXPECTED FAILURE ---
          // This is a "good" failure. We check if we got the correct error code.
          expect(e.code, equals(expectedOutcomes['errorCode']));
        }
      });
    }
  });
}