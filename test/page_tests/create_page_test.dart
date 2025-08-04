import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/pages/finish_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:lournal/services/storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_page_test.mocks.dart';

@GenerateMocks([
  FirebaseFunctions,
  HttpsCallable,
  FirestoreService,
  HttpsCallableResult,
  StorageService,
])
void main() {
  late MockFirebaseFunctions mockFirebaseFunctions;
  late MockHttpsCallable mockHttpsCallable;
  late MockFirestoreService mockFirestoreService;
  late MockHttpsCallableResult mockHttpsCallableResult;
  late MockStorageService mockStorageService;

  setUp(() {
    mockFirebaseFunctions = MockFirebaseFunctions();
    mockHttpsCallable = MockHttpsCallable();
    mockFirestoreService = MockFirestoreService();
    mockHttpsCallableResult = MockHttpsCallableResult();
    mockStorageService = MockStorageService();

    provideDummy<HttpsCallable>(mockHttpsCallable);

    when(mockFirebaseFunctions.httpsCallable(any))
        .thenReturn(mockHttpsCallable);
  });

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
        storageService: mockStorageService,
      ),
    );
  }

  final titleField = find.byKey(const ValueKey('title_field'));
  final contentField = find.byKey(const ValueKey('content_field'));

  group('Create New Note', () {
    testWidgets('should save a new note when title and content are provided',
        (WidgetTester tester) async {
      final fakeAiResponse = {
        'translation': 'This is a translation.',
        'feedback': 'Good job!',
        'score': '95',
      };

      when(mockHttpsCallableResult.data).thenReturn(fakeAiResponse);

      when(mockHttpsCallable.call(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return mockHttpsCallableResult;
      });

      await tester.pumpWidget(createTestableWidget());

      await tester.enterText(titleField, 'My Test Title');
      await tester.enterText(contentField, 'This is the content of my lournal.');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      await tester.pump();

      expect(find.byType(CustomCircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating AI feedback...'), findsOneWidget);

      await tester.pumpAndSettle();

      verify(mockFirestoreService.addNote(
        title: 'My Test Title',
        content: 'This is the content of my lournal.',
        language: 'en',
        type: 'journal',
        translation: 'This is a translation.',
        feedback: 'Good job!',
        score: 95,
        imageUrl: null,
      )).called(1);

      expect(find.byType(FinishPage), findsOneWidget);
    });

    testWidgets('should show a snackbar if title or content is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter both a title and content before saving'),
          findsOneWidget);
    });

    testWidgets('should show an error snackbar if the cloud function fails',
        (WidgetTester tester) async {
      when(mockHttpsCallable.call(any)).thenThrow(
        FirebaseFunctionsException(
          message: 'The function execution failed',
          code: 'internal',
        ),
      );

      await tester.pumpWidget(createTestableWidget());

      await tester.enterText(titleField, 'A title');
      await tester.enterText(contentField, 'Some content');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      await tester.pumpAndSettle();

      expect(find.byType(CustomCircularProgressIndicator), findsNothing);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text(
              'Failed to process note. Please ensure you are online and try again.'),
          findsOneWidget);
    });
  });

  group('Update Existing Note', () {
    testWidgets('should update an existing note', (WidgetTester tester) async {
      final fakeAiResponse = {
        'translation': 'Updated translation.',
        'feedback': 'Excellent work!',
        'score': '98',
      };
      when(mockHttpsCallableResult.data).thenReturn(fakeAiResponse);

      when(mockHttpsCallable.call(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return mockHttpsCallableResult;
      });

      await tester.pumpWidget(createTestableWidget(
        docID: 'existingDoc123',
        title: 'Initial Title',
        content: 'Initial content.',
      ));

      await tester.enterText(titleField, 'Updated Title');
      await tester.enterText(contentField, 'Updated content.');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      await tester.pump();

      expect(find.byType(CustomCircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      verify(mockFirestoreService.updateNote(
        docID: 'existingDoc123',
        title: 'Updated Title',
        content: 'Updated content.',
        language: 'en',
        type: 'journal',
        translation: 'Updated translation.',
        feedback: 'Excellent work!',
        score: 98,
        imageUrl: null,
      )).called(1);
    });
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}