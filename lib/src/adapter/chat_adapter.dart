import '../models/models.dart';

/// Backend-agnostic adapter interface for chat data.
abstract class ChatAdapter {
  // Streams
  Stream<List<Message>> watchMessages(
    ChannelId channelId, {
    MessageId? after,
    MessageId? before,
    int? limit,
  });

  Stream<TypingState> watchTyping(ChannelId channelId) =>
      Stream<TypingState>.empty();

  Stream<Map<ChatUserId, bool>> watchPresence(Set<ChatUserId> userIds) =>
      Stream<Map<ChatUserId, bool>>.empty();

  Stream<Channel> watchChannel(ChannelId channelId) => const Stream.empty();

  // Mutations
  Future<Message> sendMessage(ChannelId channelId, Message draft);
  Future<void> editMessage(
    ChannelId channelId,
    MessageId messageId, {
    String? text,
    List<Attachment>? attachments,
    Map<String, dynamic>? extra,
  }) async {}

  Future<void> deleteMessage(
    ChannelId channelId,
    MessageId messageId, {
    bool hard = false,
  }) async {}

  Future<void> react(
    ChannelId channelId,
    MessageId messageId,
    String reactionKey, {
    required bool add,
  }) async {}

  Future<void> pinMessage(
    ChannelId channelId,
    MessageId messageId, {
    required bool pinned,
  }) async {}

  Future<void> markTyping(
    ChannelId channelId, {
    required bool isTyping,
  }) async {}

  Future<void> markRead(ChannelId channelId, MessageId messageId) async {}

  Future<List<Message>> loadMore(
    ChannelId channelId, {
    MessageId? before,
    int limit = 30,
  }) async => const <Message>[];
}
