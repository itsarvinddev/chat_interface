import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/chat_theme.dart';

/// A widget that displays thread attachment in a chat message
class ThreadMessageTile extends StatelessWidget {
  /// The thread attachment to display
  final ThreadAttachment threadAttachment;

  /// Whether this message is from the current user
  final bool isFromCurrentUser;

  /// Current user ID for permissions
  final String currentUserId;

  /// Called when user wants to view the thread
  final void Function(Thread thread)? onViewThread;

  /// Called when user wants to join the thread
  final void Function(Thread thread)? onJoinThread;

  /// Called when user wants to reply to the thread
  final void Function(Thread thread)? onReplyToThread;

  /// Theme configuration
  final ChatThemeData? theme;

  const ThreadMessageTile({
    super.key,
    required this.threadAttachment,
    this.isFromCurrentUser = false,
    required this.currentUserId,
    this.onViewThread,
    this.onJoinThread,
    this.onReplyToThread,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? ChatThemeData.fromTheme(Theme.of(context));

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFromCurrentUser
            ? themeData.outgoingBubbleColor
            : themeData.incomingBubbleColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThreadHeader(),
          const SizedBox(height: 12),
          _buildThreadInfo(),
          const SizedBox(height: 12),
          _buildThreadPreview(),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (threadAttachment.priority) {
      case ThreadPriority.urgent:
        return Colors.red[400]!;
      case ThreadPriority.high:
        return Colors.orange[400]!;
      case ThreadPriority.low:
        return Colors.grey[400]!;
      default:
        return Colors.blue[400]!;
    }
  }

  Widget _buildThreadHeader() {
    return Row(
      children: [
        // Thread icon with priority indicator
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getBorderColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.forum, size: 16, color: _getBorderColor()),
        ),

        const SizedBox(width: 8),

        // Thread indicator and title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Thread',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getBorderColor(),
                    ),
                  ),
                  if (threadAttachment.priority != ThreadPriority.normal) ...[
                    const SizedBox(width: 4),
                    _buildPriorityIndicator(),
                  ],
                ],
              ),
              Text(
                threadAttachment.thread.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Status indicator
        if (!threadAttachment.isActive) _buildStatusIndicator(),
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    IconData icon;
    Color color;

    switch (threadAttachment.priority) {
      case ThreadPriority.urgent:
        icon = Icons.keyboard_double_arrow_up;
        color = Colors.red[600]!;
        break;
      case ThreadPriority.high:
        icon = Icons.keyboard_arrow_up;
        color = Colors.orange[600]!;
        break;
      case ThreadPriority.low:
        icon = Icons.keyboard_arrow_down;
        color = Colors.grey[600]!;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, size: 12, color: color);
  }

  Widget _buildStatusIndicator() {
    final thread = threadAttachment.thread;
    IconData icon;
    Color color;
    String tooltip;

    switch (thread.status) {
      case ThreadStatus.archived:
        icon = Icons.archive;
        color = Colors.grey;
        tooltip = 'Archived';
        break;
      case ThreadStatus.closed:
        icon = Icons.lock;
        color = Colors.red;
        tooltip = 'Closed';
        break;
      case ThreadStatus.deleted:
        icon = Icons.delete;
        color = Colors.red;
        tooltip = 'Deleted';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildThreadInfo() {
    final thread = threadAttachment.thread;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thread stats
        Row(
          children: [
            Icon(Icons.message, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${thread.messageCount} message${thread.messageCount != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Icon(Icons.people, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${thread.activeParticipantCount} participant${thread.activeParticipantCount != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),

        // Last activity
        const SizedBox(height: 4),
        Text(
          'Last activity ${_formatLastActivity()}',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),

        // Thread description (if available)
        if (thread.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            thread.description!,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildThreadPreview() {
    final thread = threadAttachment.thread;
    final previewText = threadAttachment.previewText;

    if (previewText?.isNotEmpty == true) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          previewText!,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey[700],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Show latest message preview if no custom preview
    final latestMessage = thread.latestMessage;
    if (latestMessage != null) {
      final participant = thread.participants
          .where((p) => p.id == latestMessage.senderId)
          .firstOrNull;

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Sender avatar
            CircleAvatar(
              radius: 8,
              backgroundColor: Colors.grey[400],
              child: Text(
                participant?.displayName.isNotEmpty == true
                    ? participant!.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 8, color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),

            // Message content
            Expanded(
              child: Text(
                '${participant?.displayName ?? 'Someone'}: ${latestMessage.content}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context) {
    final thread = threadAttachment.thread;
    final isParticipant = _isCurrentUserParticipant();

    return Row(
      children: [
        // View thread button
        Expanded(
          child: _buildActionButton(
            icon: Icons.visibility,
            label: 'View',
            onPressed: () => onViewThread?.call(thread),
            isPrimary: true,
          ),
        ),

        const SizedBox(width: 8),

        // Join/Reply button
        if (thread.isActive) ...[
          Expanded(
            child: _buildActionButton(
              icon: isParticipant ? Icons.reply : Icons.add,
              label: isParticipant ? 'Reply' : 'Join',
              onPressed: () {
                if (isParticipant) {
                  onReplyToThread?.call(thread);
                } else {
                  onJoinThread?.call(thread);
                }
              },
            ),
          ),
        ] else ...[
          Expanded(
            child: _buildActionButton(
              icon: Icons.lock,
              label: _getInactiveLabel(),
              onPressed: null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 14,
        color: onPressed != null
            ? (isPrimary ? Colors.blue[700] : Colors.grey[600])
            : Colors.grey[400],
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: onPressed != null
              ? (isPrimary ? Colors.blue[700] : Colors.grey[600])
              : Colors.grey[400],
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 28),
        side: BorderSide(
          color: onPressed != null
              ? (isPrimary
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3))
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  bool _isCurrentUserParticipant() {
    return threadAttachment.thread.participants.any(
      (p) => p.id == currentUserId && p.isActive,
    );
  }

  String _getInactiveLabel() {
    switch (threadAttachment.thread.status) {
      case ThreadStatus.archived:
        return 'Archived';
      case ThreadStatus.closed:
        return 'Closed';
      case ThreadStatus.deleted:
        return 'Deleted';
      default:
        return 'Inactive';
    }
  }

  String _formatLastActivity() {
    final now = DateTime.now();
    final lastActivity = threadAttachment.thread.lastActivityAt;
    final difference = now.difference(lastActivity);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

/// A widget that shows thread navigation indicators on regular message bubbles
class ThreadNavigationIndicator extends StatelessWidget {
  /// The message that may have associated threads
  final Message message;

  /// List of threads associated with this message
  final List<Thread> associatedThreads;

  /// Whether this message is from the current user
  final bool isFromCurrentUser;

  /// Called when user wants to view a thread
  final void Function(Thread thread)? onViewThread;

  /// Called when user wants to create a new thread from this message
  final void Function(Message message)? onCreateThread;

  /// Theme configuration
  final ChatThemeData? theme;

  const ThreadNavigationIndicator({
    super.key,
    required this.message,
    this.associatedThreads = const [],
    this.isFromCurrentUser = false,
    this.onViewThread,
    this.onCreateThread,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (associatedThreads.isEmpty && onCreateThread == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Existing threads
          if (associatedThreads.isNotEmpty) ...[
            for (final thread in associatedThreads.take(2))
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: _buildThreadChip(thread),
              ),

            // Show more indicator
            if (associatedThreads.length > 2)
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: _buildMoreThreadsChip(),
              ),
          ],

          // Create thread button
          if (onCreateThread != null) _buildCreateThreadButton(),
        ],
      ),
    );
  }

  Widget _buildThreadChip(Thread thread) {
    final color = _getThreadColor(thread);

    return GestureDetector(
      onTap: () => onViewThread?.call(thread),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum, size: 10, color: color),
            const SizedBox(width: 2),
            Text(
              '${thread.messageCount}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (thread.priority != ThreadPriority.normal) ...[
              const SizedBox(width: 2),
              Icon(_getPriorityIcon(thread.priority), size: 8, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreThreadsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        '+${associatedThreads.length - 2}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCreateThreadButton() {
    return GestureDetector(
      onTap: () => onCreateThread?.call(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_comment, size: 10, color: Colors.blue[600]),
            const SizedBox(width: 2),
            Text(
              'Thread',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
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

  IconData _getPriorityIcon(ThreadPriority priority) {
    switch (priority) {
      case ThreadPriority.urgent:
        return Icons.keyboard_double_arrow_up;
      case ThreadPriority.high:
        return Icons.keyboard_arrow_up;
      case ThreadPriority.low:
        return Icons.keyboard_arrow_down;
      default:
        return Icons.remove;
    }
  }
}

/// A widget that shows unread thread indicators
class UnreadThreadIndicator extends StatelessWidget {
  /// List of threads with unread messages
  final List<Thread> unreadThreads;

  /// Current user ID
  final String currentUserId;

  /// Called when user wants to view an unread thread
  final void Function(Thread thread)? onViewThread;

  /// Theme configuration
  final ChatThemeData? theme;

  const UnreadThreadIndicator({
    super.key,
    required this.unreadThreads,
    required this.currentUserId,
    this.onViewThread,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (unreadThreads.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Text(
                '${unreadThreads.length} unread thread${unreadThreads.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: unreadThreads.take(3).map((thread) {
              final unreadCount = thread.getUnreadMessageCount(currentUserId);
              return GestureDetector(
                onTap: () => onViewThread?.call(thread),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        thread.title.length > 15
                            ? '${thread.title.substring(0, 15)}...'
                            : thread.title,
                        style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (unreadThreads.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              '+${unreadThreads.length - 3} more',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
