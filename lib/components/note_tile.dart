import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/note_settings.dart';
import 'package:lournal/helper/language_and_type_helper.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/pages/edit_page.dart';
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
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

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
      child: Container(
        padding: const EdgeInsets.only(
          right: 10,
          left: 10,
          top: 2,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── First Row ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
                Builder(
                  builder: (iconContext) => IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      showPopover(
                        context: iconContext,
                        bodyBuilder: (context) => NoteSettings(
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
                        width: 175,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        transitionDuration:
                            const Duration(milliseconds: 150),
                        transition: PopoverTransition.scale,
                        barrierDismissible: true,
                        arrowHeight: 0,
                      );
                    },
                  ),
                ),
              ],
            ),
            // ─── Second Row ──────────────────────────────────────────────
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: CountryFlag.fromCountryCode(
                    getCountryCodeForLanguage(language),
                    width: 25,
                    height: 18.75,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  getEmojiForType(type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            // ─── Content Text ────────────────────────────────────────────
            Text(
              content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
