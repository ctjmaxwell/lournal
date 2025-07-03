import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

class AuthService {
  // FIX 1: Use the singleton instance of GoogleSignIn.
  // Scopes are now passed to the `authenticate` method, not the constructor.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Private constructor
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  GoogleSignInAccount? _currentUser;
  bool _isGoogleSignInInitialized = false;

  /// Initializes Google Sign-In. This should be called once when the app starts.
  Future<void> initialize() async {
    if (_isGoogleSignInInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
      log('Google Sign-In Initialized');
    } catch (e) {
      log('Failed to initialize Google Sign-In: $e');
    }
  }

  /// Ensures that Google Sign-In is initialized before use.
  Future<void> _ensureInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await initialize();
    }
  }

  /// Signs in with Google and links the credential to a Firebase user.
  /// Returns a [UserCredential] on success or throws an exception on failure.
  Future<UserCredential> signInWithGoogle() async {
    await _ensureInitialized();

    try {
      // FIX 2: Replace `signIn()` with `authenticate()`.
      // The `scopeHint` parameter is used to request specific scopes.
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      if (googleUser == null) {
        // The user canceled the sign-in
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'The sign-in was canceled by the user.',
        );
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // FIX 3: Use `idToken` for Firebase. `accessToken` is not needed for
      // this authentication flow and is no longer directly available on `googleAuth`.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null, // Access token is not required for Firebase sign-in.
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      _currentUser = googleUser;

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      log('An unexpected error occurred during Google Sign-In: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Signs out from both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    log('User signed out');
  }

  /// Returns the current Google user account if available.
  GoogleSignInAccount? get currentUser => _currentUser;
}