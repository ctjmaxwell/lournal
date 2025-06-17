import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
// Import your helper file to get the list of languages.
import 'package:lournal/helper/language_and_type_helper.dart'; // Adjust the path as needed

Future<String?> showLanguageDropdown(BuildContext context, String currentLanguage) async {
  // Create the ordered list directly from your single source of truth.
  List<String> orderedLanguages = List.from(supportedLanguages);
  if (orderedLanguages.contains(currentLanguage)) {
    orderedLanguages.remove(currentLanguage);
    orderedLanguages.insert(0, currentLanguage);
  }

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    // 1. Set useSafeArea to true for better handling of system intrusions
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 1,
        // 2. Move SafeArea to be the child of the sizing box and parent of the content column
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  // No changes needed in the list itself
                  children: orderedLanguages.map((language) {
                    return Column(
                      children: [
                        Container(
                          color: language == currentLanguage
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            minVerticalPadding: 22,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CountryFlag.fromCountryCode(
                                getCountryCodeForLanguage(language),
                                width: 35,
                                height: 25,
                              ),
                            ),
                            title: Text(
                              language,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, language);
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