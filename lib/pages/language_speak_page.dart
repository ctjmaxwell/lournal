import 'package:flutter/material.dart';
import 'package:lournal/helper/language_and_type_helper.dart';
import 'package:lournal/helper/language_option.dart';

// Renamed to match the file name and converted to a StatefulWidget
class LanguageSpeakPage extends StatefulWidget {
  // Accepts the set of currently selected languages
  final Set<String> initialSelection;

  const LanguageSpeakPage({
    super.key,
    this.initialSelection = const {},
  });

  @override
  State<LanguageSpeakPage> createState() => _LanguageSpeakPageState();
}

class _LanguageSpeakPageState extends State<LanguageSpeakPage> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        widget.initialSelection.isNotEmpty ? widget.initialSelection.first : null;
  }

  void _toggleLanguageSelection(String language) {
    setState(() {
      if (_selectedLanguage == language) {
        _selectedLanguage = null;
      } else {
        _selectedLanguage = language;
      }
    });
  }

  void _onDone() {
    final result = {
      for (var lang in supportedLanguages) lang: lang == _selectedLanguage
    };
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      "What is the main language \nyou speak?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...supportedLanguages.map((language) {
                    final isSelected = _selectedLanguage == language;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: LanguageOption(
                        flagCode: getCountryCodeForLanguage(language),
                        language: language,
                        isSelected: isSelected,
                        onTap: () => _toggleLanguageSelection(language),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(120),
                        ),
                      ),
                      onPressed: _onDone,
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
