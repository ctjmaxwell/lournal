import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/pages/finish_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:lournal/services/storage_service.dart';
// import 'package:lournal/widgets/custom_snackbar.dart';

// Assuming showCustomSnackBar is defined in an imported file.
void showCustomSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.tertiary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    ),
  );
}


class CreatePage extends StatefulWidget {
  final String? docID; // Firestore document ID
  final String language;
  final String type;
  final String title;
  final String content;
  final String? imageUrl;

  // For testability, we allow injecting these services.
  // In the main app, they will be null and the widget will use the default instances.
  final FirestoreService? firestoreService;
  final FirebaseFunctions? functions;
  final StorageService? storageService;

  const CreatePage({
    super.key, // This is the change!
    this.docID,
    required this.language,
    required this.type,
    required this.title,
    required this.content,
    this.imageUrl,
    this.firestoreService,
    this.functions,
    this.storageService,
  });

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // These will hold the service instances to use.
  // They are initialized in initState.
  late final FirestoreService _firestoreService;
  late final FirebaseFunctions _functions;
  late final StorageService _storageService;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  // State variable to track the saving process
  bool _isSaving = false;
  File? _selectedImage;
  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    // Use the injected services if they exist, otherwise use the default instances.
    // This allows for mocking during tests.
    _firestoreService = widget.firestoreService ?? FirestoreService();
    _functions = widget.functions ?? FirebaseFunctions.instance;
    _storageService = widget.storageService ?? StorageService();

    // If the widget title is not empty, use it as the initial text
    if (widget.title.isNotEmpty) {
      _titleController.text = widget.title;
    }
    // Optionally, do the same with content if needed:
    if (widget.content.isNotEmpty) {
      _contentController.text = widget.content;
    }

    if (widget.imageUrl != null) {
      _networkImageUrl = widget.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _networkImageUrl = null;
    });
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _networkImageUrl = null; // Clear network image if a new local one is picked
      });
    }
  }

  void saveNote() async {
  // Dismiss the keyboard.
  FocusScope.of(context).unfocus();

  if (_titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty &&
      widget.language.isNotEmpty) {
    setState(() {
      _isSaving = true;
    });

    String? finalImageUrl = _networkImageUrl;

    try {
      if (_selectedImage != null) {
        finalImageUrl = await _storageService.uploadNoteImage(_selectedImage!);
        if (finalImageUrl == null) {
          throw Exception("Image upload failed.");
        }
      }

      // Use the _functions instance (which could be a mock)
      final HttpsCallable callable =
          _functions.httpsCallable('processNoteWithAI');

      // --- LOGGING INPUTS (What you are sending) ---
      // This will print the exact data being sent to your Cloud Function.
      log('--- SENDING DATA TO CLOUD FUNCTION ---');
      log('Title: ${_titleController.text.trim()}');
      log('Content: ${_contentController.text.trim()}');
      log('Language: ${widget.language}');
      log('------------------------------------');

      final result = await callable.call({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'language': widget.language,
      });

      // --- LOGGING OUTPUTS (What you are getting back) ---
      final String generatedTranslation = result.data['translation'];
      final String generatedFeedback = result.data['feedback'];
      final String generatedScoreString = result.data['score'];

      log('--- RECEIVED DATA FROM CLOUD FUNCTION ---');
      log('Raw Translation: $generatedTranslation');
      log('Raw Feedback: $generatedFeedback');
      log('Raw Score (as String): "$generatedScoreString"'); // Log the raw string
      log('-----------------------------------------');


      // --- LOGGING BEFORE AND AFTER CLAMP ---
      // Try parsing the string to an int, default to 0 if it fails
      final int generatedScoreInt = int.tryParse(generatedScoreString) ?? 0;

      // This is the value *before* clamping
      log('SCORE (Before Clamp): $generatedScoreInt');

      // CORRECTED: clamp returns a new value, it doesn't modify in place.
      final int clampedScore = generatedScoreInt.clamp(0, 100);

      // This is the value *after* clamping
      log('SCORE (After Clamp): $clampedScore');
      log('-----------------------------------');


      if (widget.docID != null) {
        // Use the _firestoreService instance
        await _firestoreService.updateNote(
          docID: widget.docID!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          language: widget.language,
          type: widget.type,
          translation: generatedTranslation,
          feedback: generatedFeedback,
          score: clampedScore, // Use the clamped score
          imageUrl: finalImageUrl,
        );
      } else {
        await _firestoreService.addNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          language: widget.language,
          type: widget.type,
          translation: generatedTranslation,
          feedback: generatedFeedback,
          score: clampedScore, // Use the clamped score
          imageUrl: finalImageUrl,
        );
      }

      // Dismiss the overlay then navigate back.
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FinishPage(
              wordCount: _contentController.text.trim().split(" ").length,
              score: clampedScore, // Use the clamped score
              language: widget.language,
            ),
          ),
        );
      }
    } catch (e, s) { // Also catch the stack trace for more details
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        // --- LOGGING THE ERROR ---
        log('!!! ERROR processing note !!!', error: e, stackTrace: s);

        showCustomSnackBar(
          context,
          'Failed to process note. Please ensure you are online and try again.',
          backgroundColor: Colors.red,
        );
      }
    }
  } else {
    showCustomSnackBar(
      context,
      'Please enter both a title and content before saving',
      backgroundColor: Colors.red,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
      // Conditionally show the app bar only when not saving.
      appBar: _isSaving
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
      body: Stack(
        children: [
          // Main content including text fields and save button.
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset + 100),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 16.0, right: 16.0, left: 16.0),
              child: Column(
                children: [
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_networkImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              _networkImageUrl!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    // Added a key for testing
                    key: const ValueKey('title_field'),
                    controller: _titleController,
                    autofocus: true,
                    cursorColor: Theme.of(context).colorScheme.tertiary,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      // Move focus to the content text field when the return key is pressed.
                      FocusScope.of(context).requestFocus(_contentFocusNode);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    // Added a key for testing
                    key: const ValueKey('content_field'),
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    cursorColor: Theme.of(context).colorScheme.tertiary,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 16),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your Lournal...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // New Floating Action Button on the left
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24, // Provides horizontal spacing from the edge
                bottom: bottomInset > 32 ? bottomInset + 16 : 32,
              ),
              child: FloatingActionButton(
                heroTag: 'saveFabLeft', // Unique hero tag to avoid conflicts
                onPressed: _isSaving ? null : _pickImage,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.inversePrimary, // Sets the icon color
                elevation: 0, // Removes shadow for a flat look
                shape: CircleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.inversePrimary, width: 1.5), // Grey border
                ),
                child: const Icon(Icons.add), // Changed icon to a plus sign
              ),
            ),
          ),
          // Original Save button on the right
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 24,
                bottom: bottomInset > 32 ? bottomInset + 16 : 32,
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          // Overlay widget to show the progress indicator and text.
          if (_isSaving)
            Container(
              color: Theme.of(context).colorScheme.primary,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40, // Adjust the width as desired
                      height: 40, // Adjust the height as desired
                      child: CustomCircularProgressIndicator(),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Generating AI feedback...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}