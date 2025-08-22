import 'dart:async';

import '../models/models.dart';

/// Service for managing thread operations and state
class ThreadService {
  /// Internal storage for threads (in real app, this would connect to backend)
  static final Map<String, Thread> _threads = {};

  /// Stream controller for thread updates
  static final StreamController<ThreadServiceEvent> _eventController =
      StreamController<ThreadServiceEvent>.broadcast();

  /// Stream of thread service events
  static Stream<ThreadServiceEvent> get events => _eventController.stream;

  /// Create a new thread
  static Future<Thread> createThread({
    required String title,
    required String originalMessageId,
    required String createdBy,
    String? description,
    ThreadPriority priority = ThreadPriority.normal,
    ThreadSettings? settings,
    List<String>? initialParticipantIds,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final threadId = 'thread_${now.millisecondsSinceEpoch}';

    // Create initial participants
    final participants = <ThreadParticipant>[
      // Creator is always first participant
      ThreadParticipant(
        id: createdBy,
        displayName: 'Thread Creator', // In real app, get from user service
        joinedAt: now,
        role: ThreadParticipantRole.creator,
      ),
    ];

    // Add additional participants if specified
    if (initialParticipantIds?.isNotEmpty == true) {
      for (final participantId in initialParticipantIds!) {
        if (participantId != createdBy) {
          participants.add(
            ThreadParticipant(
              id: participantId,
              displayName:
                  'User $participantId', // In real app, get from user service
              joinedAt: now,
              role: ThreadParticipantRole.member,
            ),
          );
        }
      }
    }

    final thread = Thread(
      id: threadId,
      originalMessageId: originalMessageId,
      title: title,
      description: description,
      priority: priority,
      participants: participants,
      createdAt: now,
      lastActivityAt: now,
      createdBy: createdBy,
      settings: settings ?? const ThreadSettings(),
      metadata: metadata,
    );

    _threads[threadId] = thread;

    _eventController.add(ThreadCreatedEvent(thread: thread));

    return thread;
  }

  /// Get a thread by ID
  static Thread? getThread(String threadId) {
    return _threads[threadId];
  }

  /// Get all threads
  static List<Thread> getAllThreads() {
    return _threads.values.toList();
  }

  /// Get threads for a specific user
  static List<Thread> getUserThreads(String userId) {
    return _threads.values
        .where((thread) => thread.participants.any((p) => p.id == userId))
        .toList();
  }

  /// Get threads associated with a specific message
  static List<Thread> getMessageThreads(String messageId) {
    return _threads.values
        .where((thread) => thread.originalMessageId == messageId)
        .toList();
  }

  /// Add a message to a thread
  static Future<ThreadMessage> addMessage({
    required String threadId,
    required String senderId,
    required String content,
    String? replyToMessageId,
    ThreadMessageType type = ThreadMessageType.text,
    Map<String, dynamic>? attachmentData,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) {
      throw ThreadNotFoundException('Thread not found: $threadId');
    }

    // Check permissions
    if (!canUserPostInThread(threadId, senderId)) {
      throw ThreadPermissionException('User cannot post in this thread');
    }

    final now = DateTime.now();
    final messageId = 'thread_msg_${now.millisecondsSinceEpoch}';

    final message = ThreadMessage(
      id: messageId,
      senderId: senderId,
      content: content,
      timestamp: now,
      type: type,
      replyToMessageId: replyToMessageId,
      attachmentData: attachmentData,
    );

    // Update thread with new message
    final updatedMessages = List<ThreadMessage>.from(thread.messages)
      ..add(message);
    final updatedThread = thread.copyWith(
      messages: updatedMessages,
      lastActivityAt: now,
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadMessageAddedEvent(thread: updatedThread, message: message),
    );

    return message;
  }

  /// Edit a message in a thread
  static Future<bool> editMessage({
    required String threadId,
    required String messageId,
    required String newContent,
    required String editorId,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    final messageIndex = thread.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return false;

    final originalMessage = thread.messages[messageIndex];

    // Check permissions (only sender or moderators can edit)
    if (!canUserEditMessage(threadId, messageId, editorId)) {
      throw ThreadPermissionException('User cannot edit this message');
    }

    final now = DateTime.now();
    final editedMessage = originalMessage.copyWith(
      content: newContent,
      isEdited: true,
      editedAt: now,
    );

    final updatedMessages = List<ThreadMessage>.from(thread.messages);
    updatedMessages[messageIndex] = editedMessage;

    final updatedThread = thread.copyWith(
      messages: updatedMessages,
      lastActivityAt: now,
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadMessageEditedEvent(
        thread: updatedThread,
        message: editedMessage,
        originalContent: originalMessage.content,
      ),
    );

    return true;
  }

  /// Delete a message from a thread
  static Future<bool> deleteMessage({
    required String threadId,
    required String messageId,
    required String deleterId,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Check permissions
    if (!canUserDeleteMessage(threadId, messageId, deleterId)) {
      throw ThreadPermissionException('User cannot delete this message');
    }

    final updatedMessages = thread.messages
        .where((m) => m.id != messageId)
        .toList();

    final updatedThread = thread.copyWith(
      messages: updatedMessages,
      lastActivityAt: DateTime.now(),
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadMessageDeletedEvent(thread: updatedThread, messageId: messageId),
    );

    return true;
  }

  /// Add a reaction to a message
  static Future<bool> addReaction({
    required String threadId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    final messageIndex = thread.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return false;

    final originalMessage = thread.messages[messageIndex];
    final now = DateTime.now();

    // Check if user already reacted with this emoji
    final existingReactionIndex = originalMessage.reactions.indexWhere(
      (r) => r.participantId == userId && r.emoji == emoji,
    );

    List<ThreadMessageReaction> updatedReactions;

    if (existingReactionIndex != -1) {
      // Remove existing reaction (toggle)
      updatedReactions = List<ThreadMessageReaction>.from(
        originalMessage.reactions,
      );
      updatedReactions.removeAt(existingReactionIndex);
    } else {
      // Add new reaction
      final reaction = ThreadMessageReaction(
        emoji: emoji,
        participantId: userId,
        timestamp: now,
      );
      updatedReactions = List<ThreadMessageReaction>.from(
        originalMessage.reactions,
      )..add(reaction);
    }

    final updatedMessage = originalMessage.copyWith(
      reactions: updatedReactions,
    );
    final updatedMessages = List<ThreadMessage>.from(thread.messages);
    updatedMessages[messageIndex] = updatedMessage;

    final updatedThread = thread.copyWith(
      messages: updatedMessages,
      lastActivityAt: now,
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadMessageReactionEvent(
        thread: updatedThread,
        message: updatedMessage,
        emoji: emoji,
        userId: userId,
        added: existingReactionIndex == -1,
      ),
    );

    return true;
  }

  /// Add a participant to a thread
  static Future<bool> addParticipant({
    required String threadId,
    required String participantId,
    required String addedBy,
    ThreadParticipantRole role = ThreadParticipantRole.member,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Check permissions
    if (!canUserManageParticipants(threadId, addedBy)) {
      throw ThreadPermissionException('User cannot add participants');
    }

    // Check if participant already exists
    if (thread.participants.any((p) => p.id == participantId)) {
      return false; // Already a participant
    }

    // Check participant limit
    if (thread.settings.maxParticipants != null &&
        thread.participants.length >= thread.settings.maxParticipants!) {
      throw ThreadLimitException('Thread has reached maximum participants');
    }

    final now = DateTime.now();
    final participant = ThreadParticipant(
      id: participantId,
      displayName: 'User $participantId', // In real app, get from user service
      joinedAt: now,
      role: role,
    );

    final updatedParticipants = List<ThreadParticipant>.from(
      thread.participants,
    )..add(participant);
    final updatedThread = thread.copyWith(
      participants: updatedParticipants,
      lastActivityAt: now,
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadParticipantAddedEvent(
        thread: updatedThread,
        participant: participant,
        addedBy: addedBy,
      ),
    );

    return true;
  }

  /// Remove a participant from a thread
  static Future<bool> removeParticipant({
    required String threadId,
    required String participantId,
    required String removedBy,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Check permissions
    if (!canUserManageParticipants(threadId, removedBy) &&
        removedBy != participantId) {
      // Users can always remove themselves
      throw ThreadPermissionException('User cannot remove participants');
    }

    // Cannot remove thread creator
    if (participantId == thread.createdBy) {
      throw ThreadPermissionException('Cannot remove thread creator');
    }

    final updatedParticipants = thread.participants
        .map((p) => p.id == participantId ? p.copyWith(isActive: false) : p)
        .toList();

    final updatedThread = thread.copyWith(
      participants: updatedParticipants,
      lastActivityAt: DateTime.now(),
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadParticipantRemovedEvent(
        thread: updatedThread,
        participantId: participantId,
        removedBy: removedBy,
      ),
    );

    return true;
  }

  /// Update participant typing status
  static Future<bool> updateTypingStatus({
    required String threadId,
    required String participantId,
    required bool isTyping,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    final participantIndex = thread.participants.indexWhere(
      (p) => p.id == participantId,
    );
    if (participantIndex == -1) return false;

    final updatedParticipants = List<ThreadParticipant>.from(
      thread.participants,
    );
    updatedParticipants[participantIndex] =
        updatedParticipants[participantIndex].copyWith(isTyping: isTyping);

    final updatedThread = thread.copyWith(participants: updatedParticipants);
    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadTypingEvent(
        thread: updatedThread,
        participantId: participantId,
        isTyping: isTyping,
      ),
    );

    return true;
  }

  /// Mark messages as seen by a participant
  static Future<bool> markMessagesAsSeen({
    required String threadId,
    required String participantId,
    required List<String> messageIds,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    bool hasChanges = false;
    final updatedMessages = thread.messages.map((message) {
      if (messageIds.contains(message.id) &&
          !message.hasBeenSeenBy(participantId)) {
        hasChanges = true;
        final updatedSeenBy = List<String>.from(message.seenBy)
          ..add(participantId);
        return message.copyWith(seenBy: updatedSeenBy);
      }
      return message;
    }).toList();

    if (hasChanges) {
      final updatedThread = thread.copyWith(messages: updatedMessages);
      _threads[threadId] = updatedThread;

      _eventController.add(
        ThreadMessagesSeenEvent(
          thread: updatedThread,
          participantId: participantId,
          messageIds: messageIds,
        ),
      );
    }

    return hasChanges;
  }

  /// Update thread settings
  static Future<bool> updateThreadSettings({
    required String threadId,
    required ThreadSettings settings,
    required String updatedBy,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Check permissions
    if (!canUserManageThread(threadId, updatedBy)) {
      throw ThreadPermissionException('User cannot update thread settings');
    }

    final updatedThread = thread.copyWith(
      settings: settings,
      lastActivityAt: DateTime.now(),
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadSettingsUpdatedEvent(thread: updatedThread, updatedBy: updatedBy),
    );

    return true;
  }

  /// Archive a thread
  static Future<bool> archiveThread({
    required String threadId,
    required String archivedBy,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Check permissions
    if (!canUserManageThread(threadId, archivedBy)) {
      throw ThreadPermissionException('User cannot archive this thread');
    }

    final updatedThread = thread.copyWith(
      status: ThreadStatus.archived,
      lastActivityAt: DateTime.now(),
    );

    _threads[threadId] = updatedThread;

    _eventController.add(
      ThreadArchivedEvent(thread: updatedThread, archivedBy: archivedBy),
    );

    return true;
  }

  /// Delete a thread
  static Future<bool> deleteThread({
    required String threadId,
    required String deletedBy,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Check permissions (usually only creator or moderators)
    if (!canUserDeleteThread(threadId, deletedBy)) {
      throw ThreadPermissionException('User cannot delete this thread');
    }

    _threads.remove(threadId);

    _eventController.add(
      ThreadDeletedEvent(threadId: threadId, deletedBy: deletedBy),
    );

    return true;
  }

  /// Check if user can post in thread
  static bool canUserPostInThread(String threadId, String userId) {
    final thread = _threads[threadId];
    if (thread == null || !thread.isActive) return false;

    final participant = thread.participants
        .where((p) => p.id == userId && p.isActive)
        .firstOrNull;

    if (participant == null) return false;

    // Check moderators-only setting
    if (thread.settings.moderatorsOnly &&
        participant.role != ThreadParticipantRole.creator &&
        participant.role != ThreadParticipantRole.moderator) {
      return false;
    }

    return true;
  }

  /// Check if user can edit a specific message
  static bool canUserEditMessage(
    String threadId,
    String messageId,
    String userId,
  ) {
    final thread = _threads[threadId];
    if (thread == null || !thread.settings.editingEnabled) return false;

    final message = thread.messages.where((m) => m.id == messageId).firstOrNull;
    if (message == null) return false;

    // Message sender can always edit their own messages
    if (message.senderId == userId) return true;

    // Moderators and creators can edit any message
    final participant = thread.participants
        .where((p) => p.id == userId)
        .firstOrNull;

    return participant?.role == ThreadParticipantRole.creator ||
        participant?.role == ThreadParticipantRole.moderator;
  }

  /// Check if user can delete a specific message
  static bool canUserDeleteMessage(
    String threadId,
    String messageId,
    String userId,
  ) {
    final thread = _threads[threadId];
    if (thread == null || !thread.settings.deletingEnabled) return false;

    final message = thread.messages.where((m) => m.id == messageId).firstOrNull;
    if (message == null) return false;

    // Message sender can delete their own messages
    if (message.senderId == userId) return true;

    // Moderators and creators can delete any message
    final participant = thread.participants
        .where((p) => p.id == userId)
        .firstOrNull;

    return participant?.role == ThreadParticipantRole.creator ||
        participant?.role == ThreadParticipantRole.moderator;
  }

  /// Check if user can manage participants
  static bool canUserManageParticipants(String threadId, String userId) {
    final thread = _threads[threadId];
    if (thread == null) return false;

    final participant = thread.participants
        .where((p) => p.id == userId)
        .firstOrNull;

    return participant?.role == ThreadParticipantRole.creator ||
        participant?.role == ThreadParticipantRole.moderator;
  }

  /// Check if user can manage thread (settings, archive, etc.)
  static bool canUserManageThread(String threadId, String userId) {
    final thread = _threads[threadId];
    if (thread == null) return false;

    final participant = thread.participants
        .where((p) => p.id == userId)
        .firstOrNull;

    return participant?.role == ThreadParticipantRole.creator ||
        participant?.role == ThreadParticipantRole.moderator;
  }

  /// Check if user can delete thread
  static bool canUserDeleteThread(String threadId, String userId) {
    final thread = _threads[threadId];
    if (thread == null) return false;

    // Usually only creator can delete thread
    return thread.createdBy == userId;
  }

  /// Search threads
  static List<Thread> searchThreads({
    required String query,
    String? userId,
    ThreadStatus? status,
    ThreadPriority? priority,
  }) {
    final allThreads = userId != null
        ? getUserThreads(userId)
        : getAllThreads();

    return allThreads.where((thread) {
      // Text search
      final queryLower = query.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          thread.title.toLowerCase().contains(queryLower) ||
          thread.description?.toLowerCase().contains(queryLower) == true;

      // Status filter
      final matchesStatus = status == null || thread.status == status;

      // Priority filter
      final matchesPriority = priority == null || thread.priority == priority;

      return matchesQuery && matchesStatus && matchesPriority;
    }).toList();
  }

  /// Get thread statistics
  static ThreadStatistics getThreadStatistics(String threadId) {
    final thread = _threads[threadId];
    if (thread == null) {
      return ThreadStatistics(
        totalMessages: 0,
        totalParticipants: 0,
        activeParticipants: 0,
        totalReactions: 0,
        averageResponseTime: Duration.zero,
      );
    }

    final totalReactions = thread.messages.fold(
      0,
      (sum, message) => sum + message.reactions.length,
    );

    // Calculate average response time (simplified)
    Duration averageResponseTime = Duration.zero;
    if (thread.messages.length > 1) {
      final totalTime = thread.messages.last.timestamp.difference(
        thread.messages.first.timestamp,
      );
      averageResponseTime = Duration(
        milliseconds: totalTime.inMilliseconds ~/ (thread.messages.length - 1),
      );
    }

    return ThreadStatistics(
      totalMessages: thread.messageCount,
      totalParticipants: thread.participants.length,
      activeParticipants: thread.activeParticipantCount,
      totalReactions: totalReactions,
      averageResponseTime: averageResponseTime,
    );
  }

  /// Clean up resources
  static void dispose() {
    _eventController.close();
  }
}

/// Statistics for a thread
class ThreadStatistics {
  final int totalMessages;
  final int totalParticipants;
  final int activeParticipants;
  final int totalReactions;
  final Duration averageResponseTime;

  const ThreadStatistics({
    required this.totalMessages,
    required this.totalParticipants,
    required this.activeParticipants,
    required this.totalReactions,
    required this.averageResponseTime,
  });
}

/// Base class for thread service events
abstract class ThreadServiceEvent {
  final DateTime timestamp;

  ThreadServiceEvent() : timestamp = DateTime.now();
}

/// Event when a thread is created
class ThreadCreatedEvent extends ThreadServiceEvent {
  final Thread thread;
  ThreadCreatedEvent({required this.thread});
}

/// Event when a message is added to a thread
class ThreadMessageAddedEvent extends ThreadServiceEvent {
  final Thread thread;
  final ThreadMessage message;
  ThreadMessageAddedEvent({required this.thread, required this.message});
}

/// Event when a message is edited
class ThreadMessageEditedEvent extends ThreadServiceEvent {
  final Thread thread;
  final ThreadMessage message;
  final String originalContent;
  ThreadMessageEditedEvent({
    required this.thread,
    required this.message,
    required this.originalContent,
  });
}

/// Event when a message is deleted
class ThreadMessageDeletedEvent extends ThreadServiceEvent {
  final Thread thread;
  final String messageId;
  ThreadMessageDeletedEvent({required this.thread, required this.messageId});
}

/// Event when a reaction is added or removed
class ThreadMessageReactionEvent extends ThreadServiceEvent {
  final Thread thread;
  final ThreadMessage message;
  final String emoji;
  final String userId;
  final bool added;
  ThreadMessageReactionEvent({
    required this.thread,
    required this.message,
    required this.emoji,
    required this.userId,
    required this.added,
  });
}

/// Event when a participant is added
class ThreadParticipantAddedEvent extends ThreadServiceEvent {
  final Thread thread;
  final ThreadParticipant participant;
  final String addedBy;
  ThreadParticipantAddedEvent({
    required this.thread,
    required this.participant,
    required this.addedBy,
  });
}

/// Event when a participant is removed
class ThreadParticipantRemovedEvent extends ThreadServiceEvent {
  final Thread thread;
  final String participantId;
  final String removedBy;
  ThreadParticipantRemovedEvent({
    required this.thread,
    required this.participantId,
    required this.removedBy,
  });
}

/// Event when typing status changes
class ThreadTypingEvent extends ThreadServiceEvent {
  final Thread thread;
  final String participantId;
  final bool isTyping;
  ThreadTypingEvent({
    required this.thread,
    required this.participantId,
    required this.isTyping,
  });
}

/// Event when messages are marked as seen
class ThreadMessagesSeenEvent extends ThreadServiceEvent {
  final Thread thread;
  final String participantId;
  final List<String> messageIds;
  ThreadMessagesSeenEvent({
    required this.thread,
    required this.participantId,
    required this.messageIds,
  });
}

/// Event when thread settings are updated
class ThreadSettingsUpdatedEvent extends ThreadServiceEvent {
  final Thread thread;
  final String updatedBy;
  ThreadSettingsUpdatedEvent({required this.thread, required this.updatedBy});
}

/// Event when a thread is archived
class ThreadArchivedEvent extends ThreadServiceEvent {
  final Thread thread;
  final String archivedBy;
  ThreadArchivedEvent({required this.thread, required this.archivedBy});
}

/// Event when a thread is deleted
class ThreadDeletedEvent extends ThreadServiceEvent {
  final String threadId;
  final String deletedBy;
  ThreadDeletedEvent({required this.threadId, required this.deletedBy});
}

/// Exception thrown when thread is not found
class ThreadNotFoundException implements Exception {
  final String message;
  ThreadNotFoundException(this.message);

  @override
  String toString() => 'ThreadNotFoundException: $message';
}

/// Exception thrown when user lacks permissions
class ThreadPermissionException implements Exception {
  final String message;
  ThreadPermissionException(this.message);

  @override
  String toString() => 'ThreadPermissionException: $message';
}

/// Exception thrown when thread limits are exceeded
class ThreadLimitException implements Exception {
  final String message;
  ThreadLimitException(this.message);

  @override
  String toString() => 'ThreadLimitException: $message';
}
