// Import the necessary packages for testing.
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';


// Import the provider and service you want to test.
import 'package:lournal/providers/notes_provider.dart';
import 'package:lournal/services/firestore.dart';

// Import the generated mocks file.
import 'notes_provider_test.mocks.dart';

@GenerateMocks([
  FirestoreService,
  FirebaseAuth,
  User,
  StreamSubscription,
  QuerySnapshot,
  QueryDocumentSnapshot,
])


void main() {
  late NotesProvider notesProvider;
  late MockFirestoreService mockFirestoreService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  late StreamController<User?> authStateController;
  late StreamController<QuerySnapshot<Object?>> notesStreamController;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Use a broadcast controller to allow for potential multiple listeners,
    // though the best practice is to have only one. This makes the test setup
    // slightly more robust against this specific error.
    authStateController = StreamController<User?>.broadcast();
    notesStreamController = StreamController<QuerySnapshot<Object?>>.broadcast();

    when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
    when(mockFirestoreService.getNotesStream()).thenAnswer((_) => notesStreamController.stream);
    when(mockFirestoreService.deleteNote(any)).thenAnswer((_) async => {});

    notesProvider = NotesProvider.testable(mockFirebaseAuth, mockFirestoreService);
  });

  tearDown(() {
    authStateController.close();
    notesStreamController.close();
    notesProvider.dispose();
  });

  MockQueryDocumentSnapshot createMockDocument({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final mockDoc = MockQueryDocumentSnapshot();
    when(mockDoc.id).thenReturn(id);
    when(mockDoc.data()).thenReturn(data as Object);
    return mockDoc;
  }

  group('Initialization and Auth State', () {
    // FIX: This test was creating a new NotesProvider, causing the error.
    // It should test the provider created in setUp().
    test('Initial state is loading', () {
      // The notesProvider is already created in the setUp function.
      // We just need to check its initial state immediately after creation.
      expect(notesProvider.isLoading, isTrue);
    });

    test('State when user is logged out (null user)', () {
      fakeAsync((async) {
        authStateController.add(null);
        async.flushMicrotasks(); 
        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.filteredNotes, isEmpty);
        expect(notesProvider.hasError, isFalse);
      });
    });

    test('State when user logs in, before notes are loaded', () {
       fakeAsync((async) {
        authStateController.add(mockUser);
        async.flushMicrotasks();
        expect(notesProvider.isLoading, isTrue);
      });
    });

    test('State after user logs out after being logged in', () {
      fakeAsync((async) {
        authStateController.add(mockUser);
        async.flushMicrotasks();

        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([]);
        notesStreamController.add(mockQuerySnapshot);
        async.flushMicrotasks();

        expect(notesProvider.isLoading, isFalse, reason: "Should be loaded after notes arrive");

        authStateController.add(null);
        async.flushMicrotasks();
        
        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.filteredNotes, isEmpty);
        expect(notesProvider.hasError, isFalse);
      });
    });
  });

  // --- No other tests needed changes ---

  group('Notes Handling', () {
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
        authStateController.add(mockUser);
        async.flushMicrotasks();

        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        notesStreamController.add(mockQuerySnapshot);
        async.flushMicrotasks();

        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.hasError, isFalse);
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes, contains(mockDoc1));
      });
    });

    test('Handles error when fetching notes', () {
      fakeAsync((async) {
        authStateController.add(mockUser);
        async.flushMicrotasks();

        final error = FirebaseException(plugin: 'firestore', message: 'Permission denied');
        notesStreamController.addError(error);
        async.flushMicrotasks();

        expect(notesProvider.isLoading, isFalse);
        expect(notesProvider.hasError, isTrue);
        expect(notesProvider.error, contains("Failed to load notes"));
        expect(notesProvider.filteredNotes, isEmpty);
      });
    });

    test('Calls deleteNote on FirestoreService', () async {
      const docId = 'note-to-delete';
      await notesProvider.deleteNote(docId);
      verify(mockFirestoreService.deleteNote(docId)).called(1);
    });
  });

  group('Filtering Logic', () {
    final mockDoc1 = createMockDocument(
      id: '1',
      data: {'title': 'Flutter Intro', 'content': 'Widgets are cool', 'type': 'Tutorial', 'language': 'Dart'},
    );
    final mockDoc2 = createMockDocument(
      id: '2',
      data: {'title': 'State Management', 'content': 'Provider is a widget', 'type': 'Concept', 'language': 'Dart'},
    );
    final mockDoc3 = createMockDocument(
      id: '3',
      data: {'title': 'Python Intro', 'content': 'Simple syntax', 'type': 'Tutorial', 'language': 'Python'},
    );

    void setupNotes(FakeAsync async) {
      authStateController.add(mockUser);
      async.flushMicrotasks();
      final mockQuerySnapshot = MockQuerySnapshot();
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2, mockDoc3]);
      notesStreamController.add(mockQuerySnapshot);
      async.flushMicrotasks();
    }

    test('Filters by search query (case-insensitive)', () {
      fakeAsync((async) {
        setupNotes(async);
        notesProvider.updateSearchQuery('intro');
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '3']));

        notesProvider.updateSearchQuery('WIDGET');
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '2']));
      });
    });

    test('Filters by note type', () {
      fakeAsync((async) {
        setupNotes(async);
        notesProvider.updateFilters({'Tutorial'}, {});
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '3']));
      });
    });

    test('Filters by note language', () {
      fakeAsync((async) {
        setupNotes(async);
        notesProvider.updateFilters({}, {'Dart'});
        expect(notesProvider.filteredNotes.length, 2);
        expect(notesProvider.filteredNotes.map((d) => d.id), containsAll(['1', '2']));
      });
    });

    test('Filters by a combination of search, type, and language', () {
      fakeAsync((async) {
        setupNotes(async);
        notesProvider.updateFilters({'Tutorial'}, {'Dart'});
        notesProvider.updateSearchQuery('flutter');
        expect(notesProvider.filteredNotes.length, 1);
        expect(notesProvider.filteredNotes.first.id, '1');
      });
    });

    test('Returns all notes when filters are cleared', () {
       fakeAsync((async) {
        setupNotes(async);
        notesProvider.updateFilters({'Concept'}, {'Dart'});
        notesProvider.updateSearchQuery('state');
        expect(notesProvider.filteredNotes.length, 1, reason: "Should have 1 note before clearing");

        notesProvider.updateFilters({}, {});
        notesProvider.updateSearchQuery('');
        expect(notesProvider.filteredNotes.length, 3);
       });
    });
  });
}
