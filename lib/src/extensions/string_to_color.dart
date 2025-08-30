import 'package:flutter/material.dart';

extension StringToColor on String {
  /// Basic string to color conversion
  Color toColorX() {
    int hash = hashCode.abs();
    int r = (hash & 0xFF0000) >> 16;
    int g = (hash & 0x00FF00) >> 8;
    int b = hash & 0x0000FF;
    return Color.fromRGBO(r, g, b, 1.0);
  }

  /// Advanced conversion with HSL control
  Color toColorHSL({double saturation = 0.7, double lightness = 0.6}) {
    int hash = _generateHash();
    double hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  /// Material Design inspired colors
  Color toMaterialColor() {
    int hash = _generateHash();
    List<Color> materialColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return materialColors[hash % materialColors.length];
  }

  /// Get contrasting text color (black or white)
  Color getContrastingTextColor() {
    Color bgColor = toColorX();
    double luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Internal hash function for better distribution
  int _generateHash() {
    int hash = 0;
    for (int i = 0; i < length; i++) {
      hash = ((hash << 5) - hash + codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.abs();
  }
}

/// HSL Color helper for better color manipulation
class HSLColor {
  final double hue;
  final double saturation;
  final double lightness;
  final double alpha;

  const HSLColor.fromAHSL(
    this.alpha,
    this.hue,
    this.saturation,
    this.lightness,
  );

  Color toColor() {
    double c = (1 - (2 * lightness - 1).abs()) * saturation;
    double x = c * (1 - ((hue / 60) % 2 - 1).abs());
    double m = lightness - c / 2;

    double r, g, b;

    if (hue >= 0 && hue < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (hue >= 60 && hue < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (hue >= 120 && hue < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (hue >= 180 && hue < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (hue >= 240 && hue < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    return Color.fromARGB(
      (alpha * 255).round(),
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
    );
  }
}
