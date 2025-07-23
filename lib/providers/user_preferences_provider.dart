import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lournal/services/firestore.dart';

class UserPreferencesProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

  // Private state
  UserPreferences? _userPreferences;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _authSubscription;
  StreamSubscription? _prefsSubscription;

  // Public getters
  UserPreferences? get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  // Default constructor for the app
  UserPreferencesProvider()
      : _auth = FirebaseAuth.instance,
        _firestoreService = FirestoreService() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Constructor for testing
  @visibleForTesting
  UserPreferencesProvider.testable(this._auth, this._firestoreService) {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _prefsSubscription?.cancel();
    if (user == null) {
      _userPreferences = null;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } else {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _prefsSubscription =
          _firestoreService.streamUserPreferences().listen((prefs) {
        _userPreferences = prefs;
        _isLoading = false;
        _error = null;
        notifyListeners();
      }, onError: (e) {
        _userPreferences = null;
        _isLoading = false;
        _error = "Failed to load user preferences: $e";
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _prefsSubscription?.cancel();
    super.dispose();
  }
}
