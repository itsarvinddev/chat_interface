import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';

/// An InheritedWidget that provides a ChatController to its descendant widgets
class ChatControllerProvider extends InheritedWidget {
  const ChatControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  final ChatController controller;

  /// Get the nearest ChatController from the widget tree
  static ChatController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ChatControllerProvider>();
    assert(provider != null, 'No ChatControllerProvider found in context');
    return provider!.controller;
  }

  /// Get the nearest ChatController from the widget tree without creating a dependency
  static ChatController? maybeOf(BuildContext context) {
    final ChatControllerProvider? provider =
        context.getInheritedWidgetOfExactType<ChatControllerProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(ChatControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
