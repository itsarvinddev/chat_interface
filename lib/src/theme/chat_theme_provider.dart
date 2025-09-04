import 'package:flutter/material.dart';

import 'chat_theme.dart';

/// An InheritedWidget that provides a ChatTheme to its descendant widgets
class ChatThemeProvider extends InheritedWidget {
  const ChatThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  final ChatTheme theme;

  /// Get the nearest ChatTheme from the widget tree
  static ChatTheme of(BuildContext context) {
    final ChatThemeProvider? provider = context
        .dependOnInheritedWidgetOfExactType<ChatThemeProvider>();

    if (provider != null) {
      return provider.theme;
    }

    // Fallback to auto-generated theme from Material theme
    return ChatTheme.fromMaterialTheme(Theme.of(context));
  }

  /// Get the nearest ChatTheme from the widget tree without creating a dependency
  static ChatTheme? maybeOf(BuildContext context) {
    final ChatThemeProvider? provider = context
        .getInheritedWidgetOfExactType<ChatThemeProvider>();
    return provider?.theme;
  }

  @override
  bool updateShouldNotify(ChatThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
