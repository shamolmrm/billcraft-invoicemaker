import 'package:intl/intl.dart';

class DateFormatter {
  static final _full = DateFormat('dd/MM/yyyy');
  static final _medium = DateFormat('MMM dd, yyyy');
  static final _short = DateFormat('dd MMM');
  static final _monthYear = DateFormat('MMM yyyy');

  static String formatFull(DateTime date) => _full.format(date);
  static String formatMedium(DateTime date) => _medium.format(date);
  static String formatShort(DateTime date) => _short.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0 && diff <= 7) return 'In $diff days';
    if (diff < 0) return '${(-diff)} days ago';
    return formatMedium(date);
  }

  static String formatDueIn(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue by ${-diff} days';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }

  static String greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
