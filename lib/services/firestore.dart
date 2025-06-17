// firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Get current user's UID
  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  // Reference to the current user's notes collection
  CollectionReference get userNotesCollection {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('notes');
  }

  // CREATE: Add a new note
  Future<void> addNote({
    required String title,
    required String content,
    required String language,
    required String type,
    required String translation,
    required String feedback,
    required int score,
  }) {
    return userNotesCollection.add({
      'title': title,
      'content': content,
      'language': language,
      'type': type,
      'translation': translation,
      'feedback': feedback,
      'score': score,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Get notes stream for the logged-in user
  Stream<QuerySnapshot> getNotesStream() {
    return userNotesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // UPDATE: Update an existing note
  Future<void> updateNote({
    required String docID,
    required String title,
    required String content,
    required String language,
    required String type,
    required String translation,
    required String feedback,
    required int score,
  }) {
    return userNotesCollection.doc(docID).update({
      'title': title,
      'content': content,
      'language': language,
      'type': type,
      'translation': translation,
      'feedback': feedback,
      'score': score,
      'timestamp': Timestamp.now(), // Optionally update timestamp on edit
    });
  }

  // DELETE: Delete a specific note given its ID
  Future<void> deleteNote(String docID) {
    return userNotesCollection.doc(docID).delete();
  }

  /// Deletes the currently authenticated Firebase user account.
  ///
  /// IMPORTANT: The Firebase "Delete User Data" extension should be
  /// installed and configured in your Firebase project (with
  /// "Cloud Firestore delete mode" set to **Recursive** and
  /// "Cloud Firestore paths" including `users/{UID}`).
  /// This extension will automatically handle the deletion of associated
  /// Cloud Firestore data (like the user document in `users/{UID}`
  /// and its `notes` subcollection).
  ///
  /// This method should typically be called *after* ensuring the user
  /// has recently authenticated. If not, `FirebaseAuthException` with
  /// 'requires-recent-login' will be thrown, and you'll need to
  /// re-authenticate the user in your UI before trying again.
  ///
  /// Throws a [FirebaseAuthException] if:
  /// - No user is currently signed in.
  /// - The user has not recently signed in (requires re-authentication).
  /// - Other Firebase Authentication errors occur during deletion.
  Future<void> deleteUserAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-signed-in',
        message: 'No user is currently signed in to delete.',
      );
    }

    // This single call to `user.delete()` will trigger the Firebase extension
    // to remove the associated Cloud Firestore data.
    await user.delete();
    print('Firebase Auth user account deletion initiated successfully.');
  }
}
