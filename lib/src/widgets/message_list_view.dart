import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../utils/time_utils.dart';
import 'message_bubble.dart';
import 'message_context_menu.dart';
import 'typing_indicator.dart';

class MessageListView extends StatelessWidget {
  final ChatController controller;
  final ScrollController? scrollController;
  const MessageListView({
    super.key,
    required this.controller,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Message>>(
      valueListenable: controller.messages,
      builder: (BuildContext context, List<Message> messages, Widget? child) {
        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }
        return ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: messages.length + 1, // +1 for typing indicator
          itemBuilder: (BuildContext context, int index) {
            if (index == messages.length) {
              // Show typing indicator at the end
              return ValueListenableBuilder(
                valueListenable: controller.typing,
                builder: (context, typingState, child) {
                  return TypingIndicator(typingState: typingState);
                },
              );
            }
            final Message message = messages[index];
            final bool isMe =
                message.author.id.value == controller.currentUser.id.value;
            final bool showDateHeader = _shouldShowDateHeader(messages, index);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (showDateHeader) _DateHeader(date: message.createdAt),
                GestureDetector(
                  onLongPress: () async {
                    await MessageContextMenu.show(
                      context,
                      message: message,
                      controller: controller,
                    );
                  },
                  child: MessageBubble(
                    message: message,
                    isMe: isMe,
                    controller: controller,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _shouldShowDateHeader(List<Message> messages, int index) {
    if (index == messages.length - 1)
      return true; // last item (top of list when reversed)
    final DateTime a = messages[index].createdAt;
    final DateTime b = messages[index + 1].createdAt;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final String label = _formatDate(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return TimeUtils.formatDateHeader(d);
  }
}
