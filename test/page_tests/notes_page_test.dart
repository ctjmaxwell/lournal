import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lournal/pages/notes_page.dart';
import 'package:lournal/providers/notes_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:lournal/components/note_tile.dart';
import 'package:network_image_mock/network_image_mock.dart';

// A mock provider that we can control for our tests.
class MockNotesProvider extends ChangeNotifier implements NotesProvider {
  List<DocumentSnapshot> _allNotes = [];
  String _searchQuery = '';
  Set<String> _selectedTypes = {};
  Set<String> _selectedLanguages = {};
  bool _isLoading = false;
  String? _error;
  bool _isLoadingMore = false;

  @override
  List<DocumentSnapshot> get filteredNotes => _getFilteredNotes();
  @override
  bool get isLoading => _isLoading;
  @override
  bool get hasError => _error != null;
  @override
  String? get error => _error;
  @override
  String get searchQuery => _searchQuery;
  @override
  Set<String> get selectedTypes => _selectedTypes;
  @override
  Set<String> get selectedLanguages => _selectedLanguages;
  @override
  bool get isLoadingMore => _isLoadingMore;

  void setNotes(List<DocumentSnapshot> notes) {
    _allNotes = notes;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  @override
  Future<void> fetchInitialNotes() async {
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> fetchMoreNotes() async {
    return;
  }

  @override
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  @override
  void updateFilters(Set<String> newSelectedTypes, Set<String> newSelectedLanguages) {
    _selectedTypes = newSelectedTypes;
    _selectedLanguages = newSelectedLanguages;
    notifyListeners();
  }

  @override
  Future<void> deleteNote(String docId) async {
    _allNotes.removeWhere((doc) => doc.id == docId);
    notifyListeners();
  }

  @override
  Future<void> refreshNotes() async {
    // In a real scenario, this would re-fetch. For the mock, we can just notify.
    notifyListeners();
  }

  List<DocumentSnapshot> _getFilteredNotes() {
    if (_searchQuery.isEmpty && _selectedTypes.isEmpty && _selectedLanguages.isEmpty) {
      return List<DocumentSnapshot>.from(_allNotes);
    } else {
      return _allNotes.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final noteType = data['type'] as String? ?? '';
        final noteLanguage = data['language'] as String? ?? '';
        final title = (data['title'] as String? ?? '').toLowerCase();
        final content = (data['content'] as String? ?? '').toLowerCase();

        final typeMatch = _selectedTypes.isEmpty || _selectedTypes.contains(noteType);
        final langMatch = _selectedLanguages.isEmpty || _selectedLanguages.contains(noteLanguage);
        final queryMatch = _searchQuery.isEmpty || title.contains(_searchQuery) || content.contains(_searchQuery);

        return typeMatch && langMatch && queryMatch;
      }).toList();
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}

Widget createTestableWidget({required Widget child, required NotesProvider provider}) {
  return ChangeNotifierProvider<NotesProvider>.value(
    value: provider,
    child: MaterialApp(
      home: child,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    ),
  );
}

Future<DocumentSnapshot> createFakeDoc(FakeFirebaseFirestore firestore, String id, Map<String, dynamic> data) async {
  final fullData = {
    'title': 'Default Title',
    'content': 'Default content.',
    'translation': '',
    'feedback': '',
    'type': 'Diary',
    'language': 'English',
    'score': 100,
    'timestamp': Timestamp.now(),
    'imageUrl': null, // Default to no image
    ...data,
  };

  await firestore.collection('notes').doc(id).set(fullData);
  return await firestore.collection('notes').doc(id).get();
}

void main() {
  late MockNotesProvider mockNotesProvider;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockNotesProvider = MockNotesProvider();
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('NotesPage Widget Tests', () {
    testWidgets('Shows loading indicator when isLoading is true', (WidgetTester tester) async {
      mockNotesProvider.setLoading(true);

      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows error message when hasError is true', (WidgetTester tester) async {
      mockNotesProvider.setError('Failed to load');

      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));
      
      await tester.pumpAndSettle();
      
      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('Shows empty state when there are no notes and no filters', (WidgetTester tester) async {
      mockNotesProvider.setNotes([]);
      
      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Start Your Journey!'), findsOneWidget);
    });
    
    testWidgets('Shows empty state for filters when there are no matching notes', (WidgetTester tester) async {
      final notes = [
        await createFakeDoc(fakeFirestore, 'note1', {'title': 'My First Note'}),
      ];
      mockNotesProvider.setNotes(notes);
      mockNotesProvider.updateSearchQuery("nonexistent");

      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('No Matching Lournals!'), findsOneWidget);
    });

    testWidgets('Shows a list of notes when data is available', (WidgetTester tester) async {
      final notes = [
        await createFakeDoc(fakeFirestore, 'note1', {'title': 'My First Note'}),
        await createFakeDoc(fakeFirestore, 'note2', {'title': 'My Second Note'}),
      ];
      mockNotesProvider.setNotes(notes);

      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SliverList), findsOneWidget);
      expect(find.text('My First Note'), findsOneWidget);
      expect(find.text('My Second Note'), findsOneWidget);
    });

    testWidgets('Searching in TextField filters the list', (WidgetTester tester) async {
      final notes = [
        await createFakeDoc(fakeFirestore, 'note1', {'title': 'Apple Note'}),
        await createFakeDoc(fakeFirestore, 'note2', {'title': 'Banana Note'}),
      ];
      mockNotesProvider.setNotes(notes);

      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Apple Note'), findsOneWidget);
      expect(find.text('Banana Note'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Apple');
      await tester.pumpAndSettle();

      expect(find.text('Apple Note'), findsOneWidget);
      expect(find.text('Banana Note'), findsNothing);
    });

    testWidgets('Note with imageUrl shows an Image widget', (WidgetTester tester) async {
      // Use mockNetworkImagesFor to handle the Image.network call within the test
      await mockNetworkImagesFor(() async {
        final notes = [
          await createFakeDoc(fakeFirestore, 'noteWithImage', {
            'title': 'Image Note',
            'imageUrl': 'https://fakeurl.com/image.jpg',
          }),
        ];
        mockNotesProvider.setNotes(notes);

        await tester.pumpWidget(createTestableWidget(
          child: const NotesPage(),
          provider: mockNotesProvider,
        ));
        await tester.pumpAndSettle();

        // Find the NoteTile and then check for an Image widget within it.
        final noteTileFinder = find.byType(NotesTile);
        expect(noteTileFinder, findsOneWidget);

        final imageFinder = find.descendant(
          of: noteTileFinder,
          matching: find.byType(Image),
        );
        
        // We expect to find the Image.network widget.
        expect(imageFinder, findsOneWidget);
      });
    });

    testWidgets('Note without imageUrl does not show an Image widget', (WidgetTester tester) async {
      final notes = [
        await createFakeDoc(fakeFirestore, 'noteWithoutImage', {
          'title': 'No Image Note',
          'imageUrl': null, // Explicitly set to null
        }),
      ];
      mockNotesProvider.setNotes(notes);

      await tester.pumpWidget(createTestableWidget(
        child: const NotesPage(),
        provider: mockNotesProvider,
      ));
      await tester.pumpAndSettle();

      final noteTileFinder = find.byType(NotesTile);
      expect(noteTileFinder, findsOneWidget);

      final imageFinder = find.descendant(
        of: noteTileFinder,
        matching: find.byType(Image),
      );
      
      // We expect to find no Image widgets within this tile.
      expect(imageFinder, findsNothing);
    });
  });
}