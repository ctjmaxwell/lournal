import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/helper/perfomance_adjective.dart';



void main() {
  group('getAdjectiveForPerformance', () {
    test('returns "Perfect" for a score of 100', () {
      expect(getAdjectiveForPerformance(100), 'Perfect');
    });

    test('returns "Excellent" for a score of 95', () {
      expect(getAdjectiveForPerformance(95), 'Excellent');
    });

    test('returns "Excellent" for a score of 90', () {
      expect(getAdjectiveForPerformance(90), 'Excellent');
    });

    test('returns "Great" for a score of 85', () {
      expect(getAdjectiveForPerformance(85), 'Great');
    });

    test('returns "Great" for a score of 80', () {
      expect(getAdjectiveForPerformance(80), 'Great');
    });

    test('returns "Good" for a score of 75', () {
      expect(getAdjectiveForPerformance(75), 'Good');
    });

    test('returns "Good" for a score of 70', () {
      expect(getAdjectiveForPerformance(70), 'Good');
    });

    test('returns "Fair" for a score of 65', () {
      expect(getAdjectiveForPerformance(65), 'Fair');
    });

    test('returns "Fair" for a score of 60', () {
      expect(getAdjectiveForPerformance(60), 'Fair');
    });

    test('returns "Developing" for a score of 55', () {
      expect(getAdjectiveForPerformance(55), 'Developing');
    });

    test('returns "Developing" for a score of 50', () {
      expect(getAdjectiveForPerformance(50), 'Developing');
    });

    test('returns "Needs Work" for a score of 40', () {
      expect(getAdjectiveForPerformance(40), 'Needs Work');
    });

    test('returns "Needs Work" for a score of 30', () {
      expect(getAdjectiveForPerformance(30), 'Needs Work');
    });

    test('returns "Beginner" for a score of 15', () {
      expect(getAdjectiveForPerformance(15), 'Beginner');
    });

    test('returns "Beginner" for a score of 1', () {
      expect(getAdjectiveForPerformance(1), 'Beginner');
    });

    test('returns "Unrated" for a score of 0', () {
      expect(getAdjectiveForPerformance(0), 'Unrated');
    });

    test('returns "Unrated" for a negative score', () {
      expect(getAdjectiveForPerformance(-10), 'Unrated');
    });
  });
}