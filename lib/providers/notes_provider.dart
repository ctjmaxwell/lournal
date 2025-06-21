import 'dart:async';
import 'package:flutter/foundation.dart'; // Required for listEquals
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lournal/services/firestore.dart';

class NotesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  late StreamSubscription _notesSubscription;

  // Private state variables
  List<DocumentSnapshot> _allNotes = [];
  List<DocumentSnapshot> _filteredNotes = [];
  String _searchQuery = '';
  Set<String> _selectedTypes = {};
  Set<String> _selectedLanguages = {};
  bool _isLoading = true;
  String? _error;


  // Public getters for the UI to consume
  List<DocumentSnapshot> get filteredNotes => _filteredNotes;
  String get searchQuery => _searchQuery;
  Set<String> get selectedTypes => _selectedTypes;
  Set<String> get selectedLanguages => _selectedLanguages;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;


  // Constructor to kick off the data listening
  NotesProvider() {
    _listenToNotes();
  }

  void _listenToNotes() {
    _notesSubscription = _firestoreService.getNotesStream().listen(
      (snapshot) {
        _allNotes = snapshot.docs;
        _isLoading = false;
        _error = null;
        // When the base data changes, always re-filter and notify.
        _runFilter(); 
      },
      onError: (e) {
        _isLoading = false;
        _error = "Failed to load notes: $e";
        notifyListeners();
      },
    );
  }

  // A central method to apply the current filters to the full list of notes
  void _runFilter() {
    final oldFilteredList = List<DocumentSnapshot>.from(_filteredNotes);

    if (_searchQuery.isEmpty && _selectedTypes.isEmpty && _selectedLanguages.isEmpty) {
      _filteredNotes = List<DocumentSnapshot>.from(_allNotes);
    } else {
       _filteredNotes = _allNotes.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final noteType = data['type'] as String? ?? '';
        final noteLanguage = data['language'] as String? ?? '';
        final title = (data['title'] as String? ?? '').toLowerCase();
        final content = (data['content'] as String? ?? '').toLowerCase();

        if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(noteType)) return false;
        if (_selectedLanguages.isNotEmpty && !_selectedLanguages.contains(noteLanguage)) return false;
        if (_searchQuery.isNotEmpty && !title.contains(_searchQuery) && !content.contains(_searchQuery)) return false;
        
        return true;
      }).toList();
    }

    // *** THE KEY LOGIC ***
    // Only notify listeners if the filtered list has actually changed.
    if (!listEquals(oldFilteredList, _filteredNotes)) {
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _runFilter(); // Re-run the filter and notify IF needed
  }

  void updateFilters(Set<String> newSelectedTypes, Set<String> newSelectedLanguages) {
    _selectedTypes = newSelectedTypes;
    _selectedLanguages = newSelectedLanguages;
    _runFilter(); // Re-run the filter and notify IF needed
  }
  
  Future<void> deleteNote(String docId) async {
    await _firestoreService.deleteNote(docId);
    // The stream will automatically emit a new list, and our listener will handle it.
    // No direct need to call notifyListeners() here.
  }

  // Don't forget to dispose of the stream subscription!
  @override
  void dispose() {
    _notesSubscription.cancel();
    super.dispose();
  }
}