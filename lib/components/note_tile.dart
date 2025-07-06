import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/components/note_settings.dart';
import 'package:lournal/helper/language_and_type_helper.dart';
import 'package:lournal/pages/create_page.dart'; // Used by popover's edit
import 'package:lournal/pages/edit_page.dart'; // Used by onTap
import 'package:lournal/services/firestore.dart';
import 'package:popover/popover.dart';

class NotesTile extends StatelessWidget {
  final String docId; // Firestore document ID
  final String title;
  final String content;
  final String translation;
  final String feedback;
  final String type;
  final String language;
  final int score;
  final String? imageUrl;
  final void Function()? onDeletePressed;
  final void Function()? onEditPressed;

  const NotesTile({
    super.key,
    required this.docId,
    required this.title,
    required this.content,
    required this.translation,
    required this.feedback,
    required this.type,
    required this.score,
    required this.language,
    this.imageUrl,
    this.onDeletePressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    // Define text styles
    const TextStyle emojiStyle = TextStyle(fontSize: 24);
    const TextStyle typeStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w900,
    );
    const TextStyle titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    const TextStyle contentStyle = TextStyle(
      fontSize: 14,
    );

    return Container(
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPage(
                docID: docId,
                title: title,
                content: content,
                translation: translation,
                feedback: feedback,
                type: type,
                language: language,
                score: score,
                imageUrl: imageUrl,
              ),
            ),
          );
        },
        onLongPress: () {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final tileWidth = renderBox.size.width;
            const popoverWidth = 175.0;
            final calculatedArrowDxOffset = (tileWidth - popoverWidth) / 2;

            showPopover(
              context: context,
              bodyBuilder: (popoverContext) => NoteSettings(
                onDeleteTap: () {
                  firestoreService.deleteNote(docId);
                },
                onEditTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePage(
                        docID: docId,
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
              width: popoverWidth,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              transitionDuration: const Duration(milliseconds: 150),
              barrierDismissible: true,
              arrowHeight: 0,
              arrowDxOffset: calculatedArrowDxOffset,
              direction: PopoverDirection.bottom,
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The main content tile is now at the top
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                // If there's an image, round the top corners.
                // Otherwise, round all corners.
                borderRadius: hasImage
                    ? const BorderRadius.vertical(top: Radius.circular(12.0))
                    : BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(getEmojiForType(type), style: emojiStyle),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              style: typeStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              title,
                              style: titleStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: CountryFlag.fromCountryCode(
                          getCountryCodeForLanguage(language),
                          width: 28,
                          height: 21,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: contentStyle,
                  ),
                ],
              ),
            ),

            // Conditionally display the gap and the image at the bottom
            if (hasImage) ...[
              const SizedBox(height: 4),
              ClipRRect(
                // Round the bottom corners of the image
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12.0)),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 250, // Image height is now 250
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: CustomCircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}