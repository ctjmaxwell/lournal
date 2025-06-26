import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/helper/date_format_helper.dart';


void main() {
  group('formatHeaderDate', () {
    // Define a fixed "now" for consistent testing
    final fixedNow = DateTime(2025, 6, 20, 10, 30, 0); // Friday, June 20, 2025

    test('returns "Today" for the current date', () {
      final todayDate = DateTime(2025, 6, 20, 15, 0, 0); // Same day as fixedNow
      expect(formatHeaderDate(todayDate, now: fixedNow), 'Today, 20 Jun');
    });

    test('returns "Yesterday" for the previous date', () {
      final yesterdayDate = DateTime(2025, 6, 19, 9, 0, 0); // Day before fixedNow
      expect(formatHeaderDate(yesterdayDate, now: fixedNow), 'Yesterday, 19 Jun');
    });

    test('returns full date for a date in the past (not yesterday)', () {
      final pastDate = DateTime(2025, 6, 18); // Two days before fixedNow (Wednesday)
      expect(formatHeaderDate(pastDate, now: fixedNow), 'Wednesday, 18 Jun');
    });

    test('returns full date for a date in the future', () {
      final futureDate = DateTime(2025, 6, 21); // Day after fixedNow (Saturday)
      expect(formatHeaderDate(futureDate, now: fixedNow), 'Saturday, 21 Jun');
    });

    test('handles dates at the start of a month correctly (Today)', () {
      final nowAtMonthStart = DateTime(2025, 7, 1);
      final testDate = DateTime(2025, 7, 1, 10, 0, 0);
      expect(formatHeaderDate(testDate, now: nowAtMonthStart), 'Today, 1 Jul');
    });

    test('handles dates at the start of a month correctly (Yesterday)', () {
      final nowAtMonthStart = DateTime(2025, 7, 1);
      final testDate = DateTime(2025, 6, 30, 23, 59, 59); // Last day of previous month
      expect(formatHeaderDate(testDate, now: nowAtMonthStart), 'Yesterday, 30 Jun');
    });

    test('handles dates at the end of a month correctly (Past)', () {
      final nowAtMonthEnd = DateTime(2025, 6, 30);
      final testDate = DateTime(2025, 6, 28);
      expect(formatHeaderDate(testDate, now: nowAtMonthEnd), 'Saturday, 28 Jun');
    });

    test('handles different years (Past)', () {
      final nowInNewYear = DateTime(2026, 1, 15);
      final testDate = DateTime(2025, 12, 31); // Last day of previous year
      expect(formatHeaderDate(testDate, now: nowInNewYear), 'Wednesday, 31 Dec');
    });

    test('handles different years (Future)', () {
      final nowInOldYear = DateTime(2024, 12, 1);
      final testDate = DateTime(2025, 1, 1); // First day of next year
      expect(formatHeaderDate(testDate, now: nowInOldYear), 'Wednesday, 1 Jan');
    });
  });
}
