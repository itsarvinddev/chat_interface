import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/chat_theme.dart';

/// A widget for displaying and managing threaded conversations
class ThreadView extends StatefulWidget {
  /// The thread to display
  final Thread thread;

  /// Current user ID for proper message alignment
  final String currentUserId;

  /// Called when user wants to send a message in the thread
  final void Function(String content, {String? replyToMessageId})?
  onSendMessage;

  /// Called when user wants to react to a message
  final void Function(String messageId, String emoji)? onReactToMessage;

  /// Called when user wants to edit a message
  final void Function(String messageId, String newContent)? onEditMessage;

  /// Called when user wants to delete a message
  final void Function(String messageId)? onDeleteMessage;

  /// Called when user wants to mark thread as read
  final void Function()? onMarkAsRead;

  /// Called when user wants to close the thread view
  final void Function()? onClose;

  /// Called when user wants to view thread settings
  final void Function()? onViewSettings;

  /// Called when user wants to add participants
  final void Function()? onAddParticipants;

  /// Whether to show the composer for new messages
  final bool showComposer;

  /// Theme configuration
  final ChatThemeData? theme;

  const ThreadView({
    super.key,
    required this.thread,
    required this.currentUserId,
    this.onSendMessage,
    this.onReactToMessage,
    this.onEditMessage,
    this.onDeleteMessage,
    this.onMarkAsRead,
    this.onClose,
    this.onViewSettings,
    this.onAddParticipants,
    this.showComposer = true,
    this.theme,
  });

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  String? _replyToMessageId;
  bool _isComposerExpanded = false;

  @override
  void initState() {
    super.initState();

    // Mark thread as read when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMarkAsRead?.call();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildThreadHeader(),
          Expanded(child: _buildMessagesList()),
          if (widget.showComposer) _buildComposer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.thread.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            '${widget.thread.activeParticipantCount} participant${widget.thread.activeParticipantCount != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onClose,
      ),
      actions: [
        // Thread priority indicator
        if (widget.thread.priority != ThreadPriority.normal)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildPriorityIndicator(),
          ),

