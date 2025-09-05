import 'package:chatui/chatui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef CustomMessageBuilder = Widget Function(
    ChatController controller, ChatMessage message, int index);

class ChatUiConfig {
  final CustomMessageBuilder? customMessage;
  final Widget? leading;
  final List<Widget>? actions;
  final ChatTheme? theme;
  final ScaffoldConfig? scaffold;

  const ChatUiConfig({
    this.customMessage,
    this.leading,
    this.actions,
    this.theme,
    this.scaffold,
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
    final provider =
        context.dependOnInheritedWidgetOfExactType<ChatUiConfigProvider>();
    assert(provider != null, 'No ChatUiConfigProvider found in context');
    return provider!.config;
  }

  static ChatUiConfig? maybeOf(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<ChatUiConfigProvider>();
    return provider?.config;
  }

  @override
  bool updateShouldNotify(ChatUiConfigProvider oldWidget) {
    return config != oldWidget.config;
  }
}

class ScaffoldConfig {
  final Widget? background;
  final Widget? gradient;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;
  final Widget? drawer;
  final bool drawerBarrierDismissible;
  final DragStartBehavior drawerDragStartBehavior;
  final double drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final Color? drawerScrimColor;
  final Widget? endDrawer;
  final bool endDrawerDragGesture;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final void Function(bool)? onDrawerChanged;
  final void Function(bool)? onEndDrawerChanged;
  final List<Widget>? persistentFooterButtons;
  final bool primary;
  final String? restorationId;
  final AlignmentDirectional persistentFooterAlignment;
  final BoxDecoration? persistentFooterDecoration;

  const ScaffoldConfig({
    this.background,
    this.gradient,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    this.drawer,
    this.drawerBarrierDismissible = false,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.drawerEdgeDragWidth = 0,
    this.drawerEnableOpenDragGesture = false,
    this.drawerScrimColor,
    this.endDrawer,
    this.endDrawerDragGesture = false,
    this.floatingActionButtonAnimator,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.persistentFooterButtons,
    this.primary = true,
    this.restorationId,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.persistentFooterDecoration,
  });
}
