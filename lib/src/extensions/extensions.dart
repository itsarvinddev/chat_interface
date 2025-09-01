import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:screwdriver/screwdriver.dart';

extension TargetPlatformExtension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;

  bool get isIOS => this == TargetPlatform.iOS;

  //  only supports Android & iOS as of now.
  bool get isAudioWaveformsSupported => isIOS || isAndroid;
}

extension ListExtension<T> on List<T> {
  /// Returns the first element that matches [test], or `null` if none found.
  T? firstWhereOrNull(bool Function(T element) test) {
    final valuesLength = length;
    for (var i = 0; i < valuesLength; i++) {
      final element = this[i];
      if (test(element)) return element;
    }
    return null;
  }

  /// Extension method to convert a list to a map with customizable key-value pairs.
  /// * required: [getKey] to extract the key from each element of the list.
  ///
  /// (optional): [getValue] to determines the value associated with each element in the resulting map.
  /// If not provided, the elements themselves will be used as values.
  ///
  /// (optional): [where] return all elements that satisfy the predicate [where].
  /// Example:
  /// ```dart
  /// final numbers = <int>[1,2,3,4,5,6,7];
  /// result = numbers.toMap<int, int>(getKey: (e) => e, where: (x) => x > 5); // {6: 6, 7: 7}
  /// ```
  Map<K, V> toMap<K, V>({
    required K? Function(T element) getKey,
    V Function(T element)? getValue,
    bool Function(T element)? where,
  }) {
    assert(
      getValue == null && T is! V,
      'Ensure generic type of value of map is same as generic type of list',
    );

    final mapList = <K, V>{};

    for (final element in this) {
      if (element == null) continue;
      if (where != null && !where(element)) continue;
      final key = getKey(element);
      if (key == null) continue;
      mapList[key] = (getValue?.call(element) ?? element) as V;
    }
    return mapList;
  }
}

String strFormattedSize(num size) {
  size /= 1024;

  final suffixes = ["KB", "MB", "GB", "TB"];
  String suffix = "";

  for (suffix in suffixes) {
    if (size < 1024) {
      break;
    }

    size /= 1024;
  }

  return "${size.toStringAsFixed(2)}$suffix";
}

String formattedDateTime(
  DateTime dateTime, [
  bool timeOnly = false,
  bool meridiem = false,
]) {
  DateTime now = DateTime.now();
  DateTime date = dateTime;

  if (timeOnly || now.isSameDateAs(date)) {
    return meridiem
        ? DateFormat('hh:mm a').format(date)
        : DateFormat('HH:mm').format(date);
  }

  if (date.isYesterday) {
    return 'Yesterday';
  }

  return DateFormat.yMd().format(date);
}

String timeFromSeconds(int seconds, [bool minWidth4 = false]) {
  if (seconds == 0) return "0:00";

  String result = DateFormat('HH:mm:ss').format(
    DateTime(2022, 1, 1, 0, 0, seconds),
  );

  List resultParts = result.split(':');
  for (int i = 0; i < resultParts.length; i++) {
    if (resultParts[i] != "00") break;
    resultParts[i] = "";
  }
  resultParts.removeWhere((element) => element == "");

  if (minWidth4 && resultParts.length == 1) {
    resultParts = ["0", ...resultParts];
  }

  return resultParts.join(':');
}

 final RegExp urlRegex = RegExp(
    r'((https?:\/\/)?(www\.)?([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})(:[0-9]{1,5})?(\/[^\s]*)?)',
    caseSensitive: false,
  );