import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import 'utils/chat_by_date.dart';
import 'widgets/bubble.dart';
import 'widgets/input_container.dart';

typedef CustomMessageBuilder =
    Widget Function(ChatController controller, ChatMessage message, int index);

class ChatUiConfig {
  final CustomMessageBuilder? customMessageBuilder;
  final Widget? leading;
  final List<Widget>? actions;

  const ChatUiConfig({this.customMessageBuilder, this.leading, this.actions});
}

class ChatUi extends StatefulWidget {
  final ChatController controller;
  final ChatUiConfig config;

  const ChatUi({
    super.key,
    required this.controller,
    this.config = const ChatUiConfig(),
  });

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  // Show/hide the "scroll to bottom" button.
  final ValueNotifier<bool> _showJumpToBottom = ValueNotifier<bool>(false);

  // How close to the bottom counts as "at bottom".
  static const double _bottomDelta = 24.0;

  ScrollController get _sc => widget.controller.scrollController;
  ScrollController? _boundSc;

  @override
  void initState() {
    super.initState();
    _bindScrollController(_sc);
  }

  @override
  void didUpdateWidget(covariant ChatUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the upstream ChatController/ScrollController instance changed,
    // rebind our listener.
    if (oldWidget.controller.scrollController !=
        widget.controller.scrollController) {
      _bindScrollController(_sc);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload path: ensure listener is bound to the current controller
    // and recompute visibility once the frame completes.
    _bindScrollController(_sc);
  }

  @override
  void dispose() {
    _boundSc?.removeListener(_updateJumpVisibility);
    _showJumpToBottom.dispose();
    super.dispose();
  }

  void _bindScrollController(ScrollController sc) {
    if (_boundSc == sc) {
      // Still schedule a post-frame recompute in case metrics got reset.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateJumpVisibility(),
      );
      return;
    }
    _boundSc?.removeListener(_updateJumpVisibility);
    _boundSc = sc;
    _boundSc!.addListener(_updateJumpVisibility);
    // Delay until metrics exist.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateJumpVisibility(),
    );
  }

  bool _isNearBottom() {
    final sc = _boundSc;
    if (sc == null || !sc.hasClients) return true; // default: hide button
    final pos = sc.position;
    return (pos.pixels - pos.minScrollExtent).abs() <= _bottomDelta;
  }

  void _updateJumpVisibility() {
    final show = !_isNearBottom();
    if (_showJumpToBottom.value != show) {
      _showJumpToBottom.value = show;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!InitializationChecker.isInitialized) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              ChatUINotInitializedException(
                'ChatUI not initialized when trying to build ChatUi, please call initializeChatUI() in your main.dart',
              ).toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://web.whatsapp.com/img/bg-chat-tile-dark_a4be512e7195b6b733d9110b408f075d.png",
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              context.theme.colorScheme.surfaceContainerHigh,
              BlendMode.srcATop,
            ),
          ),
        ),
        child: PagingListener(
          controller: widget.controller.pagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, ChatMessage>(
              state: state,
              fetchNextPage: fetchNextPage,
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollController: widget.controller.scrollController,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, item, index) {
                  // Use the same list the widget is rendering.
                  // Prefer the pagingController items; fall back to any local cache.
                  final items = widget.controller.messages;

                  // Viewport-aware header: with reverse: true, we must compare
                  // against index  1 (the previous item in display order).
                  final bool showDateHeader =
                      ChatDateUtils.shouldShowHeaderForViewportOrder(
                        items: items,
                        index: index,
                        // because your PagedListView has reverse: true
                        reverse: true,
                        createdAtOf: (m) => m.createdAt ?? DateTime.now(),
                      );
                  return ChatBubble(
                    controller: widget.controller,
                    message: item,
                    index: index,
                    showHeader: showDateHeader,
                    config: widget.config,
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ChatInputContainer(
        controller: widget.controller,
        config: widget.config,
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showJumpToBottom,
        builder: (context, show, _) {
          return IgnorePointer(
            ignoring: !show,
            child: AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: AnimatedScale(
                scale: show ? 1 : 0.9,
                duration: const Duration(milliseconds: 180),
                child: IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    elevation: 1.0,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    enableFeedback: true,
                    shadowColor: context.theme.colorScheme.surfaceContainerHigh,
                  ),
                  onPressed: widget.controller.scrollToLastMessage,
                  tooltip: 'Jump to bottom',
                  enableFeedback: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 26),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
