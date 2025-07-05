import 'package:flutter/material.dart';
import 'package:lournal/components/note_settings.dart';
import 'package:lournal/helper/perfomance_adjective.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:popover/popover.dart';

class EditPage extends StatelessWidget {
  final String docID;
  final String title;
  final String content;
  final String translation;
  final String feedback;
  final String type;
  final String language;
  final int score;
  final String? imageUrl;
  // The FirestoreService is now nullable to allow for a const constructor.
  final FirestoreService? firestoreService;

  const EditPage({
    super.key,
    required this.docID,
    required this.title,
    required this.content,
    required this.translation,
    required this.feedback,
    required this.type,
    required this.language,
    required this.score,
    this.imageUrl,
    // The default value has been removed to fix the compile error.
    this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided firestoreService, or create a new instance if it's null.
    // This allows for dependency injection in tests while working in production.
    final effectiveFirestoreService = firestoreService ?? FirestoreService();
    final double progress = score / 100.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
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
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                onPressed: () {
                  showPopover(
                    context: context,
                    bodyBuilder: (context) => NoteSettings(
                      onDeleteTap: () {
                        // Use the effective service instance.
                        effectiveFirestoreService.deleteNote(docID);
                        // Pop twice to close the popover and the edit page.
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      onEditTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePage(
                              docID: docID,
                              type: type,
                              language: language,
                              title: title,
                              content: content,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                    width: 175,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    transitionDuration: const Duration(milliseconds: 150),
                    transition: PopoverTransition.scale,
                    barrierDismissible: true,
                    arrowHeight: 0,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The image has been removed from here.

              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      translation,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // The image is now placed here, between the two main containers.
              // A vertical padding is used to create space around it.
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                // If there's no image, we still add space to separate the boxes.
                const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Performance",
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          getAdjectiveForPerformance(score),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          "$score%",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      feedback,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}