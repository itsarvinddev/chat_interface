import 'package:flutter/foundation.dart';

/// Represents a participant in a thread conversation
@immutable
class ThreadParticipant {
  /// Unique identifier for this participant
  final String id;

  /// Display name of the participant
  final String displayName;

  /// Avatar URL or base64 encoded image
  final String? avatar;

  /// Timestamp when participant joined the thread
  final DateTime joinedAt;

  /// Whether this participant is currently active in the thread
  final bool isActive;

  /// Role of the participant in the thread
  final ThreadParticipantRole role;

  /// Last time the participant was seen online
  final DateTime? lastSeenAt;

  /// Whether this participant is currently typing
  final bool isTyping;

  const ThreadParticipant({
    required this.id,
    required this.displayName,
    this.avatar,
    required this.joinedAt,
    this.isActive = true,
    this.role = ThreadParticipantRole.member,
    this.lastSeenAt,
    this.isTyping = false,
  });

  /// Create a copy with updated properties
  ThreadParticipant copyWith({
    String? id,
    String? displayName,
    String? avatar,
    DateTime? joinedAt,
    bool? isActive,
    ThreadParticipantRole? role,
    DateTime? lastSeenAt,
    bool? isTyping,
  }) {
    return ThreadParticipant(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatar': avatar,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
      'role': role.name,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'isTyping': isTyping,
    };
  }

  /// Create from JSON
  factory ThreadParticipant.fromJson(Map<String, dynamic> json) {
    return ThreadParticipant(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      role: ThreadParticipantRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => ThreadParticipantRole.member,
      ),
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreadParticipant &&
        other.id == id &&
        other.displayName == displayName &&
        other.avatar == avatar &&
        other.joinedAt == joinedAt &&
        other.isActive == isActive &&
        other.role == role &&
        other.lastSeenAt == lastSeenAt &&
        other.isTyping == isTyping;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      avatar,
      joinedAt,
      isActive,
      role,
      lastSeenAt,
      isTyping,
    );
  }

  @override
  String toString() {
    return 'ThreadParticipant(id: $id, displayName: $displayName, role: $role, isActive: $isActive)';
  }
}

/// Role of a participant in a thread
enum ThreadParticipantRole {
  /// Creator of the thread
  creator,

  /// Regular member with standard permissions
  member,

  /// Moderator with elevated permissions
  moderator,

  /// Read-only observer
  observer,
}

/// Represents a single message within a thread
@immutable
class ThreadMessage {
  /// Unique identifier for this thread message
  final String id;

  /// ID of the participant who sent this message
  final String senderId;

  /// Content of the message
  final String content;

  /// Timestamp when the message was sent
  final DateTime timestamp;

  /// Whether this message has been edited
  final bool isEdited;

  /// Timestamp of last edit (if applicable)
  final DateTime? editedAt;

  /// Type of thread message
  final ThreadMessageType type;

  /// List of participant IDs who have seen this message
  final List<String> seenBy;

  /// List of reactions to this message
  final List<ThreadMessageReaction> reactions;

  /// ID of the message this is replying to (within the thread)
  final String? replyToMessageId;

  /// Optional attachment data
  final Map<String, dynamic>? attachmentData;

