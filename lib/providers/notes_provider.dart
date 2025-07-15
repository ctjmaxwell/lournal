import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lournal/services/firestore.dart';

class NotesProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  // Public constructor for your app
  NotesProvider()
      : _auth = FirebaseAuth.instance,
        _firestoreService = FirestoreService() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Special constructor for testing
  @visibleForTesting
  NotesProvider.testable(this._auth, this._firestoreService) {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  late StreamSubscription _authSubscription;

  // Private state variables
  List<DocumentSnapshot> _notes = [];
  String _searchQuery = '';
  Set<String> _selectedTypes = {};
  Set<String> _selectedLanguages = {};
  bool _isLoading = true;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMoreNotes = true;
  final int _notesPerPage = 15;

  // Public getters
  List<DocumentSnapshot> get filteredNotes => _getFilteredNotes();
  String get searchQuery => _searchQuery;
  Set<String> get selectedTypes => _selectedTypes;
  Set<String> get selectedLanguages => _selectedLanguages;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;
  bool get isLoadingMore => _isLoadingMore;

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      _notes = [];
      _isLoading = false;
      _error = null;
      _lastDocument = null;
      _hasMoreNotes = true;
      notifyListeners();
    } else {
      // When a user logs in, reset filters and fetch their notes.
      _selectedTypes = {};
      _selectedLanguages = {};
      _searchQuery = '';
      fetchInitialNotes();
    }
  }

  Future<void> fetchInitialNotes() async {
    _isLoading = true;
    _error = null;
    _lastDocument = null;
    _hasMoreNotes = true;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getNotesPaginated(
        limit: _notesPerPage,
        types: _selectedTypes,
        languages: _selectedLanguages,
      );
      _notes = snapshot.docs;
      if (_notes.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }
      _hasMoreNotes = _notes.length == _notesPerPage;
    } catch (e) {
      _error = "Failed to load notes: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreNotes() async {
    if (_isLoadingMore || !_hasMoreNotes) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getNotesPaginated(
        limit: _notesPerPage,
        lastDocument: _lastDocument,
        types: _selectedTypes,
        languages: _selectedLanguages,
      );

      if (snapshot.docs.isNotEmpty) {
        _notes.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
      }
      _hasMoreNotes = snapshot.docs.length == _notesPerPage;
    } catch (e) {
      _error = "Failed to load more notes: $e";
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotes() async {
    // Re-fetches the first page of notes, respecting current filters.
    await fetchInitialNotes();
  }

  List<DocumentSnapshot> _getFilteredNotes() {
    // Start with the notes fetched from Firestore (which might already be server-filtered)
    List<DocumentSnapshot> currentNotes = List<DocumentSnapshot>.from(_notes);

    // Because Firestore can only 'whereIn' on one field, we apply the second filter client-side.
    // If types were used in the server query, we only need to filter by languages here.
    if (_selectedTypes.isNotEmpty && _selectedLanguages.isNotEmpty) {
      currentNotes = currentNotes.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final noteLanguage = data['language'] as String? ?? '';
        return _selectedLanguages.contains(noteLanguage);
      }).toList();
    }

    // Apply search query filtering on the client side.
    if (_searchQuery.isNotEmpty) {
      currentNotes = currentNotes.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] as String? ?? '').toLowerCase();
        final content = (data['content'] as String? ?? '').toLowerCase();
        return title.contains(_searchQuery) || content.contains(_searchQuery);
      }).toList();
    }

    return currentNotes;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // This now triggers a full data refresh from Firestore.
  void updateFilters(Set<String> newSelectedTypes, Set<String> newSelectedLanguages) {
    _selectedTypes = newSelectedTypes;
    _selectedLanguages = newSelectedLanguages;
    // Fetch notes from the beginning with the new filters.
    fetchInitialNotes();
  }

  Future<void> deleteNote(String docId) async {
    // Optimistically remove the note from the UI
    final int index = _notes.indexWhere((doc) => doc.id == docId);
    if (index != -1) {
      final DocumentSnapshot deletedNote = _notes.removeAt(index);
      notifyListeners();

      try {
        await _firestoreService.deleteNote(docId);
      } catch (e) {
        // If deletion fails, re-insert the note and notify listeners
        _notes.insert(index, deletedNote);
        _error = "Failed to delete note: $e";
        notifyListeners();
        // Optionally, you might want to show a snackbar or other error message to the user
        // showCustomSnackBar(context, 'Failed to delete note', backgroundColor: Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
