import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/helper/congrats_helper.dart';


void main() {
  group('getCongratsForLanguage', () {
    test('returns "Well done!" for English', () {
      expect(getCongratsForLanguage('English'), 'Well done!');
      expect(getCongratsForLanguage('english'), 'Well done!');
      expect(getCongratsForLanguage('ENGLISH'), 'Well done!');
    });

    test('returns correct phrase for Spanish', () {
      expect(getCongratsForLanguage('Spanish'), '¡Bien hecho!');
    });

    test('returns correct phrase for Portuguese', () {
      expect(getCongratsForLanguage('Portuguese'), 'Parabéns!');
    });

    test('returns correct phrase for French', () {
      expect(getCongratsForLanguage('French'), 'Bravo !');
    });

    test('returns correct phrase for German', () {
      expect(getCongratsForLanguage('German'), 'Gut gemacht!');
    });

    test('returns correct phrase for Italian', () {
      expect(getCongratsForLanguage('Italian'), 'Ben fatto!');
    });

    test('returns correct phrase for Russian', () {
      expect(getCongratsForLanguage('Russian'), 'Молодец!');
    });

    test('returns correct phrase for Chinese', () {
      expect(getCongratsForLanguage('Chinese'), '干得好！');
    });

    test('returns correct phrase for Japanese', () {
      expect(getCongratsForLanguage('Japanese'), 'よくやった！');
    });

    test('returns correct phrase for Korean', () {
      expect(getCongratsForLanguage('Korean'), '잘했어요!');
    });

    test('returns default "Well done!" for unknown language', () {
      expect(getCongratsForLanguage('UnknownLanguage'), 'Well done!');
      expect(getCongratsForLanguage('XYZ'), 'Well done!');
      expect(getCongratsForLanguage(''), 'Well done!'); // Empty string case
    });
  });
}
