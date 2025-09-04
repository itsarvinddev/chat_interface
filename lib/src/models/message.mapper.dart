// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'message.dart';

class ChatMessageMapper extends ClassMapperBase<ChatMessage> {
  ChatMessageMapper._();

  static ChatMessageMapper? _instance;
  static ChatMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatMessageMapper._());
      ChatAttachmentMapper.ensureInitialized();
      ChatMessageTypeMapper.ensureInitialized();
      ChatMessageStatusMapper.ensureInitialized();
      ChatImageTypeMapper.ensureInitialized();
      ChatReactionMapper.ensureInitialized();
      ChatReplyMessageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChatMessage';

  static String _$id(ChatMessage v) => v.id;
  static const Field<ChatMessage, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: "",
  );
  static String _$message(ChatMessage v) => v.message;
  static const Field<ChatMessage, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    def: "",
  );
  static ChatAttachment? _$attachment(ChatMessage v) => v.attachment;
  static const Field<ChatMessage, ChatAttachment> _f$attachment = Field(
    'attachment',
    _$attachment,
    opt: true,
  );
  static ChatMessageType _$type(ChatMessage v) => v.type;
  static const Field<ChatMessage, ChatMessageType> _f$type = Field(
    'type',
    _$type,
    opt: true,
    def: ChatMessageType.chat,
  );
  static ChatMessageStatus _$chatStatus(ChatMessage v) => v.chatStatus;
  static const Field<ChatMessage, ChatMessageStatus> _f$chatStatus = Field(
    'chatStatus',
    _$chatStatus,
    key: r'chat_status',
    opt: true,
    def: ChatMessageStatus.pending,
  );
  static ChatImageType _$imageType(ChatMessage v) => v.imageType;
  static const Field<ChatMessage, ChatImageType> _f$imageType = Field(
    'imageType',
    _$imageType,
    key: r'image_type',
    opt: true,
    def: ChatImageType.network,
  );
  static List<ChatReaction> _$reactions(ChatMessage v) => v.reactions;
  static const Field<ChatMessage, List<ChatReaction>> _f$reactions = Field(
    'reactions',
    _$reactions,
    opt: true,
    def: const [],
  );
  static ChatReplyMessage? _$replyMessage(ChatMessage v) => v.replyMessage;
  static const Field<ChatMessage, ChatReplyMessage> _f$replyMessage = Field(
    'replyMessage',
    _$replyMessage,
    key: r'reply_message',
    opt: true,
  );
  static String _$senderId(ChatMessage v) => v.senderId;
  static const Field<ChatMessage, String> _f$senderId = Field(
    'senderId',
    _$senderId,
    key: r'sender_id',
    opt: true,
    def: "",
  );
  static String _$roomId(ChatMessage v) => v.roomId;
  static const Field<ChatMessage, String> _f$roomId = Field(
    'roomId',
    _$roomId,
    key: r'room_id',
    opt: true,
    def: "",
  );
  static Duration _$duration(ChatMessage v) => v.duration;
  static const Field<ChatMessage, Duration> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
    def: Duration.zero,
    hook: DurationMillisHook(),
  );
  static Map<String, dynamic> _$metadata(ChatMessage v) => v.metadata;
  static const Field<ChatMessage, Map<String, dynamic>> _f$metadata = Field(
    'metadata',
    _$metadata,
    opt: true,
    def: const {},
  );
  static DateTime? _$createdAt(ChatMessage v) => v.createdAt;
  static const Field<ChatMessage, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
    opt: true,
  );
  static DateTime? _$updatedAt(ChatMessage v) => v.updatedAt;
  static const Field<ChatMessage, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static DateTime? _$editedAt(ChatMessage v) => v.editedAt;
  static const Field<ChatMessage, DateTime> _f$editedAt = Field(
    'editedAt',
    _$editedAt,
    key: r'edited_at',
    opt: true,
  );
  static String _$status(ChatMessage v) => v.status;
  static const Field<ChatMessage, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: "",
  );
  static GlobalKey<State<StatefulWidget>> _$key(ChatMessage v) => v.key;
  static const Field<ChatMessage, GlobalKey<State<StatefulWidget>>> _f$key =
      Field('key', _$key, mode: FieldMode.member);
  static ChatUser? _$sender(ChatMessage v) => v.sender;
  static const Field<ChatMessage, ChatUser> _f$sender = Field(
    'sender',
    _$sender,
    mode: FieldMode.member,
  );
  static bool _$isReactionsEmpty(ChatMessage v) => v.isReactionsEmpty;
  static const Field<ChatMessage, bool> _f$isReactionsEmpty = Field(
    'isReactionsEmpty',
    _$isReactionsEmpty,
    mode: FieldMode.member,
  );
  static bool _$isReplyMessageEmpty(ChatMessage v) => v.isReplyMessageEmpty;
  static const Field<ChatMessage, bool> _f$isReplyMessageEmpty = Field(
    'isReplyMessageEmpty',
    _$isReplyMessageEmpty,
    mode: FieldMode.member,
  );
  static List<String> _$reactedUserIds(ChatMessage v) => v.reactedUserIds;
  static const Field<ChatMessage, List<String>> _f$reactedUserIds = Field(
    'reactedUserIds',
    _$reactedUserIds,
    mode: FieldMode.member,
  );
  static List<String> _$reactedEmojis(ChatMessage v) => v.reactedEmojis;
  static const Field<ChatMessage, List<String>> _f$reactedEmojis = Field(
    'reactedEmojis',
    _$reactedEmojis,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ChatMessage> fields = const {
    #id: _f$id,
    #message: _f$message,
    #attachment: _f$attachment,
    #type: _f$type,
    #chatStatus: _f$chatStatus,
    #imageType: _f$imageType,
    #reactions: _f$reactions,
    #replyMessage: _f$replyMessage,
    #senderId: _f$senderId,
    #roomId: _f$roomId,
    #duration: _f$duration,
    #metadata: _f$metadata,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #editedAt: _f$editedAt,
    #status: _f$status,
    #key: _f$key,
    #sender: _f$sender,
    #isReactionsEmpty: _f$isReactionsEmpty,
    #isReplyMessageEmpty: _f$isReplyMessageEmpty,
    #reactedUserIds: _f$reactedUserIds,
    #reactedEmojis: _f$reactedEmojis,
  };

  static ChatMessage _instantiate(DecodingData data) {
    return ChatMessage(
      id: data.dec(_f$id),
      message: data.dec(_f$message),
      attachment: data.dec(_f$attachment),
      type: data.dec(_f$type),
      chatStatus: data.dec(_f$chatStatus),
      imageType: data.dec(_f$imageType),
      reactions: data.dec(_f$reactions),
      replyMessage: data.dec(_f$replyMessage),
      senderId: data.dec(_f$senderId),
      roomId: data.dec(_f$roomId),
      duration: data.dec(_f$duration),
      metadata: data.dec(_f$metadata),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      editedAt: data.dec(_f$editedAt),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatMessage>(map);
  }

  static ChatMessage fromJson(String json) {
    return ensureInitialized().decodeJson<ChatMessage>(json);
  }
}

mixin ChatMessageMappable {
  String toJson() {
    return ChatMessageMapper.ensureInitialized().encodeJson<ChatMessage>(
      this as ChatMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return ChatMessageMapper.ensureInitialized().encodeMap<ChatMessage>(
      this as ChatMessage,
    );
  }

  ChatMessageCopyWith<ChatMessage, ChatMessage, ChatMessage> get copyWith =>
      _ChatMessageCopyWithImpl<ChatMessage, ChatMessage>(
        this as ChatMessage,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatMessageMapper.ensureInitialized().stringifyValue(
      this as ChatMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatMessageMapper.ensureInitialized().equalsValue(
      this as ChatMessage,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatMessageMapper.ensureInitialized().hashValue(this as ChatMessage);
  }
}

extension ChatMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatMessage, $Out> {
  ChatMessageCopyWith<$R, ChatMessage, $Out> get $asChatMessage =>
      $base.as((v, t, t2) => _ChatMessageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatMessageCopyWith<$R, $In extends ChatMessage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ChatAttachmentCopyWith<$R, ChatAttachment, ChatAttachment>? get attachment;
  ListCopyWith<
    $R,
    ChatReaction,
    ChatReactionCopyWith<$R, ChatReaction, ChatReaction>
  >
  get reactions;
  ChatReplyMessageCopyWith<$R, ChatReplyMessage, ChatReplyMessage>?
  get replyMessage;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get metadata;
  $R call({
    String? id,
    String? message,
    ChatAttachment? attachment,
    ChatMessageType? type,
    ChatMessageStatus? chatStatus,
    ChatImageType? imageType,
    List<ChatReaction>? reactions,
    ChatReplyMessage? replyMessage,
    String? senderId,
    String? roomId,
    Duration? duration,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? editedAt,
    String? status,
  });
  ChatMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChatMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatMessage, $Out>
    implements ChatMessageCopyWith<$R, ChatMessage, $Out> {
  _ChatMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatMessage> $mapper =
      ChatMessageMapper.ensureInitialized();
  @override
  ChatAttachmentCopyWith<$R, ChatAttachment, ChatAttachment>? get attachment =>
      $value.attachment?.copyWith.$chain((v) => call(attachment: v));
  @override
  ListCopyWith<
    $R,
    ChatReaction,
    ChatReactionCopyWith<$R, ChatReaction, ChatReaction>
  >
  get reactions => ListCopyWith(
    $value.reactions,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(reactions: v),
  );
  @override
  ChatReplyMessageCopyWith<$R, ChatReplyMessage, ChatReplyMessage>?
  get replyMessage =>
      $value.replyMessage?.copyWith.$chain((v) => call(replyMessage: v));
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get metadata => MapCopyWith(
    $value.metadata,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(metadata: v),
  );
  @override
  $R call({
    String? id,
    String? message,
    Object? attachment = $none,
    ChatMessageType? type,
    ChatMessageStatus? chatStatus,
    ChatImageType? imageType,
    List<ChatReaction>? reactions,
    Object? replyMessage = $none,
    String? senderId,
    String? roomId,
    Duration? duration,
    Map<String, dynamic>? metadata,
    Object? createdAt = $none,
    Object? updatedAt = $none,
    Object? editedAt = $none,
    String? status,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (message != null) #message: message,
      if (attachment != $none) #attachment: attachment,
      if (type != null) #type: type,
      if (chatStatus != null) #chatStatus: chatStatus,
      if (imageType != null) #imageType: imageType,
      if (reactions != null) #reactions: reactions,
      if (replyMessage != $none) #replyMessage: replyMessage,
      if (senderId != null) #senderId: senderId,
      if (roomId != null) #roomId: roomId,
      if (duration != null) #duration: duration,
      if (metadata != null) #metadata: metadata,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (editedAt != $none) #editedAt: editedAt,
      if (status != null) #status: status,
    }),
  );
  @override
  ChatMessage $make(CopyWithData data) => ChatMessage(
    id: data.get(#id, or: $value.id),
    message: data.get(#message, or: $value.message),
    attachment: data.get(#attachment, or: $value.attachment),
    type: data.get(#type, or: $value.type),
    chatStatus: data.get(#chatStatus, or: $value.chatStatus),
    imageType: data.get(#imageType, or: $value.imageType),
    reactions: data.get(#reactions, or: $value.reactions),
    replyMessage: data.get(#replyMessage, or: $value.replyMessage),
    senderId: data.get(#senderId, or: $value.senderId),
    roomId: data.get(#roomId, or: $value.roomId),
    duration: data.get(#duration, or: $value.duration),
    metadata: data.get(#metadata, or: $value.metadata),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    editedAt: data.get(#editedAt, or: $value.editedAt),
    status: data.get(#status, or: $value.status),
  );

  @override
  ChatMessageCopyWith<$R2, ChatMessage, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ChatAttachmentMapper extends ClassMapperBase<ChatAttachment> {
  ChatAttachmentMapper._();

  static ChatAttachmentMapper? _instance;
  static ChatAttachmentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatAttachmentMapper._());
      ChatAttachmentTypeMapper.ensureInitialized();
      UploadStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChatAttachment';

  static String _$fileName(ChatAttachment v) => v.fileName;
  static const Field<ChatAttachment, String> _f$fileName = Field(
    'fileName',
    _$fileName,
  );
  static ChatAttachmentType _$type(ChatAttachment v) => v.type;
  static const Field<ChatAttachment, ChatAttachmentType> _f$type = Field(
    'type',
    _$type,
  );
  static double? _$width(ChatAttachment v) => v.width;
  static const Field<ChatAttachment, double> _f$width = Field(
    'width',
    _$width,
    opt: true,
  );
  static double? _$height(ChatAttachment v) => v.height;
  static const Field<ChatAttachment, double> _f$height = Field(
    'height',
    _$height,
    opt: true,
  );
  static UploadStatus _$uploadStatus(ChatAttachment v) => v.uploadStatus;
  static const Field<ChatAttachment, UploadStatus> _f$uploadStatus = Field(
    'uploadStatus',
    _$uploadStatus,
    opt: true,
    def: UploadStatus.notUploading,
  );
  static bool _$autoDownload(ChatAttachment v) => v.autoDownload;
  static const Field<ChatAttachment, bool> _f$autoDownload = Field(
    'autoDownload',
    _$autoDownload,
    opt: true,
    def: true,
  );
  static String _$fileExtension(ChatAttachment v) => v.fileExtension;
  static const Field<ChatAttachment, String> _f$fileExtension = Field(
    'fileExtension',
    _$fileExtension,
    opt: true,
    def: "",
  );
  static int _$fileSize(ChatAttachment v) => v.fileSize;
  static const Field<ChatAttachment, int> _f$fileSize = Field(
    'fileSize',
    _$fileSize,
    opt: true,
    def: 0,
  );
  static String _$url(ChatAttachment v) => v.url;
  static const Field<ChatAttachment, String> _f$url = Field(
    'url',
    _$url,
    opt: true,
    def: "",
  );
  static XFile? _$file(ChatAttachment v) => v.file;
  static const Field<ChatAttachment, XFile> _f$file = Field(
    'file',
    _$file,
    opt: true,
    hook: XFileHook(),
  );
  static List<double>? _$samples(ChatAttachment v) => v.samples;
  static const Field<ChatAttachment, List<double>> _f$samples = Field(
    'samples',
    _$samples,
    opt: true,
  );

  @override
  final MappableFields<ChatAttachment> fields = const {
    #fileName: _f$fileName,
    #type: _f$type,
    #width: _f$width,
    #height: _f$height,
    #uploadStatus: _f$uploadStatus,
    #autoDownload: _f$autoDownload,
    #fileExtension: _f$fileExtension,
    #fileSize: _f$fileSize,
    #url: _f$url,
    #file: _f$file,
    #samples: _f$samples,
  };

  static ChatAttachment _instantiate(DecodingData data) {
    return ChatAttachment(
      fileName: data.dec(_f$fileName),
      type: data.dec(_f$type),
      width: data.dec(_f$width),
      height: data.dec(_f$height),
      uploadStatus: data.dec(_f$uploadStatus),
      autoDownload: data.dec(_f$autoDownload),
      fileExtension: data.dec(_f$fileExtension),
      fileSize: data.dec(_f$fileSize),
      url: data.dec(_f$url),
      file: data.dec(_f$file),
      samples: data.dec(_f$samples),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatAttachment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatAttachment>(map);
  }

  static ChatAttachment fromJson(String json) {
    return ensureInitialized().decodeJson<ChatAttachment>(json);
  }
}

mixin ChatAttachmentMappable {
  String toJson() {
    return ChatAttachmentMapper.ensureInitialized().encodeJson<ChatAttachment>(
      this as ChatAttachment,
    );
  }

  Map<String, dynamic> toMap() {
    return ChatAttachmentMapper.ensureInitialized().encodeMap<ChatAttachment>(
      this as ChatAttachment,
    );
  }

  ChatAttachmentCopyWith<ChatAttachment, ChatAttachment, ChatAttachment>
  get copyWith => _ChatAttachmentCopyWithImpl<ChatAttachment, ChatAttachment>(
    this as ChatAttachment,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ChatAttachmentMapper.ensureInitialized().stringifyValue(
      this as ChatAttachment,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatAttachmentMapper.ensureInitialized().equalsValue(
      this as ChatAttachment,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatAttachmentMapper.ensureInitialized().hashValue(
      this as ChatAttachment,
    );
  }
}

extension ChatAttachmentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatAttachment, $Out> {
  ChatAttachmentCopyWith<$R, ChatAttachment, $Out> get $asChatAttachment =>
      $base.as((v, t, t2) => _ChatAttachmentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatAttachmentCopyWith<$R, $In extends ChatAttachment, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, double, ObjectCopyWith<$R, double, double>>? get samples;
  $R call({
    String? fileName,
    ChatAttachmentType? type,
    double? width,
    double? height,
    UploadStatus? uploadStatus,
    bool? autoDownload,
    String? fileExtension,
    int? fileSize,
    String? url,
    XFile? file,
    List<double>? samples,
  });
  ChatAttachmentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ChatAttachmentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatAttachment, $Out>
    implements ChatAttachmentCopyWith<$R, ChatAttachment, $Out> {
  _ChatAttachmentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatAttachment> $mapper =
      ChatAttachmentMapper.ensureInitialized();
  @override
  ListCopyWith<$R, double, ObjectCopyWith<$R, double, double>>? get samples =>
      $value.samples != null
      ? ListCopyWith(
          $value.samples!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(samples: v),
        )
      : null;
  @override
  $R call({
    String? fileName,
    ChatAttachmentType? type,
    Object? width = $none,
    Object? height = $none,
    UploadStatus? uploadStatus,
    bool? autoDownload,
    String? fileExtension,
    int? fileSize,
    String? url,
    Object? file = $none,
    Object? samples = $none,
  }) => $apply(
    FieldCopyWithData({
      if (fileName != null) #fileName: fileName,
      if (type != null) #type: type,
      if (width != $none) #width: width,
      if (height != $none) #height: height,
      if (uploadStatus != null) #uploadStatus: uploadStatus,
      if (autoDownload != null) #autoDownload: autoDownload,
      if (fileExtension != null) #fileExtension: fileExtension,
      if (fileSize != null) #fileSize: fileSize,
      if (url != null) #url: url,
      if (file != $none) #file: file,
      if (samples != $none) #samples: samples,
    }),
  );
  @override
  ChatAttachment $make(CopyWithData data) => ChatAttachment(
    fileName: data.get(#fileName, or: $value.fileName),
    type: data.get(#type, or: $value.type),
    width: data.get(#width, or: $value.width),
    height: data.get(#height, or: $value.height),
    uploadStatus: data.get(#uploadStatus, or: $value.uploadStatus),
    autoDownload: data.get(#autoDownload, or: $value.autoDownload),
    fileExtension: data.get(#fileExtension, or: $value.fileExtension),
    fileSize: data.get(#fileSize, or: $value.fileSize),
    url: data.get(#url, or: $value.url),
    file: data.get(#file, or: $value.file),
    samples: data.get(#samples, or: $value.samples),
  );

  @override
  ChatAttachmentCopyWith<$R2, ChatAttachment, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatAttachmentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ChatReactionMapper extends ClassMapperBase<ChatReaction> {
  ChatReactionMapper._();

  static ChatReactionMapper? _instance;
  static ChatReactionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatReactionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ChatReaction';

  static String _$id(ChatReaction v) => v.id;
  static const Field<ChatReaction, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: "",
  );
  static String _$messageId(ChatReaction v) => v.messageId;
  static const Field<ChatReaction, String> _f$messageId = Field(
    'messageId',
    _$messageId,
    opt: true,
    def: "",
  );
  static String _$userId(ChatReaction v) => v.userId;
  static const Field<ChatReaction, String> _f$userId = Field(
    'userId',
    _$userId,
    opt: true,
    def: "",
  );
  static String _$reaction(ChatReaction v) => v.reaction;
  static const Field<ChatReaction, String> _f$reaction = Field(
    'reaction',
    _$reaction,
    opt: true,
    def: "",
  );

  @override
  final MappableFields<ChatReaction> fields = const {
    #id: _f$id,
    #messageId: _f$messageId,
    #userId: _f$userId,
    #reaction: _f$reaction,
  };

  static ChatReaction _instantiate(DecodingData data) {
    return ChatReaction(
      id: data.dec(_f$id),
      messageId: data.dec(_f$messageId),
      userId: data.dec(_f$userId),
      reaction: data.dec(_f$reaction),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatReaction fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatReaction>(map);
  }

  static ChatReaction fromJson(String json) {
    return ensureInitialized().decodeJson<ChatReaction>(json);
  }
}

mixin ChatReactionMappable {
  String toJson() {
    return ChatReactionMapper.ensureInitialized().encodeJson<ChatReaction>(
      this as ChatReaction,
    );
  }

  Map<String, dynamic> toMap() {
    return ChatReactionMapper.ensureInitialized().encodeMap<ChatReaction>(
      this as ChatReaction,
    );
  }

  ChatReactionCopyWith<ChatReaction, ChatReaction, ChatReaction> get copyWith =>
      _ChatReactionCopyWithImpl<ChatReaction, ChatReaction>(
        this as ChatReaction,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatReactionMapper.ensureInitialized().stringifyValue(
      this as ChatReaction,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatReactionMapper.ensureInitialized().equalsValue(
      this as ChatReaction,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatReactionMapper.ensureInitialized().hashValue(
      this as ChatReaction,
    );
  }
}

extension ChatReactionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatReaction, $Out> {
  ChatReactionCopyWith<$R, ChatReaction, $Out> get $asChatReaction =>
      $base.as((v, t, t2) => _ChatReactionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatReactionCopyWith<$R, $In extends ChatReaction, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? messageId, String? userId, String? reaction});
  ChatReactionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChatReactionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatReaction, $Out>
    implements ChatReactionCopyWith<$R, ChatReaction, $Out> {
  _ChatReactionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatReaction> $mapper =
      ChatReactionMapper.ensureInitialized();
  @override
  $R call({String? id, String? messageId, String? userId, String? reaction}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (messageId != null) #messageId: messageId,
          if (userId != null) #userId: userId,
          if (reaction != null) #reaction: reaction,
        }),
      );
  @override
  ChatReaction $make(CopyWithData data) => ChatReaction(
    id: data.get(#id, or: $value.id),
    messageId: data.get(#messageId, or: $value.messageId),
    userId: data.get(#userId, or: $value.userId),
    reaction: data.get(#reaction, or: $value.reaction),
  );

  @override
  ChatReactionCopyWith<$R2, ChatReaction, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatReactionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ChatReplyMessageMapper extends ClassMapperBase<ChatReplyMessage> {
  ChatReplyMessageMapper._();

  static ChatReplyMessageMapper? _instance;
  static ChatReplyMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatReplyMessageMapper._());
      ChatMessageTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChatReplyMessage';

  static String _$id(ChatReplyMessage v) => v.id;
  static const Field<ChatReplyMessage, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: "",
  );
  static String _$messageId(ChatReplyMessage v) => v.messageId;
  static const Field<ChatReplyMessage, String> _f$messageId = Field(
    'messageId',
    _$messageId,
    opt: true,
    def: "",
  );
  static String _$replyTo(ChatReplyMessage v) => v.replyTo;
  static const Field<ChatReplyMessage, String> _f$replyTo = Field(
    'replyTo',
    _$replyTo,
    opt: true,
    def: "",
  );
  static String _$replyBy(ChatReplyMessage v) => v.replyBy;
  static const Field<ChatReplyMessage, String> _f$replyBy = Field(
    'replyBy',
    _$replyBy,
    opt: true,
    def: "",
  );
  static String _$message(ChatReplyMessage v) => v.message;
  static const Field<ChatReplyMessage, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    def: "",
  );
  static ChatMessageType _$type(ChatReplyMessage v) => v.type;
  static const Field<ChatReplyMessage, ChatMessageType> _f$type = Field(
    'type',
    _$type,
    opt: true,
    def: ChatMessageType.chat,
  );
  static Duration _$duration(ChatReplyMessage v) => v.duration;
  static const Field<ChatReplyMessage, Duration> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
    def: Duration.zero,
    hook: DurationMillisHook(),
  );
  static bool _$isEmpty(ChatReplyMessage v) => v.isEmpty;
  static const Field<ChatReplyMessage, bool> _f$isEmpty = Field(
    'isEmpty',
    _$isEmpty,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ChatReplyMessage> fields = const {
    #id: _f$id,
    #messageId: _f$messageId,
    #replyTo: _f$replyTo,
    #replyBy: _f$replyBy,
    #message: _f$message,
    #type: _f$type,
    #duration: _f$duration,
    #isEmpty: _f$isEmpty,
  };

  static ChatReplyMessage _instantiate(DecodingData data) {
    return ChatReplyMessage(
      id: data.dec(_f$id),
      messageId: data.dec(_f$messageId),
      replyTo: data.dec(_f$replyTo),
      replyBy: data.dec(_f$replyBy),
      message: data.dec(_f$message),
      type: data.dec(_f$type),
      duration: data.dec(_f$duration),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatReplyMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatReplyMessage>(map);
  }

  static ChatReplyMessage fromJson(String json) {
    return ensureInitialized().decodeJson<ChatReplyMessage>(json);
  }
}

mixin ChatReplyMessageMappable {
  String toJson() {
    return ChatReplyMessageMapper.ensureInitialized()
        .encodeJson<ChatReplyMessage>(this as ChatReplyMessage);
  }

  Map<String, dynamic> toMap() {
    return ChatReplyMessageMapper.ensureInitialized()
        .encodeMap<ChatReplyMessage>(this as ChatReplyMessage);
  }

  ChatReplyMessageCopyWith<ChatReplyMessage, ChatReplyMessage, ChatReplyMessage>
  get copyWith =>
      _ChatReplyMessageCopyWithImpl<ChatReplyMessage, ChatReplyMessage>(
        this as ChatReplyMessage,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatReplyMessageMapper.ensureInitialized().stringifyValue(
      this as ChatReplyMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatReplyMessageMapper.ensureInitialized().equalsValue(
      this as ChatReplyMessage,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatReplyMessageMapper.ensureInitialized().hashValue(
      this as ChatReplyMessage,
    );
  }
}

extension ChatReplyMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatReplyMessage, $Out> {
  ChatReplyMessageCopyWith<$R, ChatReplyMessage, $Out>
  get $asChatReplyMessage =>
      $base.as((v, t, t2) => _ChatReplyMessageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatReplyMessageCopyWith<$R, $In extends ChatReplyMessage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? messageId,
    String? replyTo,
    String? replyBy,
    String? message,
    ChatMessageType? type,
    Duration? duration,
  });
  ChatReplyMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ChatReplyMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatReplyMessage, $Out>
    implements ChatReplyMessageCopyWith<$R, ChatReplyMessage, $Out> {
  _ChatReplyMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatReplyMessage> $mapper =
      ChatReplyMessageMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? messageId,
    String? replyTo,
    String? replyBy,
    String? message,
    ChatMessageType? type,
    Duration? duration,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (messageId != null) #messageId: messageId,
      if (replyTo != null) #replyTo: replyTo,
      if (replyBy != null) #replyBy: replyBy,
      if (message != null) #message: message,
      if (type != null) #type: type,
      if (duration != null) #duration: duration,
    }),
  );
  @override
  ChatReplyMessage $make(CopyWithData data) => ChatReplyMessage(
    id: data.get(#id, or: $value.id),
    messageId: data.get(#messageId, or: $value.messageId),
    replyTo: data.get(#replyTo, or: $value.replyTo),
    replyBy: data.get(#replyBy, or: $value.replyBy),
    message: data.get(#message, or: $value.message),
    type: data.get(#type, or: $value.type),
    duration: data.get(#duration, or: $value.duration),
  );

  @override
  ChatReplyMessageCopyWith<$R2, ChatReplyMessage, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatReplyMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

