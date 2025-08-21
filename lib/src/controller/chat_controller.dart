import 'dart:async';

import 'package:flutter/foundation.dart';

import '../adapter/chat_adapter.dart';
import '../models/models.dart';

/// High-level controller orchestrating chat state.
class ChatController extends ChangeNotifier {
  final ChatAdapter adapter;
  final ChannelId channelId;
  final ChatUser currentUser;

  final ValueNotifier<List<Message>> messages = ValueNotifier<List<Message>>(
    <Message>[],
  );
  final ValueNotifier<TypingState> typing = ValueNotifier<TypingState>(
    TypingState(typingUsers: {}, lastUpdated: DateTime.now()),
  );
  final ValueNotifier<Channel?> channel = ValueNotifier<Channel?>(null);
  final ValueNotifier<Message?> replyTo = ValueNotifier<Message?>(null);
  final ValueNotifier<List<Attachment>> draftAttachments =
      ValueNotifier<List<Attachment>>(<Attachment>[]);

  ChatController({
    required this.adapter,
    required this.channelId,
    required this.currentUser,
  });

  /// Attach adapter streams.
  StreamSubscription<List<Message>>? _messagesSub;
  StreamSubscription<TypingState>? _typingSub;
  StreamSubscription<Channel>? _channelSub;

  void attach() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _channelSub?.cancel();

    _messagesSub = adapter.watchMessages(channelId).listen((
      List<Message> list,
    ) {
      messages.value = list;
      // Mark messages as read when they arrive
      if (list.isNotEmpty) {
        _markReadUpTo(list.first.id);
      }
    });
    _typingSub = adapter.watchTyping(channelId).listen((TypingState t) {
      typing.value = t;
    });
    _channelSub = adapter.watchChannel(channelId).listen((Channel c) {
      channel.value = c;
    });
  }

  void detach() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _channelSub?.cancel();
    _messagesSub = null;
    _typingSub = null;
    _channelSub = null;
  }

  Future<void> sendText(String text) async {
    final Message message = Message(
      id: MessageId(DateTime.now().microsecondsSinceEpoch.toString()),
      author: currentUser,
      kind: MessageKind.text,
      text: text,
      attachments: draftAttachments.value,
      createdAt: DateTime.now(),
      replyTo: replyTo.value?.id,
    );
    await adapter.sendMessage(channelId, message);
    replyTo.value = null;
    draftAttachments.value = <Attachment>[];
  }

  Future<void> setTyping(bool isTyping) async {
    await adapter.markTyping(channelId, isTyping: isTyping);
  }

  Future<void> toggleReaction(Message message, String key) async {
    final bool mine =
        message.reactions[key]?.by.contains(currentUser.id) == true;
    await adapter.react(channelId, message.id, key, add: !mine);
  }

  void addAttachment(Attachment attachment) {
    final List<Attachment> next = List<Attachment>.from(draftAttachments.value)
      ..add(attachment);
    draftAttachments.value = next;
  }

  void removeAttachmentAt(int index) {
    final List<Attachment> next = List<Attachment>.from(draftAttachments.value)
      ..removeAt(index);
    draftAttachments.value = next;
  }

  void _markReadUpTo(MessageId messageId) async {
    await adapter.markRead(channelId, messageId);
  }

  void setReplyTo(Message message) {
    replyTo.value = message;
    notifyListeners();
  }

  /// Edit a message's text content
  Future<void> editMessageText(Message message, String newText) async {
    if (message.author.id.value != currentUser.id.value) {
      throw Exception('Cannot edit messages from other users');
    }

    if (newText.trim().isEmpty) {
      throw Exception('Message text cannot be empty');
    }

    await adapter.editMessage(channelId, message.id, text: newText.trim());
  }

  /// Edit a message's attachments
  Future<void> editMessageAttachments(
    Message message,
    List<Attachment> newAttachments,
  ) async {
    if (message.author.id.value != currentUser.id.value) {
      throw Exception('Cannot edit messages from other users');
    }

    await adapter.editMessage(
      channelId,
      message.id,
      attachments: newAttachments,
    );
  }

  /// Check if a message can be edited by the current user
  bool canEditMessage(Message message) {
    return message.author.id.value == currentUser.id.value &&
        message.kind == MessageKind.text &&
        message.createdAt.isAfter(
          DateTime.now().subtract(const Duration(hours: 24)),
        );
  }

  /// Get edit history for a message
  List<MessageEdit> getMessageEditHistory(Message message) {
    return message.editHistory;
  }

  /// Delete a message (soft delete by default)
  Future<void> deleteMessage(Message message, {bool hard = false}) async {
    if (message.author.id.value != currentUser.id.value) {
      throw Exception('Cannot delete messages from other users');
    }

    await adapter.deleteMessage(channelId, message.id, hard: hard);
  }

  /// Check if a message can be deleted by the current user
  bool canDeleteMessage(Message message) {
    return message.author.id.value == currentUser.id.value &&
        message.createdAt.isAfter(
          DateTime.now().subtract(const Duration(hours: 24)),
        );
  }
}
