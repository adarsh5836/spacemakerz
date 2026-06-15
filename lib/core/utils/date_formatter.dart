class AppDateFormatter {
  static const List<String> _months = [
    '',
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

  /// Formats a String or DateTime to local Date & Time.
  /// Example output: "23 May 2026 • 07:24 PM"
  static String formatDateTime(dynamic date) {
    if (date == null) return '--';
    DateTime? parsed;
    if (date is DateTime) {
      parsed = date;
    } else if (date is String) {
      if (date.isEmpty) return '--';
      parsed = DateTime.tryParse(date);
    }
    if (parsed == null) return date.toString();

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _months[local.month];
    final year = local.year;

    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minutes = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year • ${hour12.toString().padLeft(2, '0')}:$minutes $ampm';
  }

  /// Formats a String or DateTime to local Date & Time with slash format.
  /// Example output: "23/05/2026 07:24 PM"
  static String formatDateTimeSlash(dynamic date) {
    if (date == null) return '--';
    DateTime? parsed;
    if (date is DateTime) {
      parsed = date;
    } else if (date is String) {
      if (date.isEmpty) return '--';
      parsed = DateTime.tryParse(date);
    }
    if (parsed == null) return date.toString();

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;

    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minutes = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year ${hour12.toString().padLeft(2, '0')}:$minutes $ampm';
  }

  /// Formats a String or DateTime to local Date only.
  /// Example output: "23 May 2026"
  static String formatDate(dynamic date) {
    if (date == null) return '--';
    DateTime? parsed;
    if (date is DateTime) {
      parsed = date;
    } else if (date is String) {
      if (date.isEmpty) return '--';
      parsed = DateTime.tryParse(date);
    }
    if (parsed == null) return date.toString();

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _months[local.month];
    final year = local.year;

    return '$day $month $year';
  }
}
