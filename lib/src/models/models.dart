// Core backend-agnostic chat models (minimal scaffolding)

enum MessageKind {
  text,
  image,
  video,
  file,
  audio,
  location,
  contact,
  poll,
  system,
}

class ChatUserId {
  final String value;
  const ChatUserId(this.value);
  @override
  String toString() => value;
}

class MessageId {
  final String value;
  const MessageId(this.value);
  @override
  String toString() => value;
}

class ThreadId {
  final String value;
  const ThreadId(this.value);
  @override
  String toString() => value;
}

class ChannelId {
  final String value;
  const ChannelId(this.value);
  @override
  String toString() => value;
}

class ChatUser {
  final ChatUserId id;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;

  const ChatUser({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });
}

class ReactionSummary {
  final String key; // e.g. '👍'
  final Set<ChatUserId> by;
  const ReactionSummary({required this.key, required this.by});
}

class Attachment {
  final String uri;
  final String mimeType;
  final int? sizeBytes;
  final String? thumbnailUri;

  const Attachment({
    required this.uri,
    required this.mimeType,
    this.sizeBytes,
    this.thumbnailUri,
  });
}

class LocationAttachment {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? address;

  const LocationAttachment({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.address,
  });

  /// Convert to regular Attachment for compatibility
  Attachment toAttachment() {
    return Attachment(
      uri: 'geo:$latitude,$longitude',
      mimeType: 'application/geo',
      sizeBytes: null,
      thumbnailUri: null,
    );
  }

  /// Get coordinates as formatted string
  String get coordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

class Message {
  final MessageId id;
  final ChatUser author;
  final MessageKind kind;
  final String? text;
  final List<Attachment> attachments;
  final LocationAttachment? location;
  final PollSummary? poll;
  final DateTime createdAt;
  final DateTime? editedAt;
  final MessageId? replyTo;
  final bool isPinned;
  final Map<String, ReactionSummary> reactions;
  final List<MessageEdit> editHistory;

  const Message({
    required this.id,
    required this.author,
    this.kind = MessageKind.text,
    this.text,
    this.attachments = const [],
    this.location,
    this.poll,
    required this.createdAt,
    this.editedAt,
    this.replyTo,
    this.isPinned = false,
    this.reactions = const <String, ReactionSummary>{},
    this.editHistory = const [],
  });
}

/// Represents a single edit to a message
class MessageEdit {
  final String previousText;
  final DateTime editedAt;
  final ChatUser editedBy;

  const MessageEdit({
    required this.previousText,
    required this.editedAt,
    required this.editedBy,
  });
}

class TypingUser {
  final ChatUser user;
  final DateTime startedAt;
  final DateTime lastActivity;

  const TypingUser({
    required this.user,
    required this.startedAt,
    required this.lastActivity,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.difference(lastActivity).inSeconds < 10;
  }
}

class TypingState {
  final Set<TypingUser> typingUsers;
  final DateTime lastUpdated;

  const TypingState({this.typingUsers = const {}, required this.lastUpdated});

  bool get hasTypingUsers => typingUsers.isNotEmpty;

  List<TypingUser> get activeTypingUsers =>
      typingUsers.where((user) => user.isActive).toList();
}

class PollOption {
  final String id;
  final String text;
  final int voteCount;
  final Set<ChatUserId> votedBy;

  const PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.votedBy = const {},
  });

  PollOption copyWith({
    String? id,
    String? text,
    int? voteCount,
    Set<ChatUserId>? votedBy,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
      votedBy: votedBy ?? this.votedBy,
    );
  }
}

class PollVote {
  final ChatUserId userId;
  final String optionId;
  final DateTime votedAt;

  const PollVote({
    required this.userId,
    required this.optionId,
    required this.votedAt,
  });
}

class PollSummary {
  final String question;
  final List<PollOption> options;
  final int totalVotes;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isMultipleChoice;
  final bool isAnonymous;

  const PollSummary({
    required this.question,
    required this.options,
    this.totalVotes = 0,
    required this.createdAt,
    this.expiresAt,
    this.isMultipleChoice = false,
    this.isAnonymous = false,
  });

  PollSummary copyWith({
    String? question,
    List<PollOption>? options,
    int? totalVotes,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isMultipleChoice,
    bool? isAnonymous,
  }) {
    return PollSummary(
      question: question ?? this.question,
      options: options ?? this.options,
      totalVotes: totalVotes ?? this.totalVotes,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// Get the percentage for a specific option
  double getOptionPercentage(String optionId) {
    if (totalVotes == 0) return 0.0;
    final option = options.firstWhere((opt) => opt.id == optionId);
    return (option.voteCount / totalVotes) * 100;
  }

  /// Check if a user has voted on this poll
  bool hasUserVoted(ChatUserId userId) {
    return options.any((option) => option.votedBy.contains(userId));
  }

  /// Get the options that a user has voted for
  List<String> getUserVotes(ChatUserId userId) {
    return options
        .where((option) => option.votedBy.contains(userId))
        .map((option) => option.id)
        .toList();
  }
}

enum ChannelKind { direct, group, broadcast }

class Channel {
  final ChannelId id;
  final ChannelKind kind;
  final String name;
  final String? imageUrl;
  final List<ChatUser> members;

  const Channel({
    required this.id,
    this.kind = ChannelKind.group,
    required this.name,
    this.imageUrl,
    this.members = const [],
  });
}
