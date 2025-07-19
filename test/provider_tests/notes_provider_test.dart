
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lournal/providers/notes_provider.dart';
import 'package:lournal/services/firestore.dart';
import 'notes_provider_test.mocks.dart';

// This annotation is used by the build_runner to generate the mock classes.
@GenerateMocks([
  FirestoreService,
  FirebaseAuth,
  User,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  // Ensures that the Flutter test framework is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declare all the variables that will be used across tests.
  late NotesProvider notesProvider;
  late MockFirestoreService mockFirestoreService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late StreamController<User?> authStateController;

  // The setUp function runs before each test, ensuring a clean state.
  setUp(() {
    // Initialize all the mock objects.
    mockFirestoreService = MockFirestoreService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    authStateController = StreamController<User?>.broadcast();

    // Mock the core auth state stream that the provider listens to.
    when(mockFirebaseAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);

    // Create the provider instance using the testable constructor with mocks.
    notesProvider =
        NotesProvider.testable(mockFirebaseAuth, mockFirestoreService);
  });

  // The tearDown function runs after each test to clean up resources.
  tearDown(() {
    authStateController.close();
    notesProvider.dispose();
  });

  // Helper function to easily create a mock Firestore document.
  MockQueryDocumentSnapshot<Map<String, dynamic>> createMockDocument({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    when(mockDoc.id).thenReturn(id);
    when(mockDoc.data()).thenReturn(data);
    return mockDoc;
  }

  // Helper function to easily create a mock Firestore query snapshot.
  MockQuerySnapshot<Map<String, dynamic>> createMockQuerySnapshot(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    when(mockSnapshot.docs).thenReturn(docs);
    return mockSnapshot;
  }

  // Group of tests for the initial state and authentication changes.
  group('Initialization and Auth State', () {
    test('Initial state is loading', () {
      // The provider should always start in a loading state.
      expect(notesProvider.isLoading, isTrue);
    });

    testWidgets('State when user is logged out (null user)', (tester) async {
      // Act: Simulate a logged-out event.
      authStateController.add(null);
      await tester.pump(); // Process the stream event.

      // Assert: The provider should be idle, with no data and no errors.
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.filteredNotes, isEmpty);
      expect(notesProvider.hasError, isFalse);
    });

    testWidgets('State when user logs in and fetch is successful', (tester) async {
      // Arrange: Set up the mock for the initial fetch when a user logs in.
      // This is the key fix: We explicitly match the arguments for the first call.
      when(mockFirestoreService.getNotesPaginated(
        limit: 15,
        lastDocument: null, // `null` is critical for the first fetch.
        types: {},
        languages: {},
      )).thenAnswer((_) async => createMockQuerySnapshot([]));

      // Act: Simulate user login.
      authStateController.add(mockUser);
      await tester.pump(); // Process the login event and the subsequent fetch.

      // Assert: The provider should finish loading without any errors.
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.hasError, isFalse);
    });
  });

  // Group of tests for creating, deleting, and handling errors with notes.
  group('Notes Handling', () {
    // Pre-create mock documents for use in these tests.
    final mockDoc1 = createMockDocument(id: '1', data: {'title': 'Note 1'});
    final mockDoc2 = createMockDocument(id: '2', data: {'title': 'Note 2'});

    testWidgets('Loads and displays notes successfully after login', (tester) async {
      // Arrange: Mock the service to return a list with two notes.
      final mockSnapshot = createMockQuerySnapshot([mockDoc1, mockDoc2]);
      when(mockFirestoreService.getNotesPaginated(
        limit: 15, lastDocument: null, types: {}, languages: {},
      )).thenAnswer((_) async => mockSnapshot);

      // Act: Log the user in to trigger the fetch.
      authStateController.add(mockUser);
      await tester.pump();

      // Assert: The state should reflect the two loaded notes.
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.hasError, isFalse);
      expect(notesProvider.filteredNotes.length, 2);
      expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '2']));
    });

    testWidgets('Handles error correctly when fetching notes', (tester) async {
      // Arrange: Mock the service to throw an error during the fetch.
      final error = FirebaseException(plugin: 'firestore', message: 'Permission denied');
      when(mockFirestoreService.getNotesPaginated(
        limit: 15, lastDocument: null, types: {}, languages: {},
      )).thenThrow(error);

      // Act: Log the user in.
      authStateController.add(mockUser);
      await tester.pump();

      // Assert: The provider should catch the error and update its state.
      expect(notesProvider.isLoading, isFalse);
      expect(notesProvider.hasError, isTrue);
      expect(notesProvider.error, contains("Failed to load notes"));
      expect(notesProvider.filteredNotes, isEmpty);
    });

    testWidgets('Deletes a note and optimistically removes it', (tester) async {
      // Arrange 1: Load an initial note into the provider.
      final mockSnapshot = createMockQuerySnapshot([mockDoc1]);
      when(mockFirestoreService.getNotesPaginated(
        limit: 15, lastDocument: null, types: {}, languages: {},
      )).thenAnswer((_) async => mockSnapshot);
      
      // Arrange 2: Ensure the delete call on the service will succeed.
      when(mockFirestoreService.deleteNote('1')).thenAnswer((_) async {});

      // Act 1: Log in and wait for the note to load.
      authStateController.add(mockUser);
      await tester.pump();
      expect(notesProvider.filteredNotes.length, 1, reason: "Note should be loaded first");

      // Act 2: Delete the note.
      await notesProvider.deleteNote('1');
      await tester.pump();
      
      // Assert: The note is gone from the list, and the service was called.
      expect(notesProvider.filteredNotes, isEmpty);
      verify(mockFirestoreService.deleteNote('1')).called(1);
    });
  });

  // Group of tests for the client-side and server-side filtering logic.
  group('Filtering Logic', () {
    final mockDoc1 = createMockDocument(id: '1', data: {'title': 'Flutter Intro'});
    final mockDoc2 = createMockDocument(id: '2', data: {'title': 'State Intro'});
    final mockDoc3 = createMockDocument(id: '3', data: {'title': 'Python Basics'});
    final allDocs = [mockDoc1, mockDoc2, mockDoc3];

    // Helper to set up the initial state with all three notes.
    Future<void> setupInitialNotes(WidgetTester tester) async {
      when(mockFirestoreService.getNotesPaginated(
        limit: 15, lastDocument: null, types: {}, languages: {},
      )).thenAnswer((_) async => createMockQuerySnapshot(allDocs));
      authStateController.add(mockUser);
      await tester.pump();
    }

    testWidgets('Filters by search query correctly', (tester) async {
      // Arrange: Load all notes.
      await setupInitialNotes(tester);
      expect(notesProvider.filteredNotes.length, 3);

      // Act: Apply a search query. This filtering is client-side.
      notesProvider.updateSearchQuery('intro');
      await tester.pump();

      // Assert: Only notes containing "intro" should remain.
      expect(notesProvider.filteredNotes.length, 2);
      expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '2']));
    });

    testWidgets('Refetches from service when filters are updated', (tester) async {
      // Arrange 1: Load all notes initially.
      await setupInitialNotes(tester);
      
      // Arrange 2: Set up a specific mock for the *filtered* fetch.
      when(mockFirestoreService.getNotesPaginated(
        limit: 15, lastDocument: null, types: {'Python'}, languages: {},
      )).thenAnswer((_) async => createMockQuerySnapshot([mockDoc3]));

      // Act: Update the filters, which triggers a new fetch from the service.
      notesProvider.updateFilters({'Python'}, {});
      await tester.pump();

      // Assert: The list should now only contain the result of the filtered fetch.
      expect(notesProvider.filteredNotes.length, 1);
      expect(notesProvider.filteredNotes.first.id, '3');
    });
  });
}
