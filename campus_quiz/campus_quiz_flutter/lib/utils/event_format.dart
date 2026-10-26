import 'package:campus_quiz_client/campus_quiz_client.dart';

const _weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Formats the event time as `Mon, 27 Oct · 10:00` or, when it ends the
/// same day, `Mon, 27 Oct · 10:00–18:00`; otherwise the end date is shown
/// on its own line, e.g. `Tue, 28 Oct · 18:00`.
String formatEventTime(DateTime startsAt, DateTime? endsAt) {
  final start = '${_formatDate(startsAt)} · ${_formatTime(startsAt)}';
  if (endsAt == null) return start;

  final sameDay =
      startsAt.year == endsAt.year &&
      startsAt.month == endsAt.month &&
      startsAt.day == endsAt.day;
  if (sameDay) {
    return '$start–${_formatTime(endsAt)}';
  }
  return '$start\n${_formatDate(endsAt)} · ${_formatTime(endsAt)}';
}

/// A short human label for a category value, e.g. `sports` → `Sports`.
String categoryLabel(String categoryName) {
  if (categoryName.isEmpty) return categoryName;
  return categoryName[0].toUpperCase() + categoryName.substring(1);
}

/// Labels used for the category filter chips, in display order.
List<String> get categoryFilterLabels => [
  'All',
  ...EventCategory.values.map((c) => categoryLabel(c.name)),
];

/// A short label for the student's current response.
String rsvpStatusLabel(RsvpStatus status) {
  return switch (status) {
    RsvpStatus.going => 'Going',
    RsvpStatus.interested => 'Interested',
  };
}
