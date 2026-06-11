import 'package:intl/intl.dart';

extension DateEx on DateTime {
  /// `dd/MM/yyyy` — e.g. `09/06/2026`.
  String getFormatDayMonthYear() => DateFormat('dd/MM/yyyy').format(this);

  /// Time of day — e.g. `3:04 PM`. Useful for message timestamps.
  String get messageTime => DateFormat('h:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return year == y.year && month == y.month && day == y.day;
  }

  /// Section label for chat lists: `Today`, `Yesterday`, or `dd/MM/yyyy`.
  String get chatLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return getFormatDayMonthYear();
  }

  /// Compact "time ago" string — e.g. `now`, `5m`, `3h`, `2d`.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return getFormatDayMonthYear();
  }
}
