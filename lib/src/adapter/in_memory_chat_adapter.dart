import 'dart:async';

import '../models/models.dart';
import 'chat_adapter.dart';

/// Simple in-memory adapter for demos and tests.
class InMemoryChatAdapter implements ChatAdapter {
  final ChatUser currentUser;

  InMemoryChatAdapter({required this.currentUser});

  final Map<String, List<Message>> _messagesByChannel =
      <String, List<Message>>{};
  final Map<String, StreamController<List<Message>>> _messageCtrls =
      <String, StreamController<List<Message>>>{};
  final Map<String, StreamController<TypingState>> _typingCtrls =
      <String, StreamController<TypingState>>{};
  final Map<String, Set<TypingUser>> _typingState = <String, Set<TypingUser>>{};
  final Map<String, StreamController<Channel>> _channelCtrls =
      <String, StreamController<Channel>>{};
  final StreamController<Map<ChatUserId, bool>> _presenceCtrl =
      StreamController<Map<ChatUserId, bool>>.broadcast();
  final Map<ChatUserId, bool> _presence = <ChatUserId, bool>{};

  List<Message> _ensureMessages(ChannelId channelId) {
    return _messagesByChannel.putIfAbsent(channelId.value, () => <Message>[]);
  }

  StreamController<List<Message>> _ensureMessagesCtrl(ChannelId channelId) {
    return _messageCtrls.putIfAbsent(
      channelId.value,
      () => StreamController<List<Message>>.broadcast(),
    );
  }

  StreamController<TypingState> _ensureTypingCtrl(ChannelId channelId) {
    return _typingCtrls.putIfAbsent(
      channelId.value,
      () => StreamController<TypingState>.broadcast(),
    );
  }

  Set<TypingUser> _ensureTypingState(ChannelId channelId) {
    return _typingState.putIfAbsent(channelId.value, () => <TypingUser>{});
  }

  StreamController<Channel> _ensureChannelCtrl(ChannelId channelId) {
    return _channelCtrls.putIfAbsent(
      channelId.value,
      () => StreamController<Channel>.broadcast(),
    );
  }

  Channel _initialChannel(ChannelId channelId) {
    return Channel(
      id: channelId,
      kind: ChannelKind.group,
      name: 'Channel ${channelId.value}',
      members: <ChatUser>[currentUser],
    );
  }

  void _emitAll(ChannelId channelId) {
    final List<Message> list = List<Message>.unmodifiable(
      _ensureMessages(channelId),
    );
    _ensureMessagesCtrl(channelId).add(list);
  }

  @override
  Stream<List<Message>> watchMessages(
    ChannelId channelId, {
    MessageId? after,
    MessageId? before,
    int? limit,
  }) {
    // Emit current snapshot first on subscription
    final StreamController<List<Message>> ctrl = _ensureMessagesCtrl(channelId);
    // Microtask to push initial value
    scheduleMicrotask(
      () => ctrl.add(List<Message>.unmodifiable(_ensureMessages(channelId))),
    );
    return ctrl.stream;
  }

  @override
  Stream<TypingState> watchTyping(ChannelId channelId) {
    final StreamController<TypingState> ctrl = _ensureTypingCtrl(channelId);
    scheduleMicrotask(
      () => ctrl.add(
        TypingState(
          typingUsers: _ensureTypingState(channelId),
          lastUpdated: DateTime.now(),
        ),
      ),
    );
    return ctrl.stream;
  }

  @override
  Stream<Channel> watchChannel(ChannelId channelId) {
    final StreamController<Channel> ctrl = _ensureChannelCtrl(channelId);
    scheduleMicrotask(() => ctrl.add(_initialChannel(channelId)));
    return ctrl.stream;
  }

  @override
  Stream<Map<ChatUserId, bool>> watchPresence(Set<ChatUserId> userIds) {
    // Initialize presence entries as false for the requested set
    for (final ChatUserId id in userIds) {
      _presence[id] = _presence[id] ?? false;
    }
    scheduleMicrotask(
      () => _presenceCtrl.add(Map<ChatUserId, bool>.unmodifiable(_presence)),
    );
    return _presenceCtrl.stream;
  }

  @override
  Future<Message> sendMessage(ChannelId channelId, Message draft) async {
    final List<Message> list = _ensureMessages(channelId);
    list.add(draft);
    _emitAll(channelId);
    return draft;
  }

