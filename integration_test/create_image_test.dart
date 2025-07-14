import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lournal/main.dart' as app;
import 'package:lournal/components/note_tile.dart';

import 'test_helpers.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    "Complete user flow: Login -> Create Note (WITH Image) -> Verify -> Logout",
    (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // First, log in to get to the notes screen.
      await performLogin(tester);

      // 2. CREATE NOTE FLOW
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      final testTitle = 'Integration Test Note WITH IMAGE - ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(find.byKey(const ValueKey('title_field')), testTitle);
      await tester.enterText(find.byKey(const ValueKey('content_field')), 'This is the content of our test note with an image.');

      // *** ADD IMAGE STEP ***
      // NOTE: This step will likely fail. Integration tests cannot interact with native
      // platform UIs like the file picker. To make this test pass, the image_picker
      // package needs to be mocked to return a predefined image file.
      // await tester.tap(find.byIcon(Icons.add));
      // await tester.pumpAndSettle();
      // Assuming a mock is set up and an image is 'picked', the test would continue.

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      // Allow extra time for potential image upload
      await tester.pumpAndSettle(const Duration(seconds: 10)); 

      // 3. FINISH AND VERIFY
      expect(find.text("You’ve finished your Lournal"), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify the note exists and contains an image
      final noteFinder = find.ancestor(
        of: find.text(testTitle),
        matching: find.byType(NotesTile),
      );
      expect(noteFinder, findsOneWidget);
      expect(find.descendant(of: noteFinder, matching: find.byType(Image)), findsOneWidget);

      // 4. LOGOUT FLOW
      // Now, perform and verify the logout action.
      await performLogout(tester);
    },
  );
}
