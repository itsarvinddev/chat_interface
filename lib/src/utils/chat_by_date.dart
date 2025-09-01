import 'package:intl/intl.dart';
import 'package:screwdriver/screwdriver.dart';

class ChatDateUtils {
  static String formatChatDate(DateTime date) {
    final localDate = date;
    final now = DateTime.now();

    if (localDate.isToday) {
      return 'Today';
    } else if (localDate.isYesterday) {
      return 'Yesterday';
    } else if (localDate.isTomorrow) {
      return 'Tomorrow';
    } else if (now.difference(localDate.dateOnly).inDays.abs() < 7) {
      return DateFormat('EEEE').format(localDate); // Monday, Tuesday, etc.
    } else if (localDate.year == now.year) {
      return DateFormat('MMM d').format(localDate); // Jan 15
    } else {
      return DateFormat('MMM d, yyyy').format(localDate); // Jan 15, 2024
    }
  }

  /// Checks if two DateTime objects represent the same day
  static bool isSameDay(DateTime a, DateTime b) {
    final localA = a;
    final localB = b;
    return localA.isSameDateAs(localB);
  }

  /// Decide header placement based on the order items are DISPLAYED in the list.
  ///
  /// - If reverse == true (as in your code), the item displayed "before" index
  ///   is index + 1. If reverse == false, it is index - 1.
  /// - This guarantees the header appears at the start of each day's group
  ///   in the on-screen order, regardless of how the data itself is sorted.
  static bool shouldShowHeaderForViewportOrder<T>({
    required List<T> items,
    required int index,
    required bool reverse,
    required DateTime Function(T item) createdAtOf,
  }) {
    if (items.isEmpty || index < 0 || index >= items.length) return false;

    final current = createdAtOf(items[index]);
    final prevIndexInViewport = reverse ? index + 1 : index - 1;

    // If there is no previous item in the viewport order, start a new group.
    if (prevIndexInViewport < 0 || prevIndexInViewport >= items.length) {
      return true;
    }

    final prev = createdAtOf(items[prevIndexInViewport]);
    return !isSameDay(current, prev);
  }
}
