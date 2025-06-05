// lib/helper/language_and_type_helper.dart

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
    default:
      return 'US';
  }
}

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
