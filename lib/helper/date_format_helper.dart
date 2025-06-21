import 'package:intl/intl.dart';

// Helper method to format date headers
String formatHeaderDate(DateTime dt) {
  final now = DateTime.now();
  final aDate = DateTime(dt.year, dt.month, dt.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (aDate == today) return 'Today, ${DateFormat('d MMM').format(dt)}';
  if (aDate == yesterday) return 'Yesterday, ${DateFormat('d MMM').format(dt)}';
  return DateFormat('EEEE, d MMM').format(dt);
}