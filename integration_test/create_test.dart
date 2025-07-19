import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lournal/main.dart' as app;

import 'test_helpers.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    "Complete user flow: Login -> Create Note (No Image) -> Verify -> Logout",
    (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // First, log in to get to the notes screen.
      await performLogin(tester);


      // 2. CREATE NOTE FLOW
      // Tap the FAB to open the MyBottomBar
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // In the bottom sheet, tap the "Create" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      // We are now on the CreatePage. Enter title and content.
      final testTitle = 'Integration Test Note - ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(find.byKey(const ValueKey('title_field')), testTitle);
      await tester.enterText(find.byKey(const ValueKey('content_field')), 'This is the content of our test note.');

      // Find the image icon (FloatingActionButton with Icons.add) but do not tap it.
      final findImageButton = find.widgetWithIcon(FloatingActionButton, Icons.add);
      expect(findImageButton, findsOneWidget); // Assert that the button exists

      // Tap the "Save" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Wait for AI processing and navigation

      // 3. FINISH AND VERIFY
      // We should be on the FinishPage. Tap the "Finish" button.
      expect(find.text("You’ve finished your Lournal"), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Wait for notes to refresh

      // We are back on the NotesPage. Verify the new note is there.
      expect(find.text(testTitle, findRichText: true), findsOneWidget);
      expect(find.text('This is the content of our test note.', findRichText: true), findsOneWidget);

      // Now, perform and verify the logout action.
      await performLogout(tester);
    },
  );
}
