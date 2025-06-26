import 'package:flutter_test/flutter_test.dart';

import 'package:lournal/helper/language_and_type_helper.dart';

void main() {
  group('Language Helpers', () {
    test('supportedLanguages list is not empty', () {
      expect(supportedLanguages, isNotEmpty);
    });

    test('supportedLanguages list contains expected languages', () {
      expect(supportedLanguages, containsAll([
        'English', 'Spanish', 'French', 'German', 'Portuguese', 'Italian',
        'Russian', 'Chinese', 'Japanese', 'Korean', 'Dutch', 'Arabic',
        'Hindi', 'Swahili', 'Swedish', 'Turkish'
      ]));
      expect(supportedLanguages, hasLength(16)); // Ensure no unexpected additions
    });

    group('getCountryCodeForLanguage', () {
      test('returns "US" for English (case insensitive)', () {
        expect(getCountryCodeForLanguage('English'), 'US');
        expect(getCountryCodeForLanguage('english'), 'US');
        expect(getCountryCodeForLanguage('ENGLISH'), 'US');
      });

      test('returns "ES" for Spanish', () {
        expect(getCountryCodeForLanguage('Spanish'), 'ES');
      });

      test('returns "BR" for Portuguese', () {
        expect(getCountryCodeForLanguage('Portuguese'), 'BR');
      });

      test('returns "FR" for French', () {
        expect(getCountryCodeForLanguage('French'), 'FR');
      });

      test('returns "DE" for German', () {
        expect(getCountryCodeForLanguage('German'), 'DE');
      });

      test('returns "IT" for Italian', () {
        expect(getCountryCodeForLanguage('Italian'), 'IT');
      });

      test('returns "RU" for Russian', () {
        expect(getCountryCodeForLanguage('Russian'), 'RU');
      });

      test('returns "CN" for Chinese', () {
        expect(getCountryCodeForLanguage('Chinese'), 'CN');
      });

      test('returns "JP" for Japanese', () {
        expect(getCountryCodeForLanguage('Japanese'), 'JP');
      });

      test('returns "KR" for Korean', () {
        expect(getCountryCodeForLanguage('Korean'), 'KR');
      });

      test('returns "NL" for Dutch', () {
        expect(getCountryCodeForLanguage('Dutch'), 'NL');
      });

      test('returns "SA" for Arabic', () {
        expect(getCountryCodeForLanguage('Arabic'), 'SA');
      });

      test('returns "IN" for Hindi', () {
        expect(getCountryCodeForLanguage('Hindi'), 'IN');
      });

      test('returns "KE" for Swahili', () {
        expect(getCountryCodeForLanguage('Swahili'), 'KE');
      });

      test('returns "SE" for Swedish', () {
        expect(getCountryCodeForLanguage('Swedish'), 'SE');
      });

      test('returns "TR" for Turkish', () {
        expect(getCountryCodeForLanguage('Turkish'), 'TR');
      });

      test('returns default "US" for unknown language', () {
        expect(getCountryCodeForLanguage('Klingon'), 'US');
        expect(getCountryCodeForLanguage(''), 'US');
        expect(getCountryCodeForLanguage('gibberish'), 'US');
      });
    });
  });

  group('Journal Type Helpers', () {
    test('journalTypes list is not empty', () {
      expect(journalTypes, isNotEmpty);
    });

    test('journalTypes list contains expected types', () {
      expect(journalTypes, containsAll([
        'Diary', 'Gratitude', 'Dreams', 'Study/Work', 'Goals', 'Travel',
        'Creative Writing', 'Health & Fitness', 'Conversations'
      ]));
      expect(journalTypes, hasLength(9)); // Ensure no unexpected additions
    });

    group('getEmojiForType', () {
      test('returns correct emoji for Diary', () {
        expect(getEmojiForType('Diary'), '📖');
      });

      test('returns correct emoji for Gratitude', () {
        expect(getEmojiForType('Gratitude'), '🙏');
      });

      test('returns correct emoji for Dreams', () {
        expect(getEmojiForType('Dreams'), '💭');
      });

      test('returns correct emoji for Study/Work', () {
        expect(getEmojiForType('Study/Work'), '💼');
      });

      test('returns correct emoji for Goals', () {
        expect(getEmojiForType('Goals'), '🏆');
      });

      test('returns correct emoji for Travel', () {
        expect(getEmojiForType('Travel'), '✈️');
      });

      test('returns correct emoji for Creative Writing', () {
        expect(getEmojiForType('Creative Writing'), '✍️');
      });

      test('returns correct emoji for Health & Fitness', () {
        expect(getEmojiForType('Health & Fitness'), '💪');
      });

      test('returns correct emoji for Conversations', () {
        expect(getEmojiForType('Conversations'), '🗣️');
      });

      test('returns default emoji "📖" for unknown type', () {
        expect(getEmojiForType('UnknownType'), '📖');
        expect(getEmojiForType(''), '📖');
        expect(getEmojiForType('Random'), '📖');
      });
    });
  });
}
