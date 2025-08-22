import 'dart:async';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/chat_theme.dart';

/// A specialized composer widget for replying within threads
class ThreadComposer extends StatefulWidget {
  /// The thread context for this composer
  final Thread thread;

  /// Current user ID
  final String currentUserId;

  /// Called when user sends a message
  final void Function(
    String content, {
    String? replyToMessageId,
    Map<String, dynamic>? attachmentData,
  })?
  onSendMessage;

  /// Called when user starts typing
  final void Function()? onStartTyping;

  /// Called when user stops typing
  final void Function()? onStopTyping;

  /// Called when user wants to attach a file
  final void Function()? onAttachFile;

  /// Called when user wants to attach an image
  final void Function()? onAttachImage;

  /// Message being replied to (if any)
  final ThreadMessage? replyToMessage;

  /// Whether file attachments are enabled
  final bool enableAttachments;

  /// Whether emoji picker is enabled
  final bool enableEmojiPicker;

  /// Placeholder text for the input field
  final String? hintText;

  /// Theme configuration
  final ChatThemeData? theme;

  const ThreadComposer({
    super.key,
    required this.thread,
    required this.currentUserId,
    this.onSendMessage,
    this.onStartTyping,
    this.onStopTyping,
    this.onAttachFile,
    this.onAttachImage,
    this.replyToMessage,
    this.enableAttachments = true,
    this.enableEmojiPicker = true,
    this.hintText,
    this.theme,
  });

  @override
  State<ThreadComposer> createState() => _ThreadComposerState();
}

class _ThreadComposerState extends State<ThreadComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _typingTimer;
  bool _isTyping = false;
  bool _isExpanded = false;
  bool _showEmojiPicker = false;
  Map<String, dynamic>? _attachmentData;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;

    if (hasText != _isExpanded) {
      setState(() => _isExpanded = hasText);
    }

    // Handle typing indicators
    if (hasText && !_isTyping) {
      _startTyping();
    } else if (!hasText && _isTyping) {
      _stopTyping();
    }

    // Reset typing timer
    _typingTimer?.cancel();
    if (hasText) {
      _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
    }
  }

  void _startTyping() {
    if (!_isTyping) {
      setState(() => _isTyping = true);
      widget.onStartTyping?.call();
    }
  }

  void _stopTyping() {
    if (_isTyping) {
      setState(() => _isTyping = false);
      widget.onStopTyping?.call();
    }
    _typingTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply indicator
          if (widget.replyToMessage != null) _buildReplyIndicator(),

          // Attachment preview
          if (_attachmentData != null) _buildAttachmentPreview(),

          // Main composer
          _buildMainComposer(),

          // Emoji picker
          if (_showEmojiPicker) _buildEmojiPicker(),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator() {
    final replyMessage = widget.replyToMessage!;
    final participant = widget.thread.participants
        .where((p) => p.id == replyMessage.senderId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue[400]!, width: 3)),
      ),
      child: Row(
        children: [
          Icon(Icons.reply, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${participant?.displayName ?? 'Unknown User'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyMessage.content.length > 50
                      ? '${replyMessage.content.substring(0, 50)}...'
                      : replyMessage.content,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(_getAttachmentIcon(), size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getAttachmentLabel(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _attachmentData = null),
          ),
        ],
      ),
    );
  }

  IconData _getAttachmentIcon() {
    final type = _attachmentData?['type'] as String?;
    switch (type) {
      case 'image':
        return Icons.image;
      case 'file':
        return Icons.attach_file;
      default:
        return Icons.attachment;
    }
  }

  String _getAttachmentLabel() {
    final type = _attachmentData?['type'] as String?;
    final name = _attachmentData?['name'] as String?;

    if (name?.isNotEmpty == true) {
      return name!;
    }

    switch (type) {
      case 'image':
        return 'Image attachment';
      case 'file':
        return 'File attachment';
      default:
        return 'Attachment';
    }
  }

  Widget _buildMainComposer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          if (widget.enableAttachments &&
              widget.thread.settings.attachmentsEnabled)
            _buildAttachmentButton(),

          // Text input
          Expanded(child: _buildTextInput()),

          const SizedBox(width: 8),

          // Action buttons
          if (_isExpanded) ...[
            // Emoji button
            if (widget.enableEmojiPicker)
              IconButton(
                icon: Icon(
                  _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                  color: Colors.grey[600],
                ),
                onPressed: _toggleEmojiPicker,
              ),

            // Send button
            _buildSendButton(),
          ] else ...[
            // Collapsed state buttons
            if (widget.enableEmojiPicker)
              IconButton(
                icon: Icon(Icons.emoji_emotions, color: Colors.grey[600]),
                onPressed: _toggleEmojiPicker,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.add, color: Colors.grey[600]),
        onSelected: _handleAttachmentAction,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'image',
            child: Row(
              children: [Icon(Icons.image), SizedBox(width: 8), Text('Photo')],
            ),
          ),
          const PopupMenuItem(
            value: 'file',
            child: Row(
              children: [
                Icon(Icons.attach_file),
                SizedBox(width: 8),
                Text('File'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText ?? _getDefaultHintText(),
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        maxLines: 4,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _sendMessage(),
      ),
    );
  }

  String _getDefaultHintText() {
    if (widget.replyToMessage != null) {
      return 'Reply to thread...';
    }
    return 'Add to this thread...';
  }

  Widget _buildSendButton() {
    final canSend =
        _textController.text.trim().isNotEmpty || _attachmentData != null;

    return Container(
      decoration: BoxDecoration(
        color: canSend ? Colors.blue[600] : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(
          Icons.send,
          color: canSend ? Colors.white : Colors.grey[500],
          size: 20,
        ),
        onPressed: canSend ? _sendMessage : null,
      ),
    );
  }

  Widget _buildEmojiPicker() {
    // Common emojis for quick access
    final commonEmojis = [
      '😀',
      '😂',
      '🤣',
      '😊',
      '😍',
      '🥰',
      '😘',
      '😋',
      '🤔',
      '🙄',
      '😴',
      '😎',
      '🤩',
      '🥳',
      '😢',
      '😭',
      '😤',
      '😡',
      '🤯',
      '😱',
      '🤗',
      '🙃',
      '😉',
      '😇',
      '👍',
      '👎',
      '👌',
      '✌️',
      '🤞',
      '👏',
      '🙌',
      '👐',
      '❤️',
      '💕',
      '💯',
      '🔥',
      '⭐',
      '✨',
      '💫',
      '🎉',
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Emojis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showEmojiPicker = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: commonEmojis.length,
              itemBuilder: (context, index) {
                final emoji = commonEmojis[index];
                return GestureDetector(
                  onTap: () => _insertEmoji(emoji),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });

    if (_showEmojiPicker) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;

    final newText = text.replaceRange(selection.start, selection.end, emoji);

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );
  }

  void _handleAttachmentAction(String action) {
    switch (action) {
      case 'image':
        widget.onAttachImage?.call();
        // For demo purposes, simulate attachment
        setState(() {
          _attachmentData = {'type': 'image', 'name': 'image.jpg'};
        });
        break;
      case 'file':
        widget.onAttachFile?.call();
        // For demo purposes, simulate attachment
        setState(() {
          _attachmentData = {'type': 'file', 'name': 'document.pdf'};
        });
        break;
    }
  }

  void _sendMessage() {
    final content = _textController.text.trim();

    // Must have either text content or attachment
    if (content.isEmpty && _attachmentData == null) return;

    // Check thread permissions
    if (!_canSendMessage()) {
      _showPermissionError();
      return;
    }

    widget.onSendMessage?.call(
      content,
      replyToMessageId: widget.replyToMessage?.id,
      attachmentData: _attachmentData,
    );

    // Clear composer
    _textController.clear();
    setState(() {
      _attachmentData = null;
      _isExpanded = false;
      _showEmojiPicker = false;
    });

    _stopTyping();
  }

  bool _canSendMessage() {
    // Check if thread is active
    if (!widget.thread.isActive) return false;

    // Check if user is in thread
    final currentParticipant = widget.thread.participants
        .where((p) => p.id == widget.currentUserId)
        .firstOrNull;

    if (currentParticipant == null || !currentParticipant.isActive) {
      return false;
    }

    // Check moderators-only setting
    if (widget.thread.settings.moderatorsOnly &&
        currentParticipant.role != ThreadParticipantRole.creator &&
        currentParticipant.role != ThreadParticipantRole.moderator) {
      return false;
    }

    return true;
  }

  void _showPermissionError() {
    String message;

    if (!widget.thread.isActive) {
      message = 'This thread is no longer active';
    } else if (widget.thread.settings.moderatorsOnly) {
      message = 'Only moderators can post in this thread';
    } else {
      message = 'You do not have permission to post in this thread';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[600]),
    );
  }
}

