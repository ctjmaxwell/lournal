import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lournal/helper/language_and_type_helper.dart'; // Assuming this file exists and is correct

Future<Map<String, bool>?> showFilterBottomSheet(
  BuildContext context, {
  Set<String>? initialSelection,
}) {
  return showModalBottomSheet<Map<String, bool>>(
    context: context,
    isScrollControlled: true, // Important for full-screen or near full-screen sheets
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => _FilterBottomSheetContent(
      initialSelection: initialSelection ?? {},
    ),
  );
}

class _FilterBottomSheetContent extends StatefulWidget {
  final Set<String> initialSelection;

  const _FilterBottomSheetContent({Key? key, required this.initialSelection})
      : super(key: key);

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late Map<String, bool> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = {
      for (var type in journalTypes)
        type: widget.initialSelection.contains(type),
      for (var lang in supportedLanguages)
        lang: widget.initialSelection.contains(lang),
    };
  }

  void _onSave() {
    Navigator.pop(context, _selectedFilters);
  }

  Widget _buildTypeRow(
    String emoji,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      leading: Text(emoji, style: const TextStyle(fontSize: 25)),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: Icon(
        isSelected ? Icons.circle : Icons.radio_button_unchecked,
        size: 22,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageRow(
    String language,
    bool isSelected,
    VoidCallback onTap,
  ) {
    String countryCode = getCountryCodeForLanguage(language);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CountryFlag.fromCountryCode(
          countryCode,
          width: 25,
          height: 18,
        ),
      ),
      title: Text(language, style: const TextStyle(fontSize: 16)),
      trailing: Icon(
        isSelected ? Icons.circle : Icons.radio_button_unchecked,
        size: 22,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: journalTypes.map((type) {
                          return Column(
                            children: [
                              _buildTypeRow(
                                getEmojiForType(type),
                                type,
                                _selectedFilters[type] ?? false,
                                () => setState(() => _selectedFilters[type] =
                                    !(_selectedFilters[type] ?? false)),
                              ),
                              if (journalTypes.last != type)
                                Divider(
                                    height: 1,
                                    color: Theme.of(context).colorScheme.surface),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: supportedLanguages.map((language) {
                          return Column(
                            children: [
                              _buildLanguageRow(
                                language,
                                _selectedFilters[language] ?? false,
                                () => setState(() =>
                                    _selectedFilters[language] =
                                        !(_selectedFilters[language] ?? false)),
                              ),
                              if (supportedLanguages.last != language)
                                Divider(
                                    height: 1,
                                    color: Theme.of(context).colorScheme.surface),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for button: ensures content scrolls above button
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20, // Button position
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}