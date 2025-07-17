// firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- NEW: UserPreferences Model ---
// This model will represent the user's language preferences
class UserPreferences {
  final String nativeLanguage; // e.g., 'de', 'en', 'es'
  final String learningLanguage; // e.g., 'fr', 'ja', 'ko'

  UserPreferences({
    required this.nativeLanguage,
    required this.learningLanguage,
  });

  // Factory constructor to create UserPreferences from a Firestore DocumentSnapshot
  factory UserPreferences.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Use nullable map
    if (data == null) {
      // This case should ideally not happen if you're checking doc.exists() first
      // but provides safety.
      throw Exception("User preferences data is null for document: ${doc.id}");
    }
    return UserPreferences(
      nativeLanguage: data['nativeLanguage'] ?? 'en', // Default to English if not set
      learningLanguage: data['learningLanguage'] ?? 'es', // Default to Spanish if not set
    );
  }

  // Method to convert UserPreferences object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage,
    };
  }
}
// --- END NEW: UserPreferences Model ---


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

  // --- NEW: User Preferences Logic ---

  // Reference to the current user's document (where preferences will be stored)
  DocumentReference get currentUserDocumentRef {
    return FirebaseFirestore.instance.collection('users').doc(userId);
  }

  // CREATE/UPDATE: Set initial user preferences (or update existing ones)
  // This is used right after sign-up, and also for updating later.
  Future<void> setUserPreferences({
    required String nativeLanguage,
    required String learningLanguage,
    String? email, // Optional: for initial user document creation
    String? displayName, // Optional: for initial user document creation
  }) async {
    final dataToSet = UserPreferences(
      nativeLanguage: nativeLanguage,
      learningLanguage: learningLanguage,
    ).toFirestore();

    // Include other user info if this is the very first time creating the user document
    // (e.g., after initial sign-up)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      dataToSet['email'] = email ?? currentUser.email;
      dataToSet['displayName'] = displayName ?? currentUser.displayName;
      dataToSet['createdAt'] = FieldValue.serverTimestamp(); // Set creation timestamp only once
    }


    return currentUserDocumentRef.set(
      dataToSet,
      SetOptions(merge: true), // `merge: true` ensures only specified fields are updated/added
                               // without overwriting the entire document.
    );
  }

  // READ: Get a Future of user preferences
  Future<UserPreferences?> getUserPreferences() async {
    try {
      final docSnapshot = await currentUserDocumentRef.get();
      if (docSnapshot.exists) {
        return UserPreferences.fromFirestore(docSnapshot);
      }
      return null; // No preferences found for this user
    } catch (e) {
      print("Error getting user preferences: $e");
      return null;
    }
  }

  // READ: Get a Stream of user preferences (for real-time updates)
  Stream<UserPreferences?> streamUserPreferences() {
    return currentUserDocumentRef.snapshots().map((docSnapshot) {
      if (docSnapshot.exists) {
        return UserPreferences.fromFirestore(docSnapshot);
      }
      return null;
    });
  }

  // --- END NEW: User Preferences Logic ---


  // CREATE: Add a new note
  Future<void> addNote({
    required String title,
    required String content,
    required String language,
    required String type,
    required String translation,
    required String feedback,
    required int score,
    required String mood,
    String? imageUrl,
  }) {
    return userNotesCollection.add({
      'title': title,
      'content': content,
      'language': language,
      'type': type,
      'translation': translation,
      'feedback': feedback,
      'score': score,
      'mood': mood,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Get notes stream for the logged-in user
  Stream<QuerySnapshot> getNotesStream() {
    return userNotesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // READ: Get notes paginated
  Future<QuerySnapshot> getNotesPaginated({
    required int limit,
    DocumentSnapshot? lastDocument, // The last document from the previous page
  }) {
    Query query = userNotesCollection
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.get();
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
    required String mood,
    String? imageUrl,
  }) {
    final Map<String, dynamic> dataToUpdate = {
      'title': title,
      'content': content,
      'language': language,
      'type': type,
      'translation': translation,
      'feedback': feedback,
      'score': score,
      'mood': mood,
      'timestamp': Timestamp.now(), // Optionally update timestamp on edit
    };

    if (imageUrl != null) {
      dataToUpdate['imageUrl'] = imageUrl;
    }

    return userNotesCollection.doc(docID).update(dataToUpdate);
  }

  // DELETE: Delete a specific note given its ID
  Future<void> deleteNote(String docID) {
    return userNotesCollection.doc(docID).delete();
  }

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
  }
}