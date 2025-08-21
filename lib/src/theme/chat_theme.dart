import 'package:flutter/material.dart';

import '../utils/markdown_parser.dart';

class ChatThemeData {
  final Color incomingBubbleColor;
  final Color outgoingBubbleColor;
  final TextStyle messageTextStyle;
  final double bubbleRadius;
  final MarkdownTextStyles markdownStyles;

  ChatThemeData({
    required this.incomingBubbleColor,
    required this.outgoingBubbleColor,
    required this.messageTextStyle,
    this.bubbleRadius = 16,
    MarkdownTextStyles? markdownStyles,
  }) : markdownStyles = markdownStyles ?? MarkdownTextStyles();

  factory ChatThemeData.fromTheme(ThemeData theme) {
    return ChatThemeData(
      incomingBubbleColor: theme.colorScheme.surfaceContainerHighest,
      outgoingBubbleColor: theme.colorScheme.primaryContainer,
      messageTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      markdownStyles: MarkdownTextStyles(
        boldStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        italicStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface,
        ),
        strikethroughStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        inlineCodeStyle: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainer,
          color: theme.colorScheme.onSurface,
          letterSpacing: 0.8,
        ),
        codeBlockStyle: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainer,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class ChatTheme extends InheritedWidget {
  final ChatThemeData data;

  const ChatTheme({super.key, required this.data, required super.child});

  static ChatThemeData of(BuildContext context) {
    final ChatTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<ChatTheme>();
    if (inherited != null) return inherited.data;
    return ChatThemeData.fromTheme(Theme.of(context));
  }

  @override
  bool updateShouldNotify(ChatTheme oldWidget) => data != oldWidget.data;
}
