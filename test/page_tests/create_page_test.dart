import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/pages/finish_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_page_test.mocks.dart';

// Because we can't instantiate HttpsCallableResult directly anymore,
// we create a mock for it as well.
@GenerateMocks([
  FirebaseFunctions,
  HttpsCallable,
  FirestoreService,
  HttpsCallableResult
])
void main() {
  // Mocks for our services
  late MockFirebaseFunctions mockFirebaseFunctions;
  late MockHttpsCallable mockHttpsCallable;
  late MockFirestoreService mockFirestoreService;
  late MockHttpsCallableResult mockHttpsCallableResult;

  // This setup function runs before each test, ensuring a clean slate.
  setUp(() {
    mockFirebaseFunctions = MockFirebaseFunctions();
    mockHttpsCallable = MockHttpsCallable();
    mockFirestoreService = MockFirestoreService();
    mockHttpsCallableResult = MockHttpsCallableResult();
    
    // Register a dummy fallback for HttpsCallable.
    provideDummy<HttpsCallable>(mockHttpsCallable);

    // When the code asks for a callable named 'processNoteWithAI',
    // we return our mock callable instance.
    when(mockFirebaseFunctions.httpsCallable(any))
        .thenReturn(mockHttpsCallable);
  });

  /// A helper function to build the CreatePage with the necessary mocks.
  Widget createTestableWidget({
    String? docID,
    String language = 'en',
    String type = 'journal',
    String title = '',
    String content = '',
  }) {
    return MaterialApp(
      navigatorObservers: [MockNavigatorObserver()],
      home: CreatePage(
        docID: docID,
        language: language,
        type: type,
        title: title,
        content: content,
        firestoreService: mockFirestoreService,
        functions: mockFirebaseFunctions,
      ),
    );
  }

  // A finder for our specific TextFields using their keys.
  final titleField = find.byKey(const ValueKey('title_field'));
  final contentField = find.byKey(const ValueKey('content_field'));

  // --- Test Group for Creating a New Note ---
  group('Create New Note', () {
    testWidgets('should save a new note when title and content are provided',
        (WidgetTester tester) async {
      // --- ARRANGE ---
      final fakeAiResponse = {
        'translation': 'This is a translation.',
        'feedback': 'Good job!',
        'score': '95',
      };

      when(mockHttpsCallableResult.data).thenReturn(fakeAiResponse);

      // Simulate a network delay.
      when(mockHttpsCallable.call(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return mockHttpsCallableResult;
      });

      // Pump the widget tree.
      await tester.pumpWidget(createTestableWidget());

      // --- ACT ---
      await tester.enterText(titleField, 'My Test Title');
      await tester.enterText(contentField, 'This is the content of my lournal.');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      // Pump the first frame to show the loading indicator.
      await tester.pump();

      // --- ASSERT (during loading) ---
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating AI feedback for your Lournal...'), findsOneWidget);

      // Now, wait for all timers and animations to complete.
      await tester.pumpAndSettle();

      // --- ASSERT (after saving) ---
      verify(mockFirestoreService.addNote(
        title: 'My Test Title',
        content: 'This is the content of my lournal.',
        language: 'en',
        type: 'journal',
        translation: 'This is a translation.',
        feedback: 'Good job!',
        score: 95,
      )).called(1);

      expect(find.byType(FinishPage), findsOneWidget);
    });

    testWidgets('should show a snackbar if title or content is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter both a title and content before saving'), findsOneWidget);
    });

    // NEW TEST CASE ADDED HERE
    testWidgets('should show an error snackbar if the cloud function fails', (WidgetTester tester) async {
      // --- ARRANGE ---
      
      // Tell the mock to throw an exception when called.
      // We use a specific FirebaseFunctionsException for realism.
      when(mockHttpsCallable.call(any)).thenThrow(
        FirebaseFunctionsException(
          message: 'The function execution failed',
          code: 'internal',
        ),
      );

      // Pump the widget.
      await tester.pumpWidget(createTestableWidget());

      // --- ACT ---
      await tester.enterText(titleField, 'A title');
      await tester.enterText(contentField, 'Some content');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      // Wait for all async operations to finish (the try/catch block).
      await tester.pumpAndSettle();

      // --- ASSERT ---
      
      // 1. Verify the loading indicator is GONE.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // 2. Verify the correct error SnackBar is shown.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to process note. Please ensure you are online and try again.'), findsOneWidget);
    });
  });

  // --- Test Group for Updating an Existing Note ---
  group('Update Existing Note', () {
    testWidgets('should update an existing note', (WidgetTester tester) async {
      // --- ARRANGE ---
      final fakeAiResponse = {
        'translation': 'Updated translation.',
        'feedback': 'Excellent work!',
        'score': '98',
      };
      when(mockHttpsCallableResult.data).thenReturn(fakeAiResponse);
      
      // Also apply the simulated delay here
      when(mockHttpsCallable.call(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return mockHttpsCallableResult;
      });

      await tester.pumpWidget(createTestableWidget(
        docID: 'existingDoc123',
        title: 'Initial Title',
        content: 'Initial content.',
      ));

      // --- ACT ---
      await tester.enterText(titleField, 'Updated Title');
      await tester.enterText(contentField, 'Updated content.');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      
      // Pump to show the loading indicator
      await tester.pump();
      
      // ASSERT: check for indicator during the "in-flight" operation
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Now wait for the delayed future and subsequent navigation to complete
      await tester.pumpAndSettle();

      // --- ASSERT ---
      verify(mockFirestoreService.updateNote(
        docID: 'existingDoc123',
        title: 'Updated Title',
        content: 'Updated content.',
        language: 'en',
        type: 'journal',
        translation: 'Updated translation.',
        feedback: 'Excellent work!',
        score: 98,
      )).called(1);
    });
  });
}

// A mock navigator observer to help with testing navigation events.
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
