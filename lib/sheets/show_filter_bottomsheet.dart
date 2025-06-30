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
  // Type selections
  late bool _diarySelected;
  late bool _gratitudeSelected;
  late bool _dreamsSelected;
  late bool _studyWorkSelected;
  late bool _goalsSelected;
  late bool _travelSelected;
  late bool _creativeWritingSelected;
  late bool _healthFitnessSelected;
  late bool _conversationsSelected;

  // Language selections
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
  late bool _dutchSelected;
  late bool _arabicSelected;
  late bool _hindiSelected;
  late bool _swahiliSelected;
  late bool _swedishSelected;
  late bool _turkishSelected;

  @override
  void initState() {
    super.initState();
    final selected = widget.initialSelection;

    // Initialize type selections
    _diarySelected = selected.contains('Diary');
    _gratitudeSelected = selected.contains('Gratitude');
    _dreamsSelected = selected.contains('Dreams');
    _studyWorkSelected = selected.contains('Study/Work');
    _goalsSelected = selected.contains('Goals');
    _travelSelected = selected.contains('Travel');
    _creativeWritingSelected = selected.contains('Creative Writing');
    _healthFitnessSelected = selected.contains('Health & Fitness');
    _conversationsSelected = selected.contains('Conversations');

    // Initialize language selections
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
    _dutchSelected = selected.contains('Dutch');
    _arabicSelected = selected.contains('Arabic');
    _hindiSelected = selected.contains('Hindi');
    _swahiliSelected = selected.contains('Swahili');
    _swedishSelected = selected.contains('Swedish');
    _turkishSelected = selected.contains('Turkish');
  }

  void _onSave() {
    final result = <String, bool>{
      // Types
      'Diary': _diarySelected,
      'Gratitude': _gratitudeSelected,
      'Dreams': _dreamsSelected,
      'Study/Work': _studyWorkSelected,
      'Goals': _goalsSelected,
      'Travel': _travelSelected,
      'Creative Writing': _creativeWritingSelected,
      'Health & Fitness': _healthFitnessSelected,
      'Conversations': _conversationsSelected,
      // Languages
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
      'Dutch': _dutchSelected,
      'Arabic': _arabicSelected,
      'Hindi': _hindiSelected,
      'Swahili': _swahiliSelected,
      'Swedish': _swedishSelected,
      'Turkish': _turkishSelected,
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
                          Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                           _buildLanguageRow('Dutch', _dutchSelected,
                              () => setState(() => _dutchSelected = !_dutchSelected)),
                          Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                           _buildLanguageRow('Arabic', _arabicSelected,
                              () => setState(() => _arabicSelected = !_arabicSelected)),
                          Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                           _buildLanguageRow('Hindi', _hindiSelected,
                              () => setState(() => _hindiSelected = !_hindiSelected)),
                          Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                           _buildLanguageRow('Swahili', _swahiliSelected,
                              () => setState(() => _swahiliSelected = !_swahiliSelected)),
                          Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                           _buildLanguageRow('Swedish', _swedishSelected,
                              () => setState(() => _swedishSelected = !_swedishSelected)),
                          Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                           _buildLanguageRow('Turkish', _turkishSelected,
                              () => setState(() => _turkishSelected = !_turkishSelected)),
                        ],
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