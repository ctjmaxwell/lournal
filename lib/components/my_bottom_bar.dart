import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/helper/language_and_type_helper.dart'; // Adjust the path as needed
import 'language_bottomsheet.dart'; // Import the language bottom sheet
import 'type_bottomsheet.dart'; // Import the type bottom sheet

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
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.defaultLanguage;
    _selectedCountryCode = getCountryCodeForLanguage(_selectedLanguage);
    _selectedType = 'Diary';
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
          onTap: () async {
            final selectedLanguage = await showLanguageDropdown(context, _selectedLanguage);
            if (selectedLanguage != null) {
              setState(() {
                _selectedLanguage = selectedLanguage;
                _selectedCountryCode = getCountryCodeForLanguage(selectedLanguage);
              });
            }
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
          onTap: () async {
            final selectedType = await showTypeDropdown(context, _selectedType);
            if (selectedType != null) {
              setState(() {
                _selectedType = selectedType;
              });
            }
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