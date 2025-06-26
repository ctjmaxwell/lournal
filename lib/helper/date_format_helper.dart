import 'package:intl/intl.dart';

// Modified helper method to format date headers for testability
String formatHeaderDate(DateTime dt, {DateTime? now}) {
  // Use the provided 'now' DateTime for testing, otherwise use DateTime.now()
  final effectiveNow = now ?? DateTime.now();

  final aDate = DateTime(dt.year, dt.month, dt.day);
  final today = DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (aDate == today) {
    return 'Today, ${DateFormat('d MMM').format(dt)}';
  }
  if (aDate == yesterday) {
    return 'Yesterday, ${DateFormat('d MMM').format(dt)}';
  }
  return DateFormat('EEEE, d MMM').format(dt);
}