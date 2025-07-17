// firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- UserPreferences Model (UPDATED) ---
// This model will represent the user's language preferences and onboarding status
class UserPreferences {
  final String nativeLanguage; // e.g., 'de', 'en', 'es'
  final String learningLanguage; // e.g., 'fr', 'ja', 'ko'
  final bool onboardingComplete; // NEW: Flag for onboarding status

  UserPreferences({
    required this.nativeLanguage,
    required this.learningLanguage,
    this.onboardingComplete = false, // NEW: Default to false
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
      onboardingComplete: data['onboardingComplete'] ?? false, // NEW: Default to false if not present
    );
  }

  // Method to convert UserPreferences object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage,
      'onboardingComplete': onboardingComplete, // NEW: Include in map
    };
  }

  // NEW: copyWith method for easier updates
  UserPreferences copyWith({
    String? nativeLanguage,
    String? learningLanguage,
    bool? onboardingComplete,
  }) {
    return UserPreferences(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
// --- END UserPreferences Model ---


class FirestoreService {
  // Initialize Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    return _db.collection('users').doc(userId).collection('notes');
  }

  // --- User Preferences Logic (UPDATED) ---

  // Private method to get the current user's document reference
  // It accepts a UID for flexibility (e.g., when creating a document right after sign-up)
  DocumentReference _currentUserDocumentRef(String uid) {
    return _db.collection('users').doc(uid);
  }

  // CREATE/UPDATE: Set initial user preferences (or update existing ones)
  // This is used right after sign-up, and also for updating later.
  // It now explicitly requires the UID to ensure correct document targeting.
  Future<void> setUserPreferences({
    required String uid, // IMPORTANT: Pass UID explicitly here
    required String nativeLanguage,
    required String learningLanguage,
    String? email, // Optional: for initial user document creation
    String? displayName, // Optional: for initial user document creation
    bool onboardingComplete = false, // Parameter for onboarding status, defaults to false
  }) async {
    // Create the data map for preferences and onboarding status
    final dataToSet = UserPreferences(
      nativeLanguage: nativeLanguage,
      learningLanguage: learningLanguage,
      onboardingComplete: onboardingComplete,
    ).toFirestore();

    final userDocRef = _currentUserDocumentRef(uid); // Get the document reference
    final existingDoc = await userDocRef.get(); // Check if the document already exists

    // ✅ FIXED: Cast the data() object to a Map once
    final data = existingDoc.data() as Map<String, dynamic>?;

    // Only set email, displayName, and createdAt if the document is being created
    // or these fields don't exist yet (important for existing users before this feature)
    if (!existingDoc.exists) {
      // Document is brand new, add initial user details
      dataToSet['email'] = email;
      dataToSet['displayName'] = displayName;
      dataToSet['createdAt'] = FieldValue.serverTimestamp(); // Set creation timestamp
    } else {
      // Document exists, but ensure email/displayName are set if they were missing
      // (e.g., for older users or specific auth providers)
      // ✅ FIXED: Use the typed 'data' variable
      if (email != null && data?['email'] == null) {
          dataToSet['email'] = email;
      }
      // ✅ FIXED: Use the typed 'data' variable
      if (displayName != null && data?['displayName'] == null) {
          dataToSet['displayName'] = displayName;
      }
    }

    // Use set with merge: true to update only specified fields or create if not exists
    return userDocRef.set(
      dataToSet,
      SetOptions(merge: true),
    );
  }

  // READ: Get a Future of user preferences for the currently logged-in user
  Future<UserPreferences?> getUserPreferences() async {
    try {
      // Use the userId getter to get the current user's UID
      final docSnapshot = await _currentUserDocumentRef(userId).get();
      if (docSnapshot.exists) {
        return UserPreferences.fromFirestore(docSnapshot);
      }
      return null; // No preferences found for this user
    } catch (e) {
      // ✅ FIXED: Removed print statement.
      // For production, consider using a logging framework instead of print.
      return null;
    }
  }

  // READ: Get a Stream of user preferences for the currently logged-in user (for real-time updates)
  Stream<UserPreferences?> streamUserPreferences() {
    // Use the userId getter to get the current user's UID
    return _currentUserDocumentRef(userId).snapshots().map((docSnapshot) {
      if (docSnapshot.exists) {
        return UserPreferences.fromFirestore(docSnapshot);
      }
      return null;
    });
  }

  // NEW: Method to specifically mark onboarding as complete for the current user
  Future<void> markOnboardingComplete() async {
    // Uses the userId getter to get the current user's UID
    return _currentUserDocumentRef(userId).update({
      'onboardingComplete': true,
    });
  }

  // --- END User Preferences Logic ---


  // CREATE: Add a new note
  Future<void> addNote({
    required String title,
    required String content,
    required String language,
    required String type,
    required String translation,
    required String feedback,
    required int score,
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
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Get notes stream for the logged-in user
  Stream<QuerySnapshot> getNotesStream() {
    // Ensure 'timestamp' field exists and is indexed in Firestore for orderBy
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
      'timestamp': Timestamp.now(), // Optionally update timestamp on edit
    };

    if (imageUrl != null) {
      dataToUpdate['imageUrl'] = imageUrl;
    } else {
      // If imageUrl is null, and you want to explicitly remove the field,
      // you could add: dataToUpdate['imageUrl'] = FieldValue.delete();
      // However, the current logic only adds if not null, which means
      // existing imageUrls will persist if not explicitly provided.
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