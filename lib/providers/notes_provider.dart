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
      fetchInitialNotes();
    }
  }

  Future<void> fetchInitialNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getNotesPaginated(limit: _notesPerPage);
      _notes = snapshot.docs;
      if (_notes.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      } else {
        _lastDocument = null;
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

  List<DocumentSnapshot> _getFilteredNotes() {
    if (_searchQuery.isEmpty && _selectedTypes.isEmpty && _selectedLanguages.isEmpty) {
      return List<DocumentSnapshot>.from(_notes);
    } else {
       return _notes.where((doc) {
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

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void updateFilters(Set<String> newSelectedTypes, Set<String> newSelectedLanguages) {
    _selectedTypes = newSelectedTypes;
    _selectedLanguages = newSelectedLanguages;
    notifyListeners();
  }
  
  Future<void> deleteNote(String docId) async {
    await _firestoreService.deleteNote(docId);
    _notes.removeWhere((doc) => doc.id == docId);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
