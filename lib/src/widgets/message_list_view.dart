import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../theme/chat_theme.dart';
import '../utils/time_utils.dart';
import 'message_bubble.dart';
import 'message_context_menu.dart';
import 'typing_indicator.dart';

class MessageListView extends StatefulWidget {
  final ChatController controller;
  final ScrollController? scrollController;
  final bool enableAnimations;

  const MessageListView({
    super.key,
    required this.controller,
    this.scrollController,
    this.enableAnimations = true,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  List<Message> _previousMessages = [];

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    return ValueListenableBuilder<List<Message>>(
      valueListenable: widget.controller.messages,
      builder: (BuildContext context, List<Message> messages, Widget? child) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: theme.timestampColor,
                ),
                SizedBox(height: ChatDesignTokens.spaceLg),
                Text('No messages yet', style: theme.systemTextStyle),
                SizedBox(height: ChatDesignTokens.spaceXs),
                Text('Start a conversation!', style: theme.timestampTextStyle),
              ],
            ),
          );
        }

        // Update animation state
        _updateMessageAnimations(messages);

        return CustomScrollView(
          reverse: true,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Typing indicator
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: widget.controller.typing,
                builder: (context, typingState, child) {
                  return AnimatedSwitcher(
                    duration: ChatDesignTokens.fastAnimation,
                    child: TypingIndicator(typingState: typingState),
                  );
                },
              ),
            ),
            // Messages list
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final reversedIndex = messages.length - 1 - index;
                final Message message = messages[reversedIndex];
                final bool isMe =
                    message.author.id.value ==
                    widget.controller.currentUser.id.value;
                final bool showDateHeader = _shouldShowDateHeader(
                  messages,
                  reversedIndex,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (showDateHeader)
                      _DateHeader(date: message.createdAt, theme: theme),
                    GestureDetector(
                      onLongPress: () => _handleLongPress(message),
                      child: MessageBubble(
                        key: ValueKey(message.id.value),
                        message: message,
                        isMe: isMe,
                        controller: widget.controller,
                        enableAnimations: widget.enableAnimations,
                        animationIndex: index,
                      ),
                    ),
                  ],
                );
              }, childCount: messages.length),
            ),
          ],
        );
      },
    );
  }

  void _updateMessageAnimations(List<Message> messages) {
    // Track new messages for animation purposes
    if (_previousMessages.length < messages.length) {
      // New messages added - could trigger staggered animations
      _previousMessages = List.from(messages);
    }
  }

  Future<void> _handleLongPress(Message message) async {
    await MessageContextMenu.show(
      context,
      message: message,
      controller: widget.controller,
    );
  }

  bool _shouldShowDateHeader(List<Message> messages, int index) {
    if (index == messages.length - 1) {
      return true; // last item (top of list when reversed)
    }
    final DateTime a = messages[index].createdAt;
    final DateTime b = messages[index + 1].createdAt;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final ChatThemeData theme;

  const _DateHeader({required this.date, required this.theme});

  @override
  Widget build(BuildContext context) {
    final String label = _formatDate(date);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ChatDesignTokens.spaceMd,
        horizontal: ChatDesignTokens.spaceLg,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ChatDesignTokens.spaceMd,
            vertical: ChatDesignTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
            border: Border.all(
              color: theme.borderColor.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow: theme.enableBubbleShadows && theme.bubbleShadow != null
                ? [
                    theme.bubbleShadow!.copyWith(
                      color: theme.bubbleShadow!.color.withOpacity(0.1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: theme.timestampTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return TimeUtils.formatDateHeader(d);
  }
}
