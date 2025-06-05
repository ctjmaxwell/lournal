import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lournal/helper/language_and_type_helper.dart';

Future<Map<String, bool>?> showFilterBottomSheet(
  BuildContext context, {
  Set<String>? initialSelection,
}) {
  return showModalBottomSheet<Map<String, bool>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.92,
      child: _FilterBottomSheetContent(
        initialSelection: initialSelection ?? {},
      ),
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
  late bool _diarySelected;
  late bool _gratitudeSelected;
  late bool _dreamsSelected;
  late bool _studyWorkSelected;
  late bool _goalsSelected;
  late bool _travelSelected;
  late bool _creativeWritingSelected;
  late bool _healthFitnessSelected;
  late bool _conversationsSelected;

  late bool _englishSelected;
  late bool _spanishSelected;
  late bool _frenchSelected;
  late bool _germanSelected;
  late bool _portugueseSelected;
  late bool _italianSelected;
  late bool _russianSelected;
  late bool _chineseSelected;
  late bool _japaneseSelected;
  late bool _koreanSelected;

  @override
  void initState() {
    super.initState();
    final selected = widget.initialSelection;

    _diarySelected = selected.contains('Diary');
    _gratitudeSelected = selected.contains('Gratitude');
    _dreamsSelected = selected.contains('Dreams');
    _studyWorkSelected = selected.contains('Study/Work');
    _goalsSelected = selected.contains('Goals');
    _travelSelected = selected.contains('Travel');
    _creativeWritingSelected = selected.contains('Creative Writing');
    _healthFitnessSelected = selected.contains('Health & Fitness');
    _conversationsSelected = selected.contains('Conversations');

    _englishSelected = selected.contains('English');
    _spanishSelected = selected.contains('Spanish');
    _frenchSelected = selected.contains('French');
    _germanSelected = selected.contains('German');
    _portugueseSelected = selected.contains('Portuguese');
    _italianSelected = selected.contains('Italian');
    _russianSelected = selected.contains('Russian');
    _chineseSelected = selected.contains('Chinese');
    _japaneseSelected = selected.contains('Japanese');
    _koreanSelected = selected.contains('Korean');
  }

  void _onSave() {
    final result = <String, bool>{
      'Diary': _diarySelected,
      'Gratitude': _gratitudeSelected,
      'Dreams': _dreamsSelected,
      'Study/Work': _studyWorkSelected,
      'Goals': _goalsSelected,
      'Travel': _travelSelected,
      'Creative Writing': _creativeWritingSelected,
      'Health & Fitness': _healthFitnessSelected,
      'Conversations': _conversationsSelected,
      'English': _englishSelected,
      'Spanish': _spanishSelected,
      'French': _frenchSelected,
      'German': _germanSelected,
      'Portuguese': _portugueseSelected,
      'Italian': _italianSelected,
      'Russian': _russianSelected,
      'Chinese': _chineseSelected,
      'Japanese': _japaneseSelected,
      'Korean': _koreanSelected,
    };
    Navigator.pop(context, result);
  }

  Widget _buildTypeRow(
    String emoji,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      leading: Text(emoji, style: const TextStyle(fontSize: 30)),
      title: Text(label, style: const TextStyle(fontSize: 18)),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageRow(
    String language,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CountryFlag.fromCountryCode(
          getCountryCodeForLanguage(language),
          width: 35,
          height: 25,
        ),
      ),
      title: Text(language, style: const TextStyle(fontSize: 18)),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.92,
                ),
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
                          children: [
                            _buildTypeRow('📖', 'Diary', _diarySelected,
                                () => setState(() => _diarySelected = !_diarySelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('🙏', 'Gratitude', _gratitudeSelected,
                                () => setState(() => _gratitudeSelected = !_gratitudeSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('💭', 'Dreams', _dreamsSelected,
                                () => setState(() => _dreamsSelected = !_dreamsSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('💼', 'Study/Work', _studyWorkSelected,
                                () => setState(() => _studyWorkSelected = !_studyWorkSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('🏆', 'Goals', _goalsSelected,
                                () => setState(() => _goalsSelected = !_goalsSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('✈️', 'Travel', _travelSelected,
                                () => setState(() => _travelSelected = !_travelSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('✍️', 'Creative Writing', _creativeWritingSelected,
                                () => setState(() => _creativeWritingSelected = !_creativeWritingSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('💪', 'Health & Fitness', _healthFitnessSelected,
                                () => setState(() => _healthFitnessSelected = !_healthFitnessSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildTypeRow('🗣️', 'Conversations', _conversationsSelected,
                                () => setState(() => _conversationsSelected = !_conversationsSelected)),
                          ],
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
                          children: [
                            _buildLanguageRow('English', _englishSelected,
                                () => setState(() => _englishSelected = !_englishSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Spanish', _spanishSelected,
                                () => setState(() => _spanishSelected = !_spanishSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('French', _frenchSelected,
                                () => setState(() => _frenchSelected = !_frenchSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('German', _germanSelected,
                                () => setState(() => _germanSelected = !_germanSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Portuguese', _portugueseSelected,
                                () => setState(() => _portugueseSelected = !_portugueseSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Italian', _italianSelected,
                                () => setState(() => _italianSelected = !_italianSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Russian', _russianSelected,
                                () => setState(() => _russianSelected = !_russianSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Chinese', _chineseSelected,
                                () => setState(() => _chineseSelected = !_chineseSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Japanese', _japaneseSelected,
                                () => setState(() => _japaneseSelected = !_japaneseSelected)),
                            Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                            _buildLanguageRow('Korean', _koreanSelected,
                                () => setState(() => _koreanSelected = !_koreanSelected)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // For button space
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: SizedBox(
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
    );
  }
}
