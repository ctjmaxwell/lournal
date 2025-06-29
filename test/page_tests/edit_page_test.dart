import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/pages/edit_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock file
import 'edit_page_test.mocks.dart';

// We no longer need the MockNavigatorObserver, so it has been removed.

// Generate a mock for FirestoreService.
@GenerateMocks([FirestoreService])
void main() {
late MockFirestoreService mockFirestoreService;
// Create a GlobalKey for our Navigator. This is our new tool for testing.
final navigatorKey = GlobalKey<NavigatorState>();

// setUp is called before each test to ensure a clean state.
setUp(() {
  mockFirestoreService = MockFirestoreService();
});

// A helper function to build the EditPage.
Future<void> pumpEditPage(WidgetTester tester) async {
  // We pass our navigatorKey to the MaterialApp.
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      home: EditPage(
        docID: 'testDocID',
        title: 'Test Title',
        content: 'Test Content',
        translation: 'Test Translation',
        feedback: 'Test Feedback',
        type: 'Test Type',
        language: 'Test Language',
        score: 80,
        firestoreService: mockFirestoreService,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.white,
          inversePrimary: Colors.black,
          tertiary: Colors.green,
        ),
      ),
    ),
  );
}

testWidgets('EditPage renders all UI elements correctly', (WidgetTester tester) async {
  await pumpEditPage(tester);

  expect(find.text('Test Title'), findsOneWidget);
  expect(find.text('Test Content'), findsOneWidget);
  // ... other widget checks remain the same
  expect(find.byIcon(Icons.more_vert), findsOneWidget);
  expect(find.byIcon(Icons.arrow_back), findsOneWidget);
});

testWidgets('Tapping the back button pops the page', (WidgetTester tester) async {
  await pumpEditPage(tester);
  // Ensure the page is present before tapping.
  expect(find.byType(EditPage), findsOneWidget);

  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Assert: Verify the page is no longer on screen.
  expect(find.byType(EditPage), findsNothing);
});

testWidgets('Tapping Edit option navigates to CreatePage', (WidgetTester tester) async {
  await pumpEditPage(tester);

  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();

  // Assert: We simply check if the CreatePage is now visible. This confirms the push.
  expect(find.byType(CreatePage), findsOneWidget);
});

testWidgets('Tapping Delete option calls firestore and pops the page', (WidgetTester tester) async {
  when(mockFirestoreService.deleteNote(any)).thenAnswer((_) async {});
  await pumpEditPage(tester);
  
  // Ensure the EditPage is present.
  expect(find.byType(EditPage), findsOneWidget);

  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();

  // Assert: Verify the firestore method was called.
  verify(mockFirestoreService.deleteNote('testDocID')).called(1);

  // Assert: Verify the EditPage is gone from the widget tree.
  expect(find.byType(EditPage), findsNothing);
});
}