/// A simplified version of ThreadComposer for inline use
class InlineThreadComposer extends StatelessWidget {
  /// The thread context
  final Thread thread;

  /// Current user ID
  final String currentUserId;

  /// Called when user wants to open the full composer
  final VoidCallback? onOpenComposer;

  /// Called when user wants to send a quick reply
  final void Function(String content)? onQuickReply;

  /// Theme configuration
  final ChatThemeData? theme;

  const InlineThreadComposer({
    super.key,
    required this.thread,
    required this.currentUserId,
    this.onOpenComposer,
    this.onQuickReply,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final canPost = _canSendMessage();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 16),
          ),

          const SizedBox(width: 12),

          // Quick reply input
          Expanded(
            child: GestureDetector(
              onTap: canPost ? onOpenComposer : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: canPost ? Colors.grey[100] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: canPost ? Colors.grey[300]! : Colors.grey[200]!,
                  ),
                ),
                child: Text(
                  canPost ? 'Reply to thread...' : _getDisabledMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: canPost ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),

          if (canPost) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue[600]),
              onPressed: onOpenComposer,
            ),
          ],
        ],
      ),
    );
  }

  bool _canSendMessage() {
    if (!thread.isActive) return false;

    final currentParticipant = thread.participants
        .where((p) => p.id == currentUserId)
        .firstOrNull;

    if (currentParticipant == null || !currentParticipant.isActive) {
      return false;
    }

    if (thread.settings.moderatorsOnly &&
        currentParticipant.role != ThreadParticipantRole.creator &&
        currentParticipant.role != ThreadParticipantRole.moderator) {
      return false;
    }

    return true;
  }

  String _getDisabledMessage() {
    if (!thread.isActive) {
      return 'Thread is closed';
    } else if (thread.settings.moderatorsOnly) {
      return 'Moderators only';
    } else {
      return 'Cannot reply';
    }
  }
}
