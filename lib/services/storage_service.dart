import 'dart:io'; // Required for File
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A service class for handling Firebase Storage operations.
///
/// This service is now stateless and provides a direct method for uploading
/// images related to a specific note.
class StorageService {
  // Firebase storage instance
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Uploads an image for a specific note to a user-specific folder.
  ///
  /// The image is stored in `users/{UID}/note_images/`.
  /// Returns the public download URL on success, or null on failure.
  Future<String?> uploadNoteImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // In a real app, you might want to throw a more specific error.
      print("Error: User not logged in, cannot upload image.");
      return null;
    }

    try {
      // Create a unique path for the image in a user-specific folder.
      final filePath =
          'users/${user.uid}/note_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _firebaseStorage.ref(filePath);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Error uploading note image: ${e.message}");
      return null;
    } catch (e) {
      print("An unexpected error occurred during note image upload: $e");
      return null;
    }
  }
}