// lib/helper/language_and_type_helper.dart

//================== LANGUAGE HELPERS ==================

/// The single source of truth for all supported language names.
const List<String> supportedLanguages = [
  'Spanish',
  'English',
  'French',
  'German',
  'Portuguese',
  'Italian',
  'Russian',
  'Chinese',
  'Japanese',
  'Korean',
  'Dutch',
  'Arabic',
  'Hindi',
  'Swahili',
  'Swedish',
  'Turkish',
];

/// Returns the country code for the given language.
String getCountryCodeForLanguage(String language) {
  switch (language.toLowerCase()) {
    case 'english':
      return 'US';
    case 'spanish':
      return 'ES';
    case 'portuguese':
      return 'BR';
    case 'french':
      return 'FR';
    case 'german':
      return 'DE';
    case 'italian':
      return 'IT';
    case 'russian':
      return 'RU';
    case 'chinese':
      return 'CN';
    case 'japanese':
      return 'JP';
    case 'korean':
      return 'KR';
    case 'dutch':
      return 'NL';
    case 'arabic':
      return 'SA';
    case 'hindi':
      return 'IN';
    case 'swahili':
      return 'KE';
    case 'swedish':
      return 'SE';
    case 'turkish':
      return 'TR';
    default:
      // Default to US flag if language is not found
      return 'US';
  }
}


//================== JOURNAL TYPE HELPERS ==================

/// The single source of truth for all journal type names.
const List<String> journalTypes = [
  'Diary',
  'Gratitude',
  'Dreams',
  'Study/Work',
  'Goals',
  'Travel',
  'Creative Writing',
  'Health & Fitness',
  'Conversations',
];

/// Returns the emoji associated with the type.
String getEmojiForType(String type) {
  switch (type) {
    case 'Diary':
      return '📖';
    case 'Gratitude':
      return '🙏';
    case 'Dreams':
      return '💭';
    case 'Study/Work':
      return '💼';
    case 'Goals':
      return '🏆';
    case 'Travel':
      return '✈️';
    case 'Creative Writing':
      return '✍️';
    case 'Health & Fitness':
      return '💪';
    case 'Conversations':
      return '🗣️';
    default:
      return '📖';
  }
}