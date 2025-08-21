import 'package:intl/intl.dart';

class TimeUtils {
  /// Formats message timestamp with smart relative time
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // If it's today, show relative time
    if (_isToday(timestamp)) {
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      }
    }

    // If it's yesterday, show "Yesterday"
    if (_isYesterday(timestamp)) {
      return 'Yesterday';
    }

    // If it's this week, show day name
    if (_isThisWeek(timestamp)) {
      return _getDayName(timestamp);
    }

    // If it's this year, show month and day
    if (_isThisYear(timestamp)) {
      return DateFormat('MMM d').format(timestamp);
    }

    // If it's older, show month, day, and year
    return DateFormat('MMM d, y').format(timestamp);
  }

  /// Formats message time for list view (more compact)
  static String formatMessageTimeCompact(DateTime timestamp) {
    // If it's today, show time
    if (_isToday(timestamp)) {
      return DateFormat('HH:mm').format(timestamp);
    }

    // If it's yesterday, show "Yesterday"
    if (_isYesterday(timestamp)) {
      return 'Yesterday';
    }

    // If it's this week, show day name
    if (_isThisWeek(timestamp)) {
      return _getDayNameShort(timestamp);
    }

    // If it's this year, show month and day
    if (_isThisYear(timestamp)) {
      return DateFormat('MMM d').format(timestamp);
    }

    // If it's older, show month and year
    return DateFormat('MMM y').format(timestamp);
  }

  /// Formats message time for detailed view
  static String formatMessageTimeDetailed(DateTime timestamp) {
    // If it's today, show time
    if (_isToday(timestamp)) {
      return DateFormat('HH:mm').format(timestamp);
    }

    // If it's yesterday, show "Yesterday at time"
    if (_isYesterday(timestamp)) {
      return 'Yesterday at ${DateFormat('HH:mm').format(timestamp)}';
    }

    // If it's this week, show "Day at time"
    if (_isThisWeek(timestamp)) {
      return '${_getDayName(timestamp)} at ${DateFormat('HH:mm').format(timestamp)}';
    }

    // If it's this year, show "Month Day at time"
    if (_isThisYear(timestamp)) {
      return '${DateFormat('MMM d').format(timestamp)} at ${DateFormat('HH:mm').format(timestamp)}';
    }

    // If it's older, show full date and time
    return DateFormat('MMM d, y at HH:mm').format(timestamp);
  }

  /// Checks if date is today
  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if date is yesterday
  static bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Checks if date is this week
  static bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  /// Checks if date is this year
  static bool _isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  /// Gets full day name
  static String _getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Gets short day name
  static String _getDayNameShort(DateTime date) {
    return DateFormat('E').format(date);
  }

  /// Formats date for date headers in chat
  static String formatDateHeader(DateTime date) {
    if (_isToday(date)) {
      return 'Today';
    } else if (_isYesterday(date)) {
      return 'Yesterday';
    } else if (_isThisWeek(date)) {
      return _getDayName(date);
    } else if (_isThisYear(date)) {
      return DateFormat('MMMM d').format(date);
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  /// Checks if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
