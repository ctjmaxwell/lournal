import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
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
    this.onDeletePressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    // Define text styles
    const TextStyle emojiStyle = TextStyle(fontSize: 24);
    // Using color from the theme for better adaptability
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

    return GestureDetector(
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
            ),
          ),
        );
      },
      onLongPress: () {
        // Get the RenderBox of the GestureDetector (the NotesTile) to find its width
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

        if (renderBox != null) {
          final tileWidth = renderBox.size.width;
          const popoverWidth = 175.0; // This must match the width property of showPopover

          // Calculate the horizontal offset for the arrow (and thus the popover body)
          // This will align the right edge of the popover with the right edge of the tile
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
                    ),
                  ),
                );
              },
            ),
            width: popoverWidth, // Use the constant here
            backgroundColor: Theme.of(context).colorScheme.secondary,
            transitionDuration: const Duration(milliseconds: 150),
            transition: PopoverTransition.scale,
            barrierDismissible: true,
            arrowHeight: 0, // Keeping arrow invisible as in original code
            arrowDxOffset: calculatedArrowDxOffset, // Apply the calculated offset
            direction: PopoverDirection.bottom, // Explicitly set or rely on default
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        // MODIFIED MARGIN: Reduced top and bottom margin
        margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Main column alignment
          children: [
            // ─── First Row: Emoji, (Column: Type, Title), Country Flag ─────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Vertically align items in the Row
              children: [
                Text(
                  getEmojiForType(type),
                  style: emojiStyle,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10), // Add some padding to the right
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically if emoji/flag are taller
                      children: [
                        Text(
                          type,
                          style: typeStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        // const SizedBox(height: 2),
                        Text(
                          title,
                          style: titleStyle,
                          overflow: TextOverflow.ellipsis, // This will add "..."
                          maxLines: 1,                      // Ensure it's single line for ellipsis
                        ),
                      ],
                    ),
                  ),
                ),
                // No Spacer needed here as Expanded handles the space
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
            const SizedBox(height: 8), // Spacing between the top row and content text

            // ─── Content Text ───────────────────────────────────────────
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: contentStyle,
            ),
          ],
        ),
      ),
    );
  }
}