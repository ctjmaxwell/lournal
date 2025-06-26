import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lournal/services/firestore.dart';

class NotesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late StreamSubscription _authSubscription;
  StreamSubscription? _notesSubscription;

  // Private state variables
  List<DocumentSnapshot> _allNotes = [];
  List<DocumentSnapshot> _filteredNotes = [];
  String _searchQuery = '';
  Set<String> _selectedTypes = {};
  Set<String> _selectedLanguages = {};
  bool _isLoading = true;
  String? _error;

  // Public getters
  List<DocumentSnapshot> get filteredNotes => _filteredNotes;
  String get searchQuery => _searchQuery;
  Set<String> get selectedTypes => _selectedTypes;
  Set<String> get selectedLanguages => _selectedLanguages;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  NotesProvider() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _notesSubscription?.cancel();
    if (user == null) {
      _allNotes = [];
      _filteredNotes = [];
      _isLoading = false; // Set to false, not true
      _error = null;
      notifyListeners();
    } else {
      _isLoading = true;
      // You may want to notify here to immediately show a loader on re-login
      // notifyListeners(); 
      _listenToNotes();
    }
  }

  void _listenToNotes() {
    _notesSubscription?.cancel();
    _notesSubscription = _firestoreService.getNotesStream().listen(
      (snapshot) {
        _allNotes = snapshot.docs;
        _isLoading = false;
        _error = null;
        // First, apply the filter to the new data
        _runFilter();
        // **FIX:** Then, always notify listeners that the data fetch is complete.
        // This ensures the UI updates from the loading state.
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = "Failed to load notes: $e";
        _allNotes = [];
        _filteredNotes = [];
        notifyListeners();
      },
    );
  }

  // **CHANGE:** This method should ONLY filter, not notify.
  void _runFilter() {
    if (_searchQuery.isEmpty && _selectedTypes.isEmpty && _selectedLanguages.isEmpty) {
      _filteredNotes = List<DocumentSnapshot>.from(_allNotes);
    } else {
       _filteredNotes = _allNotes.where((doc) {
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

  // **CHANGE:** Public methods should now call notifyListeners.
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _runFilter();
    notifyListeners(); // Notify after updating the query and re-filtering.
  }

  void updateFilters(Set<String> newSelectedTypes, Set<String> newSelectedLanguages) {
    _selectedTypes = newSelectedTypes;
    _selectedLanguages = newSelectedLanguages;
    _runFilter();
    notifyListeners(); // Notify after updating filters and re-filtering.
  }
  
  Future<void> deleteNote(String docId) async {
    // Note deletion will be handled automatically by the stream,
    // which will fire and trigger the update cycle above.
    await _firestoreService.deleteNote(docId);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _notesSubscription?.cancel();
    super.dispose();
  }
}