        // Thread status indicator
        if (!widget.thread.isActive)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildStatusIndicator(),
          ),

        // Actions menu
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'participants',
              child: Row(
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text('Manage Participants'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Thread Settings'),
                ],
              ),
            ),
            if (widget.thread.isActive)
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive),
                    SizedBox(width: 8),
                    Text('Archive Thread'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    IconData icon;
    Color color;

    switch (widget.thread.priority) {
      case ThreadPriority.high:
        icon = Icons.keyboard_arrow_up;
        color = Colors.orange;
        break;
      case ThreadPriority.urgent:
        icon = Icons.keyboard_double_arrow_up;
        color = Colors.red;
        break;
      case ThreadPriority.low:
        icon = Icons.keyboard_arrow_down;
        color = Colors.grey;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildStatusIndicator() {
    IconData icon;
    Color color;

    switch (widget.thread.status) {
      case ThreadStatus.archived:
        icon = Icons.archive;
        color = Colors.grey;
        break;
      case ThreadStatus.closed:
        icon = Icons.lock;
        color = Colors.red;
        break;
      case ThreadStatus.deleted:
        icon = Icons.delete;
        color = Colors.red;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, color: color, size: 18);
  }

  Widget _buildThreadHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread description
          if (widget.thread.description?.isNotEmpty == true) ...[
            Text(
              widget.thread.description!,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
          ],

          // Thread metadata
          Row(
            children: [
              Icon(Icons.forum, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 4),
              Text(
                'Thread \u2022 ${widget.thread.messageCount} message${widget.thread.messageCount != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatThreadAge(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          // Typing indicators
          if (widget.thread.typingParticipants.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildTypingIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final typingUsers = widget.thread.typingParticipants;
    if (typingUsers.isEmpty) return const SizedBox.shrink();

    String typingText;
    if (typingUsers.length == 1) {
      typingText = '${typingUsers.first.displayName} is typing...';
    } else if (typingUsers.length == 2) {
      typingText =
          '${typingUsers.first.displayName} and ${typingUsers.last.displayName} are typing...';
    } else {
      typingText = '${typingUsers.length} people are typing...';
    }

    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(
          typingText,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (widget.thread.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.thread.messages.length,
      itemBuilder: (context, index) {
        final message = widget.thread.messages[index];
        final isFromCurrentUser = message.senderId == widget.currentUserId;
        final showSenderInfo = _shouldShowSenderInfo(index);

        return _buildMessageBubble(message, isFromCurrentUser, showSenderInfo);
      },
    );
  }

  bool _shouldShowSenderInfo(int index) {
    if (index == 0) return true;

    final currentMessage = widget.thread.messages[index];
    final previousMessage = widget.thread.messages[index - 1];

    // Show sender info if different sender or significant time gap
    return currentMessage.senderId != previousMessage.senderId ||
        currentMessage.timestamp
                .difference(previousMessage.timestamp)
                .inMinutes >
            5;
  }

  Widget _buildMessageBubble(
    ThreadMessage message,
    bool isFromCurrentUser,
    bool showSenderInfo,
  ) {
    final participant = widget.thread.participants
        .where((p) => p.id == message.senderId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: isFromCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender info
          if (showSenderInfo && !isFromCurrentUser) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: participant?.avatar?.isNotEmpty == true
                      ? ClipOval(
                          child: Image.network(
                            participant!.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitialsAvatar(participant.displayName),
                          ),
                        )
                      : _buildInitialsAvatar(participant?.displayName ?? 'U'),
                ),
                const SizedBox(width: 8),
                Text(
                  participant?.displayName ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // Message bubble
          GestureDetector(
            onLongPress: () => _showMessageActions(message),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? Colors.blue[500] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply indicator
                  if (message.replyToMessageId != null)
                    _buildReplyIndicator(message.replyToMessageId!),

                  // Message content
                  _buildMessageContent(message, isFromCurrentUser),

                  // Message status indicators
                  if (isFromCurrentUser) ...[
                    const SizedBox(height: 4),
                    _buildMessageStatus(message),
                  ],
                ],
              ),
            ),
          ),

          // Reactions
          if (message.hasReactions) ...[
            const SizedBox(height: 4),
            _buildReactions(message),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String displayName) {
    final initials = displayName.isNotEmpty
        ? displayName
              .split(' ')
              .map((n) => n.isNotEmpty ? n[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildReplyIndicator(String replyToMessageId) {
    final replyToMessage = widget.thread.messages
        .where((m) => m.id == replyToMessageId)
        .firstOrNull;

    if (replyToMessage == null) return const SizedBox.shrink();

    final replyToParticipant = widget.thread.participants
        .where((p) => p.id == replyToMessage.senderId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue[400]!, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyToParticipant?.displayName ?? 'Unknown User',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            replyToMessage.content.length > 50
                ? '${replyToMessage.content.substring(0, 50)}...'
                : replyToMessage.content,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThreadMessage message, bool isFromCurrentUser) {
    Color textColor = isFromCurrentUser ? Colors.white : Colors.black87;

    switch (message.type) {
      case ThreadMessageType.text:
        return Text(
          message.content,
          style: TextStyle(fontSize: 14, color: textColor),
        );
      case ThreadMessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: textColor.withOpacity(0.8),
          ),
        );
      case ThreadMessageType.image:
      case ThreadMessageType.file:
      case ThreadMessageType.link:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAttachmentIcon(message.type),
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    message.content,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ),
              ],
            ),
            if (message.attachmentData != null) const SizedBox(height: 4),
            // Additional attachment rendering would go here
          ],
        );
    }
  }

  IconData _getAttachmentIcon(ThreadMessageType type) {
    switch (type) {
      case ThreadMessageType.image:
        return Icons.image;
      case ThreadMessageType.file:
        return Icons.attach_file;
      case ThreadMessageType.link:
        return Icons.link;
      default:
        return Icons.message;
    }
  }

  Widget _buildMessageStatus(ThreadMessage message) {
    final seenCount = message.seenBy.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited) ...[
          Icon(Icons.edit, size: 10, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 4),
        ],
        Text(
          _formatMessageTime(message.timestamp),
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7)),
        ),
        if (seenCount > 0) ...[
          const SizedBox(width: 4),
          Icon(
            seenCount == 1 ? Icons.check : Icons.done_all,
            size: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ],
    );
  }

  Widget _buildReactions(ThreadMessage message) {
    final groupedReactions = message.groupedReactions;

    return Wrap(
      spacing: 4,
      children: groupedReactions.entries.map((entry) {
        final emoji = entry.key;
        final reactions = entry.value;
        final hasCurrentUserReacted = reactions.any(
          (r) => r.participantId == widget.currentUserId,
        );

        return GestureDetector(
          onTap: () => widget.onReactToMessage?.call(message.id, emoji),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: hasCurrentUserReacted
                  ? Colors.blue[100]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: hasCurrentUserReacted
                  ? Border.all(color: Colors.blue[300]!)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 2),
                Text(
                  '${reactions.length}',
                  style: TextStyle(
                    fontSize: 10,
                    color: hasCurrentUserReacted
                        ? Colors.blue[700]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Reply indicator
          if (_replyToMessageId != null) _buildComposerReplyIndicator(),

          // Message input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Reply to thread...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  onChanged: (text) {
                    setState(() {
                      _isComposerExpanded = text.isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _messageController.text.trim().isNotEmpty
                    ? _sendMessage
                    : null,
                icon: Icon(
                  Icons.send,
                  color: _messageController.text.trim().isNotEmpty
                      ? Colors.blue[600]
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposerReplyIndicator() {
    final replyToMessage = widget.thread.messages
        .where((m) => m.id == _replyToMessageId)
        .firstOrNull;

    if (replyToMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue[400]!, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to: ${replyToMessage.content.length > 30 ? '${replyToMessage.content.substring(0, 30)}...' : replyToMessage.content}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _replyToMessageId = null),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to reply in this thread',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatThreadAge() {
    final now = DateTime.now();
    final difference = now.difference(widget.thread.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    widget.onSendMessage?.call(content, replyToMessageId: _replyToMessageId);

    _messageController.clear();
    setState(() {
      _replyToMessageId = null;
      _isComposerExpanded = false;
    });

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showMessageActions(ThreadMessage message) {
    final isFromCurrentUser = message.senderId == widget.currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyToMessageId = message.id);
                _messageFocusNode.requestFocus();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_reaction),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(context);
                _showReactionPicker(message.id);
              },
            ),
            if (isFromCurrentUser && widget.thread.settings.editingEnabled)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(message);
                },
              ),
            if (isFromCurrentUser && widget.thread.settings.deletingEnabled)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(message.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(String messageId) {
    final commonEmojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'React with',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: commonEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onReactToMessage?.call(messageId, emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ThreadMessage message) {
    final editController = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Enter new message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty && newContent != message.content) {
                widget.onEditMessage?.call(message.id, newContent);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteMessage?.call(messageId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'participants':
        widget.onAddParticipants?.call();
        break;
      case 'settings':
        widget.onViewSettings?.call();
        break;
      case 'archive':
        // Handle archive action
        break;
    }
  }
}
