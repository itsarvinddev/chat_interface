import 'dart:async';

import 'package:flutter/foundation.dart';

import '../adapter/chat_adapter.dart';
import '../models/models.dart';
import '../services/thread_service.dart';

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

  // Threading state
  final ValueNotifier<List<Thread>> threads = ValueNotifier<List<Thread>>([]);
  final ValueNotifier<Thread?> activeThread = ValueNotifier<Thread?>(null);
  final ValueNotifier<bool> showThreads = ValueNotifier<bool>(false);

  ChatController({
    required this.adapter,
    required this.channelId,
    required this.currentUser,
  });

  /// Attach adapter streams.
  StreamSubscription<List<Message>>? _messagesSub;
  StreamSubscription<TypingState>? _typingSub;
  StreamSubscription<Channel>? _channelSub;
  StreamSubscription<ThreadServiceEvent>? _threadEventsSub;

  void attach() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _channelSub?.cancel();
    _threadEventsSub?.cancel();

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

    // Listen to thread service events
    _threadEventsSub = ThreadService.events.listen(_handleThreadEvent);

    // Load initial threads
    _refreshThreads();
  }

  void detach() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _channelSub?.cancel();
    _threadEventsSub?.cancel();
    _messagesSub = null;
    _typingSub = null;
    _channelSub = null;
    _threadEventsSub = null;
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

  /// Vote on a poll
  Future<void> voteOnPoll(String pollId, List<String> optionIds) async {
    // For now, this is a placeholder implementation
    // In a real app, this would call the adapter to submit votes

    // For demo purposes, just show what was voted on
    print('Voted on poll $pollId with options: ${optionIds.join(", ")}');

    // In a real implementation, this would:
    // 1. Send vote data to the backend through the adapter
    // 2. Update the local poll state when the backend confirms the vote
    // 3. Trigger a UI refresh to show the updated poll results
  }

  // ===== THREADING FUNCTIONALITY =====

  /// Create a new thread from a message
  Future<Thread> createThread({
    required Message originalMessage,
    required String title,
    String? description,
    ThreadPriority priority = ThreadPriority.normal,
    ThreadSettings? settings,
    List<String>? additionalParticipantIds,
  }) async {
    final thread = await ThreadService.createThread(
      title: title,
      originalMessageId: originalMessage.id.value,
      createdBy: currentUser.id.value,
      description: description,
      priority: priority,
      settings: settings,
      initialParticipantIds: additionalParticipantIds,
    );

    _refreshThreads();
    return thread;
  }

  /// Get threads associated with a specific message
  List<Thread> getMessageThreads(MessageId messageId) {
    return ThreadService.getMessageThreads(messageId.value);
  }

  /// Get all threads for the current user
  List<Thread> getUserThreads() {
    return ThreadService.getUserThreads(currentUser.id.value);
  }

  /// Send a message in a thread
  Future<ThreadMessage> sendThreadMessage({
    required String threadId,
    required String content,
    String? replyToMessageId,
    ThreadMessageType type = ThreadMessageType.text,
    Map<String, dynamic>? attachmentData,
  }) async {
    final message = await ThreadService.addMessage(
      threadId: threadId,
      senderId: currentUser.id.value,
      content: content,
      replyToMessageId: replyToMessageId,
      type: type,
      attachmentData: attachmentData,
    );

    _refreshThreads();
    return message;
  }

  /// Edit a thread message
  Future<bool> editThreadMessage({
    required String threadId,
    required String messageId,
    required String newContent,
  }) async {
    final success = await ThreadService.editMessage(
      threadId: threadId,
      messageId: messageId,
      newContent: newContent,
      editorId: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
    }

    return success;
  }

  /// Delete a thread message
  Future<bool> deleteThreadMessage({
    required String threadId,
    required String messageId,
  }) async {
    final success = await ThreadService.deleteMessage(
      threadId: threadId,
      messageId: messageId,
      deleterId: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
    }

    return success;
  }

  /// React to a thread message
  Future<bool> reactToThreadMessage({
    required String threadId,
    required String messageId,
    required String emoji,
  }) async {
    final success = await ThreadService.addReaction(
      threadId: threadId,
      messageId: messageId,
      emoji: emoji,
      userId: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
    }

    return success;
  }

  /// Join a thread
  Future<bool> joinThread(String threadId) async {
    final success = await ThreadService.addParticipant(
      threadId: threadId,
      participantId: currentUser.id.value,
      addedBy: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
    }

    return success;
  }

  /// Leave a thread
  Future<bool> leaveThread(String threadId) async {
    final success = await ThreadService.removeParticipant(
      threadId: threadId,
      participantId: currentUser.id.value,
      removedBy: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
    }

    return success;
  }

  /// Update typing status in a thread
  Future<void> setThreadTyping(String threadId, bool isTyping) async {
    await ThreadService.updateTypingStatus(
      threadId: threadId,
      participantId: currentUser.id.value,
      isTyping: isTyping,
    );
  }

  /// Mark thread messages as seen
  Future<void> markThreadMessagesAsSeen(
    String threadId,
    List<String> messageIds,
  ) async {
    await ThreadService.markMessagesAsSeen(
      threadId: threadId,
      participantId: currentUser.id.value,
      messageIds: messageIds,
    );
  }

  /// Archive a thread
  Future<bool> archiveThread(String threadId) async {
    final success = await ThreadService.archiveThread(
      threadId: threadId,
      archivedBy: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
    }

    return success;
  }

  /// Delete a thread
  Future<bool> deleteThread(String threadId) async {
    final success = await ThreadService.deleteThread(
      threadId: threadId,
      deletedBy: currentUser.id.value,
    );

    if (success) {
      _refreshThreads();
      // Close active thread if it was deleted
      if (activeThread.value?.id == threadId) {
        closeActiveThread();
      }
    }

    return success;
  }

  /// Open a thread for viewing
  void openThread(Thread thread) {
    activeThread.value = thread;
    showThreads.value = true;
    notifyListeners();
  }

  /// Close the active thread
  void closeActiveThread() {
    activeThread.value = null;
    showThreads.value = false;
    notifyListeners();
  }

  /// Toggle thread view visibility
  void toggleThreadsView() {
    showThreads.value = !showThreads.value;
    notifyListeners();
  }

  /// Get unread thread count for current user
  int getUnreadThreadCount() {
    return threads.value
        .where(
          (thread) => thread.getUnreadMessageCount(currentUser.id.value) > 0,
        )
        .length;
  }

  /// Check if user can post in a thread
  bool canPostInThread(String threadId) {
    return ThreadService.canUserPostInThread(threadId, currentUser.id.value);
  }

  /// Check if user can manage a thread
  bool canManageThread(String threadId) {
    return ThreadService.canUserManageThread(threadId, currentUser.id.value);
  }

  /// Search threads
  List<Thread> searchThreads(String query) {
    return ThreadService.searchThreads(
      query: query,
      userId: currentUser.id.value,
    );
  }

  /// Get thread statistics
  ThreadStatistics getThreadStatistics(String threadId) {
    return ThreadService.getThreadStatistics(threadId);
  }

  /// Handle thread service events
  void _handleThreadEvent(ThreadServiceEvent event) {
    // Refresh threads when any thread event occurs
    _refreshThreads();

    // Update active thread if it's affected
    if (activeThread.value != null) {
      if (event is ThreadCreatedEvent &&
          event.thread.id == activeThread.value!.id) {
        activeThread.value = event.thread;
      } else if (event is ThreadMessageAddedEvent &&
          event.thread.id == activeThread.value!.id) {
        activeThread.value = event.thread;
      } else if (event is ThreadDeletedEvent &&
          event.threadId == activeThread.value!.id) {
        closeActiveThread();
      }
    }

    notifyListeners();
  }

  /// Refresh threads list
  void _refreshThreads() {
    threads.value = ThreadService.getUserThreads(currentUser.id.value);
  }

  @override
  void dispose() {
    detach();
    messages.dispose();
    typing.dispose();
    channel.dispose();
    replyTo.dispose();
    draftAttachments.dispose();
    threads.dispose();
    activeThread.dispose();
    showThreads.dispose();
    super.dispose();
  }
}
