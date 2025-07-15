// Import the necessary packages for testing.
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';

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
    when(mockFirestoreService.deleteNote(any)).thenAnswer((_) async => {});

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

    test('State when user is logged out (null user)', () {
      fakeAsync((async) {
        // Simulate a null user event from Firebase Auth
        authStateController.add(null);
        async.flushMicrotasks(); // Process the stream event

        // Assert the state is correctly set for a logged-out user
        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.filteredNotes, isEmpty);
        expect(notesProvider.hasError, isFalse);
      });
    });

    test('State when user logs in and successfully fetches notes', () {
      fakeAsync((async) {
        // Arrange: Prepare the mock response for the initial paginated fetch
        final mockSnapshot = createMockQuerySnapshot([]);
        when(mockFirestoreService.getNotesPaginated(limit: anyNamed('limit'), lastDocument: null))
            .thenAnswer((_) async => mockSnapshot);

        // Act: Simulate user login
        authStateController.add(mockUser);
        // FIX: Use elapse to ensure all async operations (futures, timers) complete.
        async.elapse(Duration.zero);

        // Assert: The provider should no longer be loading and have no errors.
        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.hasError, isFalse);
      });
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

    test('Loads and displays notes successfully after login', () {
      fakeAsync((async) {
        // Arrange: Mock the service to return our mock documents
        final mockSnapshot = createMockQuerySnapshot([mockDoc1, mockDoc2]);
        when(mockFirestoreService.getNotesPaginated(limit: anyNamed('limit'), lastDocument: null))
            .thenAnswer((_) async => mockSnapshot);

        // Act: Simulate user login to trigger the note fetch
        authStateController.add(mockUser);
        // FIX: Use elapse to ensure all async operations complete.
        async.elapse(Duration.zero);

        // Assert: Check if the state reflects the loaded notes
        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.hasError, isFalse);
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '2']));
      });
    });

    test('Handles error when fetching notes', () {
      fakeAsync((async) {
        // Arrange: Mock the service to throw an exception
        final error = FirebaseException(plugin: 'firestore', message: 'Permission denied');
        when(mockFirestoreService.getNotesPaginated(limit: anyNamed('limit'), lastDocument: null)).thenThrow(error);

        // Act: Simulate login to trigger the fetch
        authStateController.add(mockUser);
        // FIX: Use elapse to ensure all async operations complete.
        async.elapse(Duration.zero);

        // Assert: Check if the error state is correctly set
        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.hasError, isTrue);
        expect(notesProvider.error, contains("Failed to load notes"));
        expect(notesProvider.filteredNotes, isEmpty);
      });
    });

    test('Deletes a note and optimistically removes it from the list', () {
      fakeAsync((async) {
        // Arrange: Load an initial note into the provider by mocking the fetch
        final mockSnapshot = createMockQuerySnapshot([mockDoc1]);
        when(mockFirestoreService.getNotesPaginated(limit: anyNamed('limit'), lastDocument: null))
            .thenAnswer((_) async => mockSnapshot);
        
        authStateController.add(mockUser);
        // FIX: Use elapse to ensure all async operations complete.
        async.elapse(Duration.zero);

        // Sanity check that the note is loaded before deletion
        expect(notesProvider.filteredNotes.length, 1, reason: "Note should be loaded first");

        // Act: Delete the note
        notesProvider.deleteNote('1');
        
        // Assert: The note is removed from the UI immediately (optimistic update)
        expect(notesProvider.filteredNotes, isEmpty);
        
        // Verify that the service's delete method was called in the background
        verify(mockFirestoreService.deleteNote('1')).called(1);
      });
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

    // Helper to load initial data for all filtering tests in this group
    void setupNotesForFiltering(FakeAsync async) {
        final mockSnapshot = createMockQuerySnapshot([mockDoc1, mockDoc2, mockDoc3]);
        when(mockFirestoreService.getNotesPaginated(limit: anyNamed('limit'), lastDocument: null))
            .thenAnswer((_) async => mockSnapshot);
        
        authStateController.add(mockUser);
        // FIX: Use elapse to ensure all async operations complete.
        async.elapse(Duration.zero);
    }

    test('Filters by search query (case-insensitive)', () {
      fakeAsync((async) {
        setupNotesForFiltering(async);
        notesProvider.updateSearchQuery('intro');
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '3']));
      });
    });

    test('Filters by note type and language', () {
      fakeAsync((async) {
        setupNotesForFiltering(async);
        notesProvider.updateFilters({'Tutorial'}, {'Dart'});
        expect(notesProvider.filteredNotes.length, 1);
        expect(notesProvider.filteredNotes.first.id, '1');
      });
    });

    test('Returns all notes when filters are cleared', () {
       fakeAsync((async) {
        setupNotesForFiltering(async);
        // Apply filters first
        notesProvider.updateFilters({'Concept'}, {'Dart'});
        expect(notesProvider.filteredNotes.length, 1, reason: "Should have 1 note before clearing");

        // Clear filters and check if all notes are returned
        notesProvider.updateFilters({}, {});
        expect(notesProvider.filteredNotes.length, 3);
       });
    });
  });
}
