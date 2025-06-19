import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lournal/pages/finish_page.dart';
import 'package:lournal/services/firestore.dart';

class CreatePage extends StatefulWidget {
  final String? docID; // Firestore document ID
  final String language;
  final String type;
  final String title;
  final String content;

  const CreatePage({
    Key? key,
    this.docID,
    required this.language,
    required this.type,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  // State variable to track the saving process
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // If the widget title is not empty, use it as the initial text
    if (widget.title.isNotEmpty) {
      _titleController.text = widget.title;
    }
    // Optionally, do the same with content if needed:
    if (widget.content.isNotEmpty) {
      _contentController.text = widget.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
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

      try {
        final HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('processNoteWithAI');
        final result = await callable.call({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'language': widget.language,
        });

        final String generatedTranslation = result.data['translation'];
        final String generatedFeedback = result.data['feedback'];
        final String generatedScoreString = result.data['score'];

        
        // Try parsing the string to an int, default to 0 if it fails
        final int generatedScoreInt = int.tryParse(generatedScoreString) ?? 0;

        // Clamp the score between 0 and 100
        generatedScoreInt.clamp(0, 100);

        if (widget.docID != null) {
          await firestoreService.updateNote(
          docID: widget.docID!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          language: widget.language,
          type: widget.type,
          translation: generatedTranslation,
          feedback: generatedFeedback,
          score: generatedScoreInt,
        );
        } else {
          await firestoreService.addNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          language: widget.language,
          type: widget.type,
          translation: generatedTranslation,
          feedback: generatedFeedback,
          score: generatedScoreInt,
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
                score: generatedScoreInt,
                language: widget.language,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to process note. Please try again.'),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter both a title and content before saving'),
        ),
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
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    cursorColor: Theme.of(context).colorScheme.tertiary,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      // Move focus to the content text field when the return key is pressed.
                      FocusScope.of(context).requestFocus(_contentFocusNode);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    cursorColor: Theme.of(context).colorScheme.tertiary,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 16),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your Lournal...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 16,
                bottom: bottomInset > 32 ? bottomInset + 16 : 32,
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40, // Adjust the width as desired
                      height: 40, // Adjust the height as desired
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.tertiary,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: const Text(
                        'Generating AI feedback for your Lournal...',
                        style: TextStyle(
                          fontSize: 22,
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
