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

extension StringToDarkColor on String {
  // Stable 32-bit FNV-1a hash for deterministic mapping across runs.
  int _stableHash() {
    int hash = 0x811C9DC5; // 2166136261
    for (var i = 0; i < length; i++) {
      hash ^= codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF; // 16777619
    }
    return hash & 0x7FFFFFFF; // keep positive
  }

  /// Deterministic dark color via HSL with clamped lightness.
  /// Keeps colors dark by choosing lightness in [minLightness, maxLightness].
  Color toDarkColor({
    double minLightness = 0.18,
    double maxLightness = 0.32,
    double minSaturation = 0.55,
    double maxSaturation = 0.85,
  }) {
    final hash = _stableHash();
    final hue = (hash % 360).toDouble();
    final satSeed = ((hash >> 8) & 0xFF) / 255.0;
    final lightSeed = ((hash >> 16) & 0xFF) / 255.0;

    final s = (minSaturation + satSeed * (maxSaturation - minSaturation)).clamp(
      0.0,
      1.0,
    );
    final l = (minLightness + lightSeed * (maxLightness - minLightness)).clamp(
      0.0,
      1.0,
    );

    return HSLColor.fromAHSL(1.0, hue, s, l).toColor();
  }

  /// Dark picks from Material swatches (700/800/900 shades).
  Color toDarkSwatchColor() {
    final swatches = <MaterialColor>[
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
      Colors.blueGrey,
      Colors.grey,
    ];
    final shades = <int>[700, 800, 900];
    final hash = _stableHash();
    final swatch = swatches[hash % swatches.length];
    final shade = shades[(hash >> 8) % shades.length];
    return swatch[shade]!;
  }

  /// High-contrast foreground for the generated dark color (black/white).
  Color get contrastingOnDark {
    final bg = toDarkColor();
    final lum = bg.computeLuminance(); // 0=darkest, 1=lightest
    return lum > 0.2 ? Colors.black : Colors.white;
  }
}
