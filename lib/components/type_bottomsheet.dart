import 'package:flutter/material.dart';
import 'package:lournal/helper/language_and_type_helper.dart'; // Adjust path as needed

Future<String?> showTypeDropdown(BuildContext context, String currentType) async {
  // Create the ordered list directly from your single source of truth.
  List<String> orderedTypes = List.from(journalTypes);
  orderedTypes.remove(currentType);
  orderedTypes.insert(0, currentType);

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    // 1. Set useSafeArea to true for robust handling of system intrusions
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 1,
        // 2. Wrap the content Column with SafeArea
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  // Map over the list of type names (Strings).
                  children: orderedTypes.map((type) {
                    return Column(
                      children: [
                        Container(
                          color: type == currentType
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            minVerticalPadding: 22,
                            leading: Text(
                              // Call your helper function to get the emoji!
                              getEmojiForType(type),
                              style: TextStyle(fontSize: 32),
                            ),
                            title: Text(
                              type, // The type is just the string itself.
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, type);
                            },
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0,
                          thickness: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}