  const ThreadMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isEdited = false,
    this.editedAt,
    this.type = ThreadMessageType.text,
    this.seenBy = const [],
    this.reactions = const [],
    this.replyToMessageId,
    this.attachmentData,
  });

  /// Whether this message has been seen by the given participant
  bool hasBeenSeenBy(String participantId) {
    return seenBy.contains(participantId);
  }

  /// Get reactions grouped by emoji
  Map<String, List<ThreadMessageReaction>> get groupedReactions {
    final Map<String, List<ThreadMessageReaction>> grouped = {};
    for (final reaction in reactions) {
      grouped.putIfAbsent(reaction.emoji, () => []).add(reaction);
    }
    return grouped;
  }

  /// Whether this message has reactions
  bool get hasReactions => reactions.isNotEmpty;

  /// Total number of reactions
  int get totalReactions => reactions.length;

  /// Create a copy with updated properties
  ThreadMessage copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isEdited,
    DateTime? editedAt,
    ThreadMessageType? type,
    List<String>? seenBy,
    List<ThreadMessageReaction>? reactions,
    String? replyToMessageId,
    Map<String, dynamic>? attachmentData,
  }) {
    return ThreadMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      type: type ?? this.type,
      seenBy: seenBy ?? this.seenBy,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      attachmentData: attachmentData ?? this.attachmentData,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'type': type.name,
      'seenBy': seenBy,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyToMessageId': replyToMessageId,
      'attachmentData': attachmentData,
    };
  }

  /// Create from JSON
  factory ThreadMessage.fromJson(Map<String, dynamic> json) {
    return ThreadMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
      type: ThreadMessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ThreadMessageType.text,
      ),
      seenBy: List<String>.from(json['seenBy'] as List? ?? []),
      reactions: (json['reactions'] as List<dynamic>? ?? [])
          .map((r) => ThreadMessageReaction.fromJson(r as Map<String, dynamic>))
          .toList(),
      replyToMessageId: json['replyToMessageId'] as String?,
      attachmentData: json['attachmentData'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreadMessage &&
        other.id == id &&
        other.senderId == senderId &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.isEdited == isEdited &&
        other.editedAt == editedAt &&
        other.type == type &&
        listEquals(other.seenBy, seenBy) &&
        listEquals(other.reactions, reactions) &&
        other.replyToMessageId == replyToMessageId &&
        mapEquals(other.attachmentData, attachmentData);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      senderId,
      content,
      timestamp,
      isEdited,
      editedAt,
      type,
      Object.hashAll(seenBy),
      Object.hashAll(reactions),
      replyToMessageId,
      Object.hashAll(attachmentData?.entries ?? []),
    );
  }

  @override
  String toString() {
    return 'ThreadMessage(id: $id, senderId: $senderId, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, type: $type)';
  }
}

/// Type of thread message
enum ThreadMessageType {
  /// Regular text message
  text,

  /// System message (participant joined, left, etc.)
  system,

  /// Image attachment
  image,

  /// File attachment
  file,

  /// Link preview
  link,
}

/// Represents a reaction to a thread message
@immutable
class ThreadMessageReaction {
  /// Emoji used for the reaction
  final String emoji;

  /// ID of the participant who reacted
  final String participantId;

  /// Timestamp when the reaction was added
  final DateTime timestamp;

