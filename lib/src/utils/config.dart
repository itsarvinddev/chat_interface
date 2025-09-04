import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';

typedef CustomMessageBuilder =
    Widget Function(ChatController controller, ChatMessage message, int index);

class ChatUiConfig {
  final CustomMessageBuilder? customMessageBuilder;
  final Widget? leading;
  final List<Widget>? actions;
  final ChatTheme? theme;
  final Decoration? backgroundDecoration;

  const ChatUiConfig({
    this.customMessageBuilder,
    this.leading,
    this.actions,
    this.theme,
    this.backgroundDecoration,
  });
}

class ChatUiConfigProvider extends InheritedWidget {
  const ChatUiConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });

  final ChatUiConfig config;

  static ChatUiConfig of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ChatUiConfigProvider>();
    assert(provider != null, 'No ChatUiConfigProvider found in context');
    return provider!.config;
  }

  static ChatUiConfig? maybeOf(BuildContext context) {
    final provider = context
        .getInheritedWidgetOfExactType<ChatUiConfigProvider>();
    return provider?.config;
  }

  @override
  bool updateShouldNotify(ChatUiConfigProvider oldWidget) {
    return config != oldWidget.config;
  }
}
