import 'package:intl/intl.dart';
import 'package:screwdriver/screwdriver.dart';

// class DateGroupedMessages {
//   final DateTime date;
//   final List<ChatMessage> messages;

//   DateGroupedMessages({required this.date, required this.messages});
// }

class ChatDateUtils {
  static String formatChatDate(DateTime date) {
    final now = DateTime.now();
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate.isToday) {
      return 'Today';
    } else if (messageDate.isYesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Monday, Tuesday, etc.
    } else if (messageDate.year == now.year) {
      return DateFormat('MMM d').format(date); // Jan 15
    } else {
      return DateFormat('MMM d, yyyy').format(date); // Jan 15, 2024
    }
  }

  /// Checks if two DateTime objects represent the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    // return a.year == b.year && a.month == b.month && a.day == b.day;
    return a.isSameDateAs(b);
  }

  // static List<DateGroupedMessages> groupMessagesByDate(
  //   List<ChatMessage> messages,
  // ) {
  //   final Map<DateTime, List<ChatMessage>> grouped = {};

  //   for (final message in messages) {
  //     final messageDate = message.createdAt ?? DateTime.now();

  //     if (grouped[messageDate] == null) {
  //       grouped[messageDate] = [];
  //     }
  //     grouped[messageDate]!.add(message);
  //   }

  //   return grouped.entries
  //       .map(
  //         (entry) =>
  //             DateGroupedMessages(date: entry.key, messages: entry.value),
  //       )
  //       .toList()
  //     ..sort((a, b) => a.date.compareTo(b.date));
  // }
}
