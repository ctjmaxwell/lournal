
String getLanguageCode(String language) {
  switch (language.toLowerCase()) {
    case 'english':
      return 'en';
    case 'spanish':
      return 'es';
    case 'french':
      return 'fr';
    case 'german':
      return 'de';
    case 'portuguese':
      return 'pt';
    case 'italian':
      return 'it';
    case 'russian':
      return 'ru';
    case 'chinese':
      return 'zh';
    case 'japanese':
      return 'ja';
    case 'korean':
      return 'ko';
    case 'dutch':
      return 'nl';
    case 'arabic':
      return 'ar';
    case 'hindi':
      return 'hi';
    case 'swahili':
      return 'sw';
    case 'swedish':
      return 'sv';
    case 'turkish':
      return 'tr';
    default:
      return 'en'; // Default to English
  }
}
