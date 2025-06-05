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

  // Reference to the user's notes collection
  CollectionReference get userNotesCollection {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('notes');
  }

  // CREATE: Add a new note with title, content, and timestamp
  Future<void> addNote({required String title, required String content, required String language, required String type, required String translation, required String feedback, required int score}) {
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

  
  Future<void> updateNote({required String docID, required String title, required String content, required String language, required String type, required String translation, required String feedback, required int score}) {
    return userNotesCollection.doc(docID).update({
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

  // DELETE: Delete a note given its ID
  Future<void> deleteNote(String docID) {
    return userNotesCollection.doc(docID).delete();
  }
}
