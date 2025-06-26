import 'package:flutter/material.dart';

class ReadOnlyPage extends StatelessWidget {
  final String docID; // Firestore document ID
  final String title;
  final String content;
  final String translation;
  final String feedback;

  const ReadOnlyPage({
    super.key,
    required this.docID,
    required this.title,
    required this.content,
    required this.translation,
    required this.feedback,
  });

  void navigateBack(BuildContext context) {
    Navigator.pop(context); // Just pop to go back with default animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navigateBack(context),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              // Note container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minHeight: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Display
                    SelectableText(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Thin separator
                    Divider(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      thickness: 1,
                      height: 10,
                    ),

                    // Content Display
                    SelectableText(
                      content,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Separator text
              const Text(
                'Translation:',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Translation box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minHeight: 200),
                child: SelectableText(
                  translation,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Separator text
              const Text(
                'AI Feedback:',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Static AI Feedback box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minHeight: 300),
                child: SelectableText(
                  feedback,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
