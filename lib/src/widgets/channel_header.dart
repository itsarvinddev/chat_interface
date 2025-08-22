import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import 'thread_list_view.dart';
import 'typing_indicator.dart';

class ChannelHeader extends StatelessWidget implements PreferredSizeWidget {
  final ChatController controller;
  const ChannelHeader({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased height to prevent overflow

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            const _PresenceDot(),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller.channel,
                builder:
                    (BuildContext context, dynamic channel, Widget? child) {
                      final String title = channel?.name ?? 'Chat';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          ValueListenableBuilder(
                            valueListenable: controller.typing,
                            builder:
                                (
                                  BuildContext context,
                                  TypingState typing,
                                  Widget? child,
                                ) {
                                  return CompactTypingIndicator(
                                    typingState: typing,
                                  );
                                },
                          ),
                        ],
                      );
                    },
              ),
            ),
            // Threads button
            ValueListenableBuilder(
              valueListenable: controller.threads,
              builder: (context, threads, child) {
                final unreadCount = controller.getUnreadThreadCount();
                return Stack(
                  children: [
                    IconButton(
                      tooltip: 'Threads',
                      icon: const Icon(Icons.forum),
                      onPressed: () => _showThreadsList(context),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              tooltip: 'Info',
              icon: const Icon(Icons.info_outline),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showThreadsList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreadListView(
          threads: controller.threads.value,
          currentUserId: controller.currentUser.id.value,
          onViewThread: (thread) {
            Navigator.of(context).pop();
            controller.openThread(thread);
          },
          onCreateThread: () {
            Navigator.of(context).pop();
            // Thread creation is handled through message context menu
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Long press on a message to start a thread'),
              ),
            );
          },
          onArchiveThread: (thread) async {
            await controller.archiveThread(thread.id);
          },
          onDeleteThread: (thread) async {
            await controller.deleteThread(thread.id);
          },
          onTogglePin: (thread, isPinned) async {
            // This would need to be implemented in ThreadService
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pin/unpin coming soon!')),
            );
          },
        ),
      ),
    );
  }
}

class _PresenceDot extends StatelessWidget {
  const _PresenceDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );
  }
}
