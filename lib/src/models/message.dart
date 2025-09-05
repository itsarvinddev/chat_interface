import 'package:chatui/chatui.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screwdriver/screwdriver.dart';

part 'message.mapper.dart';

@MappableClass()
class ChatMessage with ChatMessageMappable {
  String id = "";
  String message = "";
  ChatAttachment? attachment;
  ChatMessageType type = ChatMessageType.chat;
  ChatMessageStatus chatStatus = ChatMessageStatus.pending;
  ChatImageType imageType = ChatImageType.network;
  List<ChatReaction> reactions = [];
  ChatReplyMessage? replyMessage;
  String senderId = "";
  String roomId = "";
  @MappableField(hook: DurationMillisHook())
  Duration duration = Duration.zero; // for audio and video messages
  Map<String, dynamic> metadata = {};
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? editedAt;
  String status = "";

  /// Key for accessing the widget's render box.
  final GlobalKey key = GlobalKey();

  /// Provides sender of the message.
  ChatUser? sender;

  Object? _room;

  void setRoom(Object? room) {
    _room = room;
  }

  Object? getRoom() {
    return _room;
  }

  T? getRoomAs<T>() => _room is T ? _room as T : null;

  Object? _metadata;

  void setMetadata(Object? metadata) {
    _metadata = metadata;
  }

  Object? getMetadata() {
    return _metadata;
  }

  T? getMetadataAs<T>() => _metadata is T ? _metadata as T : null;

  ChatMessage({
    this.id = "",
    this.message = "",
    this.attachment,
    this.type = ChatMessageType.chat,
    this.chatStatus = ChatMessageStatus.pending,
    this.imageType = ChatImageType.network,
    this.reactions = const [],
    this.replyMessage,
    this.senderId = "",
    this.roomId = "",
    this.duration = Duration.zero,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.editedAt,
    this.status = "",
  }) : sender = ChatUser(id: senderId);

  bool get isReactionsEmpty => reactions.isNullOrEmpty;

  bool get isReplyMessageEmpty => replyMessage?.isEmpty ?? true;

  List<String> get reactedUserIds => reactions.map((e) => e.userId).toList();

  List<String> get reactedEmojis => reactions.map((e) => e.reaction).toList();
}

@MappableClass()
class ChatReaction with ChatReactionMappable {
  String id = "";
  String messageId = "";
  String userId = "";
  String reaction = "";

  ChatReaction({
    this.id = "",
    this.messageId = "",
    this.userId = "",
    this.reaction = "",
  });
}

@MappableClass()
class ChatReplyMessage with ChatReplyMessageMappable {
  String id = "";
  String messageId = "";
  String replyTo = "";
  String replyBy = "";
  String message = "";
  ChatMessageType type = ChatMessageType.chat;
  @MappableField(hook: DurationMillisHook())
  Duration duration = Duration.zero;

  ChatReplyMessage({
    this.id = "",
    this.messageId = "",
    this.replyTo = "",
    this.replyBy = "",
    this.message = "",
    this.type = ChatMessageType.chat,
    this.duration = Duration.zero,
  });

  bool get isEmpty =>
      messageId.isNullOrEmpty &&
      message.isNullOrEmpty &&
      replyTo.isNullOrEmpty &&
      replyBy.isNullOrEmpty;
}

@MappableClass()
class ChatAttachment with ChatAttachmentMappable {
  final String fileName;
  final ChatAttachmentType type;
  final double? width;
  final double? height;
  UploadStatus uploadStatus;
  bool autoDownload;
  String fileExtension;
  int fileSize;
  String url;
  @MappableField(hook: XFileHook())
  XFile? file;
  List<double>? samples;

  ChatAttachment({
    required this.fileName,
    required this.type,
    this.width,
    this.height,
    this.uploadStatus = UploadStatus.notUploading,
    this.autoDownload = true,
    this.fileExtension = "",
    this.fileSize = 0,
    this.url = "",
    this.file,
    this.samples,
  });
}
