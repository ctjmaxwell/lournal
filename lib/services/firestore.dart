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
    // This getter relies on `userId`, which checks for a logged-in user.
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

  Future<void> deleteUserAccountAndData({required String userIdToDelete}) async {
    // --- Step 1: Delete all notes for the specified user ID from Firestore ---
    final notesCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userIdToDelete)
        .collection('notes');

    final QuerySnapshot notesSnapshot = await notesCollectionRef.get();
    if (notesSnapshot.docs.isNotEmpty) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot doc in notesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print("Firestore: All notes for user $userIdToDelete deleted.");
    } else {
      print("Firestore: No notes found for user $userIdToDelete.");
    }

    // --- Step 2: Delete the user's main document from the 'users' collection in Firestore ---
    await FirebaseFirestore.instance.collection('users').doc(userIdToDelete).delete();
    print("Firestore: User document $userIdToDelete deleted.");

    // --- Step 3: Attempt to delete user from Firebase Authentication IF it's the current user ---
    final User? currentUserAuth = FirebaseAuth.instance.currentUser;

    // Only attempt to delete the auth record if the provided userIdToDelete
    // matches the currently logged-in user.
    if (currentUserAuth != null && currentUserAuth.uid == userIdToDelete) {
      try {
        await currentUserAuth.delete();
        print("Firebase Auth: User $userIdToDelete successfully deleted.");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Data is deleted, but Auth record remains. Inform user.
          print("Firebase Auth: User $userIdToDelete delete failed - ${e.code}. Data already deleted.");
          throw FirebaseAuthException(
            code: e.code,
            message:
                "Your account data has been successfully deleted from our database. However, to complete the deletion of your authentication record, please sign out, sign back in, and attempt to delete your account again. Your authentication profile will remain until this is done.",
          );
        } else {
          // Data is deleted, but Auth record remains due to another auth error.
          print("Firebase Auth: User $userIdToDelete delete failed - ${e.code}. Data already deleted.");
          throw Exception(
              "Your account data has been deleted. However, an error occurred while removing your authentication record: ${e.message} (code: ${e.code})");
        }
      } catch (e) {
        // Data is deleted, but Auth record remains due to an unexpected error.
        print("Firebase Auth: User $userIdToDelete delete failed - unexpected error. Data already deleted. Error: $e");
        throw Exception(
            "Your account data has been deleted. However, an unexpected error occurred while removing your authentication record: $e");
      }
    } else if (currentUserAuth != null && currentUserAuth.uid != userIdToDelete) {
      // This case implies an attempt to delete data for a user (userIdToDelete)
      // who is not the currently logged-in user. The client SDK cannot delete
      // another user's auth record. This function will have only deleted their Firestore data.
      print("Firestore data for $userIdToDelete deleted. This user is not the currently authenticated user, so their authentication record was not targeted by this client operation.");
    } else {
      // No user currently logged in, or some other edge case. Firestore data for userIdToDelete was processed.
      print("Firestore data for $userIdToDelete deleted. No authenticated user session found to attempt matching auth record deletion, or userIdToDelete did not match any active session.");
    }
  }
}