  const ThreadMessageReaction({
    required this.emoji,
    required this.participantId,
    required this.timestamp,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'participantId': participantId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ThreadMessageReaction.fromJson(Map<String, dynamic> json) {
    return ThreadMessageReaction(
      emoji: json['emoji'] as String,
      participantId: json['participantId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreadMessageReaction &&
        other.emoji == emoji &&
        other.participantId == participantId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(emoji, participantId, timestamp);
  }

  @override
  String toString() {
    return 'ThreadMessageReaction(emoji: $emoji, participantId: $participantId)';
  }
}

/// Status of a thread
enum ThreadStatus {
  /// Thread is active and accepting new messages
  active,

  /// Thread has been archived
  archived,

  /// Thread has been closed/locked
  closed,

  /// Thread has been deleted
  deleted,
}

/// Priority level of a thread
enum ThreadPriority {
  /// Low priority thread
  low,

  /// Normal priority thread (default)
  normal,

  /// High priority thread
  high,

  /// Urgent thread requiring immediate attention
  urgent,
}

/// Represents a complete thread conversation
@immutable
class Thread {
  /// Unique identifier for this thread
  final String id;

  /// ID of the original message that started this thread
  final String originalMessageId;

  /// Title or subject of the thread
  final String title;

  /// Optional description or summary
  final String? description;

  /// Current status of the thread
  final ThreadStatus status;

  /// Priority level of the thread
  final ThreadPriority priority;

  /// List of participants in this thread
  final List<ThreadParticipant> participants;

  /// List of messages in chronological order
  final List<ThreadMessage> messages;

  /// Timestamp when the thread was created
  final DateTime createdAt;

  /// Timestamp of the last activity in the thread
  final DateTime lastActivityAt;

  /// ID of the participant who created the thread
  final String createdBy;

  /// Whether the thread is pinned
  final bool isPinned;

  /// Tags associated with the thread
  final List<String> tags;

  /// Custom metadata for the thread
  final Map<String, dynamic>? metadata;

  /// Thread settings and configuration
  final ThreadSettings settings;

  const Thread({
    required this.id,
    required this.originalMessageId,
    required this.title,
    this.description,
    this.status = ThreadStatus.active,
    this.priority = ThreadPriority.normal,
    this.participants = const [],
    this.messages = const [],
    required this.createdAt,
    required this.lastActivityAt,
    required this.createdBy,
    this.isPinned = false,
    this.tags = const [],
    this.metadata,
    this.settings = const ThreadSettings(),
  });

  /// Whether the thread is currently active
  bool get isActive => status == ThreadStatus.active;

  /// Whether the thread is archived
  bool get isArchived => status == ThreadStatus.archived;

  /// Whether the thread is closed
  bool get isClosed => status == ThreadStatus.closed;

  /// Total number of messages in the thread
  int get messageCount => messages.length;

  /// Number of active participants
  int get activeParticipantCount =>
      participants.where((p) => p.isActive).length;

  /// Get the creator participant
  ThreadParticipant? get creator {
    return participants.where((p) => p.id == createdBy).firstOrNull;
  }

  /// Get the latest message
  ThreadMessage? get latestMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// Get unread message count for a specific participant
  int getUnreadMessageCount(String participantId) {
    final participant = participants
        .where((p) => p.id == participantId)
        .firstOrNull;
    if (participant == null || participant.lastSeenAt == null) {
      return messages.length;
    }

    return messages
        .where((m) => m.timestamp.isAfter(participant.lastSeenAt!))
        .length;
  }

  /// Whether a participant is currently typing
  bool isParticipantTyping(String participantId) {
    return participants.any((p) => p.id == participantId && p.isTyping);
  }

  /// Get list of participants currently typing
  List<ThreadParticipant> get typingParticipants {
    return participants.where((p) => p.isTyping).toList();
  }

  /// Create a copy with updated properties
  Thread copyWith({
    String? id,
    String? originalMessageId,
    String? title,
    String? description,
    ThreadStatus? status,
    ThreadPriority? priority,
    List<ThreadParticipant>? participants,
    List<ThreadMessage>? messages,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? createdBy,
    bool? isPinned,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    ThreadSettings? settings,
  }) {
    return Thread(
      id: id ?? this.id,
      originalMessageId: originalMessageId ?? this.originalMessageId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdBy: createdBy ?? this.createdBy,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalMessageId': originalMessageId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'participants': participants.map((p) => p.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'createdBy': createdBy,
      'isPinned': isPinned,
      'tags': tags,
      'metadata': metadata,
      'settings': settings.toJson(),
    };
  }

  /// Create from JSON
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as String,
      originalMessageId: json['originalMessageId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: ThreadStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ThreadStatus.active,
      ),
      priority: ThreadPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => ThreadPriority.normal,
      ),
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((p) => ThreadParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => ThreadMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      createdBy: json['createdBy'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      settings: json['settings'] != null
          ? ThreadSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : const ThreadSettings(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Thread &&
        other.id == id &&
        other.originalMessageId == originalMessageId &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.priority == priority &&
        listEquals(other.participants, participants) &&
        listEquals(other.messages, messages) &&
        other.createdAt == createdAt &&
        other.lastActivityAt == lastActivityAt &&
        other.createdBy == createdBy &&
        other.isPinned == isPinned &&
        listEquals(other.tags, tags) &&
        mapEquals(other.metadata, metadata) &&
        other.settings == settings;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      originalMessageId,
      title,
      description,
      status,
      priority,
      Object.hashAll(participants),
      Object.hashAll(messages),
      createdAt,
      lastActivityAt,
      createdBy,
      isPinned,
      Object.hashAll(tags),
      Object.hashAll(metadata?.entries ?? []),
      settings,
    ]);
  }

  @override
  String toString() {
    return 'Thread(id: $id, title: $title, status: $status, messageCount: $messageCount, participantCount: ${participants.length})';
  }
}

/// Settings and configuration for a thread
@immutable
class ThreadSettings {
  /// Whether notifications are enabled for this thread
  final bool notificationsEnabled;

  /// Whether only moderators can post messages
  final bool moderatorsOnly;

  /// Whether participants can react to messages
  final bool reactionsEnabled;

  /// Whether participants can edit their messages
  final bool editingEnabled;

  /// Whether participants can delete their messages
  final bool deletingEnabled;

  /// Whether the thread allows file attachments
  final bool attachmentsEnabled;

  /// Maximum number of participants allowed
  final int? maxParticipants;

  /// Auto-archive duration in days (null = never)
  final int? autoArchiveDays;

  const ThreadSettings({
    this.notificationsEnabled = true,
    this.moderatorsOnly = false,
    this.reactionsEnabled = true,
    this.editingEnabled = true,
    this.deletingEnabled = false,
    this.attachmentsEnabled = true,
    this.maxParticipants,
    this.autoArchiveDays,
  });

  /// Create a copy with updated properties
  ThreadSettings copyWith({
    bool? notificationsEnabled,
    bool? moderatorsOnly,
    bool? reactionsEnabled,
    bool? editingEnabled,
    bool? deletingEnabled,
    bool? attachmentsEnabled,
    int? maxParticipants,
    int? autoArchiveDays,
  }) {
    return ThreadSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      moderatorsOnly: moderatorsOnly ?? this.moderatorsOnly,
      reactionsEnabled: reactionsEnabled ?? this.reactionsEnabled,
      editingEnabled: editingEnabled ?? this.editingEnabled,
      deletingEnabled: deletingEnabled ?? this.deletingEnabled,
      attachmentsEnabled: attachmentsEnabled ?? this.attachmentsEnabled,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      autoArchiveDays: autoArchiveDays ?? this.autoArchiveDays,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'moderatorsOnly': moderatorsOnly,
      'reactionsEnabled': reactionsEnabled,
      'editingEnabled': editingEnabled,
      'deletingEnabled': deletingEnabled,
      'attachmentsEnabled': attachmentsEnabled,
      'maxParticipants': maxParticipants,
      'autoArchiveDays': autoArchiveDays,
    };
  }

  /// Create from JSON
  factory ThreadSettings.fromJson(Map<String, dynamic> json) {
    return ThreadSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      moderatorsOnly: json['moderatorsOnly'] as bool? ?? false,
      reactionsEnabled: json['reactionsEnabled'] as bool? ?? true,
      editingEnabled: json['editingEnabled'] as bool? ?? true,
      deletingEnabled: json['deletingEnabled'] as bool? ?? false,
      attachmentsEnabled: json['attachmentsEnabled'] as bool? ?? true,
      maxParticipants: json['maxParticipants'] as int?,
      autoArchiveDays: json['autoArchiveDays'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreadSettings &&
        other.notificationsEnabled == notificationsEnabled &&
        other.moderatorsOnly == moderatorsOnly &&
        other.reactionsEnabled == reactionsEnabled &&
        other.editingEnabled == editingEnabled &&
        other.deletingEnabled == deletingEnabled &&
        other.attachmentsEnabled == attachmentsEnabled &&
        other.maxParticipants == maxParticipants &&
        other.autoArchiveDays == autoArchiveDays;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      moderatorsOnly,
      reactionsEnabled,
      editingEnabled,
      deletingEnabled,
      attachmentsEnabled,
      maxParticipants,
      autoArchiveDays,
    );
  }

  @override
  String toString() {
    return 'ThreadSettings(notificationsEnabled: $notificationsEnabled, moderatorsOnly: $moderatorsOnly, reactionsEnabled: $reactionsEnabled)';
  }
}
