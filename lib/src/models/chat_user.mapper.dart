// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'chat_user.dart';

class ChatUserRoleMapper extends EnumMapper<ChatUserRole> {
  ChatUserRoleMapper._();

  static ChatUserRoleMapper? _instance;
  static ChatUserRoleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatUserRoleMapper._());
    }
    return _instance!;
  }

  static ChatUserRole fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatUserRole decode(dynamic value) {
    switch (value) {
      case r'admin':
        return ChatUserRole.admin;
      case r'member':
        return ChatUserRole.member;
      case r'guest':
        return ChatUserRole.guest;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatUserRole self) {
    switch (self) {
      case ChatUserRole.admin:
        return r'admin';
      case ChatUserRole.member:
        return r'member';
      case ChatUserRole.guest:
        return r'guest';
    }
  }
}

extension ChatUserRoleMapperExtension on ChatUserRole {
  String toValue() {
    ChatUserRoleMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatUserRole>(this) as String;
  }
}

class ChatUserMapper extends ClassMapperBase<ChatUser> {
  ChatUserMapper._();

  static ChatUserMapper? _instance;
  static ChatUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatUserMapper._());
      ChatImageTypeMapper.ensureInitialized();
      ChatUserRoleMapper.ensureInitialized();
      ChatMessageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChatUser';

  static String _$id(ChatUser v) => v.id;
  static const Field<ChatUser, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: "",
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static String _$name(ChatUser v) => v.name;
  static const Field<ChatUser, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    def: "",
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static String? _$avatar(ChatUser v) => v.avatar;
  static const Field<ChatUser, String> _f$avatar = Field(
    'avatar',
    _$avatar,
    opt: true,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static ChatImageType _$imageType(ChatUser v) => v.imageType;
  static const Field<ChatUser, ChatImageType> _f$imageType = Field(
    'imageType',
    _$imageType,
    opt: true,
    def: ChatImageType.network,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static Map<String, dynamic> _$metadata(ChatUser v) => v.metadata;
  static const Field<ChatUser, Map<String, dynamic>> _f$metadata = Field(
    'metadata',
    _$metadata,
    opt: true,
    def: const {},
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static ChatUserRole _$role(ChatUser v) => v.role;
  static const Field<ChatUser, ChatUserRole> _f$role = Field(
    'role',
    _$role,
    opt: true,
    def: ChatUserRole.member,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static ChatMessage? _$lastReadMessage(ChatUser v) => v.lastReadMessage;
  static const Field<ChatUser, ChatMessage> _f$lastReadMessage = Field(
    'lastReadMessage',
    _$lastReadMessage,
    opt: true,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static DateTime? _$lastReadAt(ChatUser v) => v.lastReadAt;
  static const Field<ChatUser, DateTime> _f$lastReadAt = Field(
    'lastReadAt',
    _$lastReadAt,
    opt: true,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static String _$roomId(ChatUser v) => v.roomId;
  static const Field<ChatUser, String> _f$roomId = Field(
    'roomId',
    _$roomId,
    opt: true,
    def: "",
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static String _$status(ChatUser v) => v.status;
  static const Field<ChatUser, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: "",
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static DateTime? _$createdAt(ChatUser v) => v.createdAt;
  static const Field<ChatUser, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );
  static DateTime? _$updatedAt(ChatUser v) => v.updatedAt;
  static const Field<ChatUser, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: false,
  );

  @override
  final MappableFields<ChatUser> fields = const {
    #id: _f$id,
    #name: _f$name,
    #avatar: _f$avatar,
    #imageType: _f$imageType,
    #metadata: _f$metadata,
    #role: _f$role,
    #lastReadMessage: _f$lastReadMessage,
    #lastReadAt: _f$lastReadAt,
    #roomId: _f$roomId,
    #status: _f$status,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static ChatUser _instantiate(DecodingData data) {
    return ChatUser(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      avatar: data.dec(_f$avatar),
      imageType: data.dec(_f$imageType),
      metadata: data.dec(_f$metadata),
      role: data.dec(_f$role),
      lastReadMessage: data.dec(_f$lastReadMessage),
      lastReadAt: data.dec(_f$lastReadAt),
      roomId: data.dec(_f$roomId),
      status: data.dec(_f$status),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatUser>(map);
  }

  static ChatUser fromJson(String json) {
    return ensureInitialized().decodeJson<ChatUser>(json);
  }
}

mixin ChatUserMappable {
  String toJson() {
    return ChatUserMapper.ensureInitialized().encodeJson<ChatUser>(
      this as ChatUser,
    );
  }

  Map<String, dynamic> toMap() {
    return ChatUserMapper.ensureInitialized().encodeMap<ChatUser>(
      this as ChatUser,
    );
  }

  ChatUserCopyWith<ChatUser, ChatUser, ChatUser> get copyWith =>
      _ChatUserCopyWithImpl<ChatUser, ChatUser>(
        this as ChatUser,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatUserMapper.ensureInitialized().stringifyValue(this as ChatUser);
  }

  @override
  bool operator ==(Object other) {
    return ChatUserMapper.ensureInitialized().equalsValue(
      this as ChatUser,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatUserMapper.ensureInitialized().hashValue(this as ChatUser);
  }
}

extension ChatUserValueCopy<$R, $Out> on ObjectCopyWith<$R, ChatUser, $Out> {
  ChatUserCopyWith<$R, ChatUser, $Out> get $asChatUser =>
      $base.as((v, t, t2) => _ChatUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatUserCopyWith<$R, $In extends ChatUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get metadata;
  ChatMessageCopyWith<$R, ChatMessage, ChatMessage>? get lastReadMessage;
  $R call({
    String? id,
    String? name,
    String? avatar,
    ChatImageType? imageType,
    Map<String, dynamic>? metadata,
    ChatUserRole? role,
    ChatMessage? lastReadMessage,
    DateTime? lastReadAt,
    String? roomId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  ChatUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChatUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatUser, $Out>
    implements ChatUserCopyWith<$R, ChatUser, $Out> {
  _ChatUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatUser> $mapper =
      ChatUserMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get metadata => MapCopyWith(
    $value.metadata,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(metadata: v),
  );
  @override
  ChatMessageCopyWith<$R, ChatMessage, ChatMessage>? get lastReadMessage =>
      $value.lastReadMessage?.copyWith.$chain((v) => call(lastReadMessage: v));
  @override
  $R call({
    String? id,
    String? name,
    Object? avatar = $none,
    ChatImageType? imageType,
    Map<String, dynamic>? metadata,
    ChatUserRole? role,
    Object? lastReadMessage = $none,
    Object? lastReadAt = $none,
    String? roomId,
    String? status,
    Object? createdAt = $none,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (avatar != $none) #avatar: avatar,
      if (imageType != null) #imageType: imageType,
      if (metadata != null) #metadata: metadata,
      if (role != null) #role: role,
      if (lastReadMessage != $none) #lastReadMessage: lastReadMessage,
      if (lastReadAt != $none) #lastReadAt: lastReadAt,
      if (roomId != null) #roomId: roomId,
      if (status != null) #status: status,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  ChatUser $make(CopyWithData data) => ChatUser(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    avatar: data.get(#avatar, or: $value.avatar),
    imageType: data.get(#imageType, or: $value.imageType),
    metadata: data.get(#metadata, or: $value.metadata),
    role: data.get(#role, or: $value.role),
    lastReadMessage: data.get(#lastReadMessage, or: $value.lastReadMessage),
    lastReadAt: data.get(#lastReadAt, or: $value.lastReadAt),
    roomId: data.get(#roomId, or: $value.roomId),
    status: data.get(#status, or: $value.status),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  ChatUserCopyWith<$R2, ChatUser, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

