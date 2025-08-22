import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import 'thread_view.dart';

/// A navigation widget that can overlay or slide in to show thread view
class ThreadNavigation extends StatelessWidget {
  final ChatController controller;
  final Widget child;

  const ThreadNavigation({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.showThreads,
      builder: (context, showThreads, _) {
        return Stack(
          children: [
            // Main chat view
            child,

            // Thread overlay
            if (showThreads)
              ValueListenableBuilder<Thread?>(
                valueListenable: controller.activeThread,
                builder: (context, activeThread, _) {
                  if (activeThread == null) return const SizedBox.shrink();

                  return Container(
                    color: Colors.white,
                    child: ThreadView(
                      thread: activeThread,
                      currentUserId: controller.currentUser.id.value,
                      onSendMessage:
                          (content, {replyToMessageId, attachmentData}) async {
                            await controller.sendThreadMessage(
                              threadId: activeThread.id,
                              content: content,
                              replyToMessageId: replyToMessageId,
                              attachmentData: attachmentData,
                            );
                          },
                      onReactToMessage: (messageId, emoji) async {
                        await controller.reactToThreadMessage(
                          threadId: activeThread.id,
                          messageId: messageId,
                          emoji: emoji,
                        );
                      },
                      onEditMessage: (messageId, newContent) async {
                        await controller.editThreadMessage(
                          threadId: activeThread.id,
                          messageId: messageId,
                          newContent: newContent,
                        );
                      },
                      onDeleteMessage: (messageId) async {
                        await controller.deleteThreadMessage(
                          threadId: activeThread.id,
                          messageId: messageId,
                        );
                      },
                      onMarkAsRead: () async {
                        final messageIds = activeThread.messages
                            .map((m) => m.id)
                            .toList();
                        await controller.markThreadMessagesAsSeen(
                          activeThread.id,
                          messageIds,
                        );
                      },
                      onClose: () {
                        controller.closeActiveThread();
                      },
                      onViewSettings: () {
                        // TODO: Implement thread settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thread settings coming soon!'),
                          ),
                        );
                      },
                      onAddParticipants: () {
                        // TODO: Show participant manager
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add participants coming soon!'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

/// A floating action button that shows thread-related quick actions
class ThreadFloatingActionButton extends StatelessWidget {
  final ChatController controller;

  const ThreadFloatingActionButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Thread>>(
      valueListenable: controller.threads,
      builder: (context, threads, _) {
        final unreadCount = controller.getUnreadThreadCount();

        if (threads.isEmpty) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            FloatingActionButton(
              onPressed: () => controller.toggleThreadsView(),
              child: const Icon(Icons.forum),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A compact thread indicator that can be shown in message bubbles
class ThreadIndicator extends StatelessWidget {
  final Message message;
  final ChatController controller;

  const ThreadIndicator({
    super.key,
    required this.message,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final associatedThreads = controller.getMessageThreads(message.id);

    if (associatedThreads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: associatedThreads.take(2).map((thread) {
          final unreadCount = thread.getUnreadMessageCount(
            controller.currentUser.id.value,
          );

          return GestureDetector(
            onTap: () => controller.openThread(thread),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getThreadColor(thread).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getThreadColor(thread).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forum, size: 10, color: _getThreadColor(thread)),
                  const SizedBox(width: 2),
                  Text(
                    '${thread.messageCount}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getThreadColor(thread),
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 2),
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getThreadColor(Thread thread) {
    switch (thread.priority) {
      case ThreadPriority.urgent:
        return Colors.red[600]!;
      case ThreadPriority.high:
        return Colors.orange[600]!;
      case ThreadPriority.low:
        return Colors.grey[600]!;
      default:
        return Colors.blue[600]!;
    }
  }
}
