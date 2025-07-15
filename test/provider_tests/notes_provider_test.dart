// Import the necessary packages for testing.
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the provider and service you want to test.
// Make sure to adjust the import path to match your project structure.
import 'package:lournal/providers/notes_provider.dart';
import 'package:lournal/services/firestore.dart';

// Import the generated mocks file.
import 'notes_provider_test.mocks.dart';

// Regenerate mocks with this command:
// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  FirestoreService,
  FirebaseAuth,
  User,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  // FIX: Initialize the binding for testWidgets
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Declare variables to be used in tests
  late NotesProvider notesProvider;
  late MockFirestoreService mockFirestoreService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late StreamController<User?> authStateController;

  // setUp is called before each test
  setUp(() {
    // Initialize mocks
    mockFirestoreService = MockFirestoreService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    authStateController = StreamController<User?>.broadcast();

    // Mock the auth state stream which the provider listens to
    when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
    
    // Mock the delete method since it's called in one of the tests
    when(mockFirestoreService.deleteNote(any)).thenAnswer((_) => Future.value());

    // Create the provider instance using the special testable constructor
    notesProvider = NotesProvider.testable(mockFirebaseAuth, mockFirestoreService);
  });

  // tearDown is called after each test
  tearDown(() {
    authStateController.close();
    notesProvider.dispose();
  });

  // Helper function to create mock Firestore documents
  MockQueryDocumentSnapshot<Map<String, dynamic>> createMockDocument({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    when(mockDoc.id).thenReturn(id);
    when(mockDoc.data()).thenReturn(data);
    return mockDoc;
  }

  // Helper function to create a mock Firestore query snapshot
  MockQuerySnapshot<Map<String, dynamic>> createMockQuerySnapshot(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    when(mockSnapshot.docs).thenReturn(docs);
    return mockSnapshot;
  }


  group('Initialization and Auth State', () {
    test('Initial state is loading', () {
      // The provider should start in a loading state immediately after creation
      expect(notesProvider.isLoading, isTrue);
    });

    // FIX: Use testWidgets and tester.pump() to handle async stream events
    testWidgets('State when user is logged out (null user)', (tester) async {
      // Simulate a null user event from Firebase Auth
      authStateController.add(null);
      // Wait for the stream listener to process the event
      await tester.pump();

      // Assert the state is correctly set for a logged-out user
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.filteredNotes, isEmpty);
      expect(notesProvider.hasError, isFalse);
    });

    testWidgets('State when user logs in and successfully fetches notes', (tester) async {
      // Arrange: Prepare the mock response for the initial paginated fetch
      final mockSnapshot = createMockQuerySnapshot([]);
      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: anyNamed('types'),
        languages: anyNamed('languages'),
      )).thenAnswer((_) => Future.value(mockSnapshot));

      // Act: Simulate user login
      authStateController.add(mockUser);
      // FIX: Pump the widget tree to process the Future from the service
      await tester.pump();

      // Assert: The provider should no longer be loading and have no errors.
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.hasError, isFalse);
    });
  });

  group('Notes Handling', () {
    // Create mock documents to be used in this group of tests
    final mockDoc1 = createMockDocument(
      id: '1',
      data: {'title': 'Flutter Intro', 'content': 'Widgets', 'type': 'Tutorial', 'language': 'Dart'},
    );
    final mockDoc2 = createMockDocument(
      id: '2',
      data: {'title': 'State Management', 'content': 'Provider rocks', 'type': 'Concept', 'language': 'Dart'},
    );

    testWidgets('Loads and displays notes successfully after login', (tester) async {
      // Arrange: Mock the service to return our mock documents
      final mockSnapshot = createMockQuerySnapshot([mockDoc1, mockDoc2]);
      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: anyNamed('types'),
        languages: anyNamed('languages'),
      )).thenAnswer((_) => Future.value(mockSnapshot));

      // Act: Simulate user login to trigger the note fetch
      authStateController.add(mockUser);
      await tester.pump();

      // Assert: Check if the state reflects the loaded notes
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.hasError, isFalse);
      expect(notesProvider.filteredNotes.length, 2);
      expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '2']));
    });

    testWidgets('Handles error when fetching notes', (tester) async {
      // Arrange: Mock the service to throw an exception
      final error = FirebaseException(plugin: 'firestore', message: 'Permission denied');
      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: anyNamed('types'),
        languages: anyNamed('languages'),
      )).thenAnswer((_) => Future.error(error));

      // Act: Simulate login to trigger the fetch
      authStateController.add(mockUser);
      await tester.pump();

      // Assert: Check if the error state is correctly set
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.hasError, isTrue);
      expect(notesProvider.error, contains("Failed to load notes"));
      expect(notesProvider.filteredNotes, isEmpty);
    });

    testWidgets('Deletes a note and optimistically removes it from the list', (tester) async {
      // Arrange: Load an initial note into the provider by mocking the fetch
      final mockSnapshot = createMockQuerySnapshot([mockDoc1]);
      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: anyNamed('types'),
        languages: anyNamed('languages'),
      )).thenAnswer((_) => Future.value(mockSnapshot));
      
      authStateController.add(mockUser);
      await tester.pump();

      // Sanity check that the note is loaded before deletion
      expect(notesProvider.filteredNotes.length, 1, reason: "Note should be loaded first");

      // Act: Delete the note
      await notesProvider.deleteNote('1');
      await tester.pump();
      
      // Assert: The note is removed from the UI immediately (optimistic update)
      expect(notesProvider.filteredNotes, isEmpty);
      
      // Verify that the service's delete method was called in the background
      verify(mockFirestoreService.deleteNote('1')).called(1);
    });
  });

  group('Filtering Logic', () {
    // Create mock documents for filtering tests
    final mockDoc1 = createMockDocument(
        id: '1',
        data: {'title': 'Flutter Intro', 'content': 'Widgets are cool', 'type': 'Tutorial', 'language': 'Dart'});
    final mockDoc2 = createMockDocument(
        id: '2',
        data: {'title': 'State Management', 'content': 'Provider is a widget', 'type': 'Concept', 'language': 'Dart'});
    final mockDoc3 = createMockDocument(
        id: '3',
        data: {'title': 'Python Intro', 'content': 'Simple syntax', 'type': 'Tutorial', 'language': 'Python'});
    
    final allDocs = [mockDoc1, mockDoc2, mockDoc3];

    // Helper to load initial data for all filtering tests in this group
    Future<void> setupNotesForFiltering(WidgetTester tester) async {
        when(mockFirestoreService.getNotesPaginated(
          limit: anyNamed('limit'),
          lastDocument: anyNamed('lastDocument'),
          types: anyNamed('types'),
          languages: anyNamed('languages'),
        )).thenAnswer((_) => Future.value(createMockQuerySnapshot(allDocs)));
        
        authStateController.add(mockUser);
        await tester.pump();
    }

    testWidgets('Filters by search query (case-insensitive)', (tester) async {
      await setupNotesForFiltering(tester);
      notesProvider.updateSearchQuery('intro');
      await tester.pump();

      expect(notesProvider.filteredNotes.length, 2);
      expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '3']));
    });

    testWidgets('Filters by note type and language', (tester) async {
      await setupNotesForFiltering(tester);
      
      // Arrange: Set up a more specific mock for this particular filter combination
      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: {'Tutorial'},
        languages: {'Dart'},
      )).thenAnswer((_) => Future.value(createMockQuerySnapshot([mockDoc1])));

      // Act: Update filters, which triggers an async fetch
      notesProvider.updateFilters({'Tutorial'}, {'Dart'});
      await tester.pump();

      // Assert: Check the results after the fetch
      expect(notesProvider.filteredNotes.length, 1);
      expect(notesProvider.filteredNotes.first.id, '1');
    });

    testWidgets('Returns all notes when filters are cleared', (tester) async {
      await setupNotesForFiltering(tester);
      
      // Arrange: Mock the responses for both the filtered and cleared states
      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: {'Concept'},
        languages: {'Dart'},
      )).thenAnswer((_) => Future.value(createMockQuerySnapshot([mockDoc2])));

      when(mockFirestoreService.getNotesPaginated(
        limit: anyNamed('limit'),
        lastDocument: anyNamed('lastDocument'),
        types: {},
        languages: {},
      )).thenAnswer((_) => Future.value(createMockQuerySnapshot(allDocs)));

      // Act 1: Apply filters first
      notesProvider.updateFilters({'Concept'}, {'Dart'});
      await tester.pump();
      expect(notesProvider.filteredNotes.length, 1, reason: "Should have 1 note before clearing");

      // Act 2: Clear filters and check if all notes are returned
      notesProvider.updateFilters({}, {});
      await tester.pump();
      expect(notesProvider.filteredNotes.length, 3);
    });
  });
}