  @override
  Future<void> editMessage(
    ChannelId channelId,
    MessageId messageId, {
    String? text,
    List<Attachment>? attachments,
    Map<String, dynamic>? extra,
  }) async {
    final List<Message> list = _ensureMessages(channelId);
    final int idx = list.indexWhere(
      (Message m) => m.id.value == messageId.value,
    );
    if (idx != -1) {
      final Message m = list[idx];

      // Create edit history entry
      final List<MessageEdit> editHistory = List<MessageEdit>.from(
        m.editHistory,
      );
      if (text != null && text != m.text) {
        editHistory.add(
          MessageEdit(
            previousText: m.text ?? '',
            editedAt: DateTime.now(),
            editedBy: m.author,
          ),
        );
      }

      list[idx] = Message(
        id: m.id,
        author: m.author,
        kind: m.kind,
        text: text ?? m.text,
        attachments: attachments ?? m.attachments,
        createdAt: m.createdAt,
        editedAt: DateTime.now(),
        replyTo: m.replyTo,
        isPinned: m.isPinned,
        reactions: m.reactions, // Preserve reactions
        editHistory: editHistory,
      );
      _emitAll(channelId);
    }
  }

  @override
  Future<void> deleteMessage(
    ChannelId channelId,
    MessageId messageId, {
    bool hard = false,
  }) async {
    final List<Message> list = _ensureMessages(channelId);
    list.removeWhere((Message m) => m.id.value == messageId.value);
    _emitAll(channelId);
  }

  @override
  Future<void> react(
    ChannelId channelId,
    MessageId messageId,
    String reactionKey, {
    required bool add,
  }) async {
    final List<Message> list = _ensureMessages(channelId);
    final int idx = list.indexWhere(
      (Message m) => m.id.value == messageId.value,
    );
    if (idx == -1) return;
    final Message m = list[idx];
    final Map<String, ReactionSummary> reactions =
        Map<String, ReactionSummary>.from(m.reactions);
    final ReactionSummary? existing = reactions[reactionKey];
    final Set<ChatUserId> by = existing?.by.toSet() ?? <ChatUserId>{};
    if (add) {
      by.add(currentUser.id);
    } else {
      by.remove(currentUser.id);
    }
    if (by.isEmpty) {
      reactions.remove(reactionKey);
    } else {
      reactions[reactionKey] = ReactionSummary(key: reactionKey, by: by);
    }
    list[idx] = Message(
      id: m.id,
      author: m.author,
      kind: m.kind,
      text: m.text,
      attachments: m.attachments,
      createdAt: m.createdAt,
      editedAt: m.editedAt,
      replyTo: m.replyTo,
      isPinned: m.isPinned,
      reactions: reactions,
    );
    _emitAll(channelId);
  }

  @override
  Future<void> pinMessage(
    ChannelId channelId,
    MessageId messageId, {
    required bool pinned,
  }) async {
    final List<Message> list = _ensureMessages(channelId);
    final int idx = list.indexWhere(
      (Message m) => m.id.value == messageId.value,
    );
    if (idx != -1) {
      final Message m = list[idx];
      list[idx] = Message(
        id: m.id,
        author: m.author,
        kind: m.kind,
        text: m.text,
        attachments: m.attachments,
        createdAt: m.createdAt,
        editedAt: m.editedAt,
        replyTo: m.replyTo,
        isPinned: pinned,
      );
      _emitAll(channelId);
    }
  }

  @override
  Future<void> markTyping(ChannelId channelId, {required bool isTyping}) async {
    final Set<TypingUser> set = _ensureTypingState(channelId);
    final now = DateTime.now();

    if (isTyping) {
      // Add or update typing user
      set.removeWhere((user) => user.user.id.value == currentUser.id.value);
      set.add(TypingUser(user: currentUser, startedAt: now, lastActivity: now));
    } else {
      // Remove typing user
      set.removeWhere((user) => user.user.id.value == currentUser.id.value);
    }

    _ensureTypingCtrl(
      channelId,
    ).add(TypingState(typingUsers: set, lastUpdated: now));
  }

  @override
  Future<void> markRead(ChannelId channelId, MessageId messageId) async {
    // No-op for in-memory scaffold
  }

  @override
  Future<List<Message>> loadMore(
    ChannelId channelId, {
    MessageId? before,
    int limit = 30,
  }) async {
    return List<Message>.unmodifiable(_ensureMessages(channelId));
  }
}
