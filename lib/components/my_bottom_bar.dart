import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/helper/language_and_type_helper.dart'; // Adjust the path as needed

class MyBottomBar extends StatefulWidget {
  final Function(int) onPageSelected;
  final String defaultLanguage;

  const MyBottomBar({
    Key? key,
    required this.onPageSelected,
    required this.defaultLanguage,
  }) : super(key: key);

  static void showMakerSheet(BuildContext context, {required String defaultLanguage}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(75)),
      ),
      builder: (BuildContext context) {
        return MyBottomBar(
          onPageSelected: (int index) {},
          defaultLanguage: defaultLanguage,
        );
      },
    );
  }

  @override
  _MyBottomBarState createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  late String _selectedLanguage;
  late String _selectedCountryCode;
  late String _selectedType; // New state variable for type

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.defaultLanguage;
    // Use the helper method imported from language_and_type_helper.dart
    _selectedCountryCode = getCountryCodeForLanguage(_selectedLanguage);
    _selectedType = 'Diary'; // Default type selection
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = 350.0;
    return Container(
      height: sheetHeight,
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row with the flag and type button.
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountryFlagButton(context),
                _buildTypeButton(context),
              ],
            ),
          ),
          // Create button.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet first
                  Future.delayed(Duration(milliseconds: 100), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePage(
                          language: _selectedLanguage,
                          type: _selectedType,
                          content: "",
                          title: "",
                        ),
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
                child: Text(
                  "Create",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Circular close button.
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildCircularButton(Icons.close, "", context, isCloseButton: true),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFlagButton(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _showLanguageDropdown(context);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CountryFlag.fromCountryCode(
                  _selectedCountryCode,
                  width: 40,
                  height: 30,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text("Language", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTypeButton(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _showTypeDropdown(context);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Center(
              // Use the helper method to get the emoji for the selected type.
              child: Text(
                getEmojiForType(_selectedType),
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text("Type", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _showTypeDropdown(BuildContext context) async {
    final List<Map<String, String>> types = [
      {'emoji': '📖', 'name': 'Diary'},
      {'emoji': '🙏', 'name': 'Gratitude'},
      {'emoji': '💭', 'name': 'Dreams'},
      {'emoji': '💼', 'name': 'Study/Work'},
      {'emoji': '🏆', 'name': 'Goals'},
      {'emoji': '✈️', 'name': 'Travel'},
      {'emoji': '✍️', 'name': 'Creative Writing'},
      {'emoji': '💪', 'name': 'Health & Fitness'},
      {'emoji': '🗣️', 'name': 'Conversations'},
    ];

    // Reorder the list so that the currently selected type is at the top.
    List<Map<String, String>> orderedTypes = List.from(types);
    orderedTypes.removeWhere((type) => type['name'] == _selectedType);
    orderedTypes.insert(0, types.firstWhere((type) => type['name'] == _selectedType));

    final selectedType = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: orderedTypes.map((type) {
                    return Column(
                      children: [
                        Container(
                          color: type['name'] == _selectedType
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            minVerticalPadding: 22,
                            leading: Text(
                              type['emoji']!,
                              style: TextStyle(fontSize: 32),
                            ),
                            title: Text(
                              type['name']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, type['name']);
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
        );
      },
    );

    if (selectedType != null) {
      setState(() {
        _selectedType = selectedType;
      });
    }
  }

  Future<void> _showLanguageDropdown(BuildContext context) async {
    final List<String> languages = [
      'Spanish',
      'English',
      'French',
      'German',
      'Portuguese',
      'Italian',
      'Russian',
      'Chinese',
      'Japanese',
      'Korean'
    ];

    List<String> orderedLanguages = List.from(languages);
    if (orderedLanguages.contains(_selectedLanguage)) {
      orderedLanguages.remove(_selectedLanguage);
      orderedLanguages.insert(0, _selectedLanguage);
    }

    final selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: orderedLanguages.map((language) {
                    return Column(
                      children: [
                        Container(
                          color: language == _selectedLanguage
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            minVerticalPadding: 22,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CountryFlag.fromCountryCode(
                                // Use the helper method here as well.
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
        );
      },
    );

    if (selectedLanguage != null) {
      setState(() {
        _selectedLanguage = selectedLanguage;
        _selectedCountryCode = getCountryCodeForLanguage(selectedLanguage);
      });
    }
  }

  Widget _buildCircularButton(IconData icon, String text, BuildContext context, {bool isCloseButton = false}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (isCloseButton) Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.inversePrimary, size: 28),
          ),
        ),
        if (!isCloseButton) SizedBox(height: 8),
        if (!isCloseButton)
          Text(text, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
