import 'package:flutter/foundation.dart';

/// Represents a single option in a poll
@immutable
class PollOption {
  /// Unique identifier for this poll option
  final String id;

  /// Text content of the option
  final String text;

  /// Number of votes this option has received
  final int voteCount;

  /// Whether this option was voted for by the current user
  final bool isVotedByCurrentUser;

  const PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.isVotedByCurrentUser = false,
  });

  /// Create a copy with updated properties
  PollOption copyWith({
    String? id,
    String? text,
    int? voteCount,
    bool? isVotedByCurrentUser,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
      isVotedByCurrentUser: isVotedByCurrentUser ?? this.isVotedByCurrentUser,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'voteCount': voteCount,
      'isVotedByCurrentUser': isVotedByCurrentUser,
    };
  }

  /// Create from JSON
  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: json['voteCount'] as int? ?? 0,
      isVotedByCurrentUser: json['isVotedByCurrentUser'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PollOption &&
        other.id == id &&
        other.text == text &&
        other.voteCount == voteCount &&
        other.isVotedByCurrentUser == isVotedByCurrentUser;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, voteCount, isVotedByCurrentUser);
  }

  @override
  String toString() {
    return 'PollOption(id: $id, text: $text, voteCount: $voteCount, isVotedByCurrentUser: $isVotedByCurrentUser)';
  }
}

/// Represents a single vote in a poll
@immutable
class PollVote {
  /// Unique identifier for this vote
  final String id;

  /// ID of the user who cast this vote
  final String userId;

  /// ID of the poll option that was voted for
  final String optionId;

  /// Timestamp when the vote was cast
  final DateTime timestamp;

  /// Optional user name for display purposes
  final String? userName;

  const PollVote({
    required this.id,
    required this.userId,
    required this.optionId,
    required this.timestamp,
    this.userName,
  });

  /// Create a copy with updated properties
  PollVote copyWith({
    String? id,
    String? userId,
    String? optionId,
    DateTime? timestamp,
    String? userName,
  }) {
    return PollVote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      optionId: optionId ?? this.optionId,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'optionId': optionId,
      'timestamp': timestamp.toIso8601String(),
      'userName': userName,
    };
  }

  /// Create from JSON
  factory PollVote.fromJson(Map<String, dynamic> json) {
    return PollVote(
      id: json['id'] as String,
      userId: json['userId'] as String,
      optionId: json['optionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userName: json['userName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PollVote &&
        other.id == id &&
        other.userId == userId &&
        other.optionId == optionId &&
        other.timestamp == timestamp &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, optionId, timestamp, userName);
  }

  @override
  String toString() {
    return 'PollVote(id: $id, userId: $userId, optionId: $optionId, timestamp: $timestamp, userName: $userName)';
  }
}

/// Poll type enumeration
enum PollType {
  /// Single choice poll (radio buttons)
  singleChoice,

  /// Multiple choice poll (checkboxes)
  multipleChoice,
}

/// Poll status enumeration
enum PollStatus {
  /// Poll is active and accepting votes
  active,

  /// Poll has ended (by deadline or manual closure)
  ended,

  /// Poll has been cancelled
  cancelled,
}

/// Represents a complete poll with options, votes, and metadata
@immutable
class Poll {
  /// Unique identifier for this poll
  final String id;

  /// Question or title of the poll
  final String question;

  /// List of available options to vote on
  final List<PollOption> options;

  /// Type of poll (single or multiple choice)
  final PollType type;

  /// Current status of the poll
  final PollStatus status;

  /// Whether voting is anonymous
  final bool isAnonymous;

  /// Maximum number of options a user can select (for multiple choice)
  final int? maxSelections;

  /// Optional deadline for the poll
  final DateTime? deadline;

  /// Timestamp when the poll was created
  final DateTime createdAt;

  /// ID of the user who created the poll
  final String createdBy;

  /// Optional creator name for display
  final String? creatorName;

  /// Total number of participants who have voted
  final int totalVoters;

  /// List of all votes (only available if not anonymous)
  final List<PollVote> votes;

  const Poll({
    required this.id,
    required this.question,
    required this.options,
    this.type = PollType.singleChoice,
    this.status = PollStatus.active,
    this.isAnonymous = false,
    this.maxSelections,
    this.deadline,
    required this.createdAt,
    required this.createdBy,
    this.creatorName,
    this.totalVoters = 0,
    this.votes = const [],
  });

  /// Whether the poll has ended (by deadline or status)
  bool get hasEnded {
    if (status != PollStatus.active) return true;
    if (deadline != null && DateTime.now().isAfter(deadline!)) return true;
    return false;
  }

  /// Whether the poll allows multiple selections
  bool get allowsMultipleSelections => type == PollType.multipleChoice;

  /// Total number of votes cast across all options
  int get totalVotes =>
      options.fold(0, (sum, option) => sum + option.voteCount);

  /// Whether the current user has voted in this poll
  bool get hasCurrentUserVoted =>
      options.any((option) => option.isVotedByCurrentUser);

  /// Get the winning option(s) (most votes)
  List<PollOption> get winningOptions {
    if (options.isEmpty) return [];

    final maxVotes = options
        .map((o) => o.voteCount)
        .reduce((a, b) => a > b ? a : b);
    return options.where((option) => option.voteCount == maxVotes).toList();
  }

  /// Get options voted by current user
  List<PollOption> get currentUserVotes {
    return options.where((option) => option.isVotedByCurrentUser).toList();
  }

  /// Create a copy with updated properties
  Poll copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    PollType? type,
    PollStatus? status,
    bool? isAnonymous,
    int? maxSelections,
    DateTime? deadline,
    DateTime? createdAt,
    String? createdBy,
    String? creatorName,
    int? totalVoters,
    List<PollVote>? votes,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      type: type ?? this.type,
      status: status ?? this.status,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      maxSelections: maxSelections ?? this.maxSelections,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      totalVoters: totalVoters ?? this.totalVoters,
      votes: votes ?? this.votes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'type': type.name,
      'status': status.name,
      'isAnonymous': isAnonymous,
      'maxSelections': maxSelections,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'creatorName': creatorName,
      'totalVoters': totalVoters,
      'votes': votes.map((v) => v.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => PollOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      type: PollType.values.firstWhere((t) => t.name == json['type']),
      status: PollStatus.values.firstWhere((s) => s.name == json['status']),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      maxSelections: json['maxSelections'] as int?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      creatorName: json['creatorName'] as String?,
      totalVoters: json['totalVoters'] as int? ?? 0,
      votes: (json['votes'] as List<dynamic>? ?? [])
          .map((v) => PollVote.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Poll &&
        other.id == id &&
        other.question == question &&
        listEquals(other.options, options) &&
        other.type == type &&
        other.status == status &&
        other.isAnonymous == isAnonymous &&
        other.maxSelections == maxSelections &&
        other.deadline == deadline &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.creatorName == creatorName &&
        other.totalVoters == totalVoters &&
        listEquals(other.votes, votes);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      question,
      Object.hashAll(options),
      type,
      status,
      isAnonymous,
      maxSelections,
      deadline,
      createdAt,
      createdBy,
      creatorName,
      totalVoters,
      Object.hashAll(votes),
    ]);
  }

  @override
  String toString() {
    return 'Poll(id: $id, question: $question, options: ${options.length}, type: $type, status: $status, totalVotes: $totalVotes)';
  }
}
