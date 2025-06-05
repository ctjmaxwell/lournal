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
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
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
                        firestoreService.deleteNote(docID);
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
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
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      translation,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
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
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          "$score%",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
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
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
