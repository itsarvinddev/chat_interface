import 'package:chatui/chatui.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'chat_user.mapper.dart';

@MappableClass()
class ChatUser with ChatUserMappable {
  /// Provides id of user.
  String id;

  /// Provides name of user.
  String name;

  /// Provides profile picture as network URL or asset of user.
  /// Or
  /// Provides profile picture's data in base64 string.
  /// or
  /// Provides profile picture's asset path.
  String? avatar;

  /// Field to define image type.
  ///
  /// {@macro chatui.enumeration.ImageType}
  ChatImageType imageType;

  /// Field to define metadata of user.
  Map<String, dynamic> metadata;

  /// Field to define user's role.
  ChatUserRole role;

  /// Provides last read message of user.
  ChatMessage? lastReadMessage;

  /// Provides last read message at.
  DateTime? lastReadAt;

  /// Provides room id of user.
  String roomId;

  /// Provides status of user.
  String status;

  /// Provides is createdAt of user.
  DateTime? createdAt;

  /// Provides is deleted of user.
  DateTime? updatedAt;

  ChatUser({
    this.id = "",
    this.name = "",
    this.avatar,
    this.imageType = ChatImageType.network,
    this.metadata = const {},
    this.role = ChatUserRole.member,
    this.lastReadMessage,
    this.lastReadAt,
    this.roomId = "",
    this.status = "",
    this.createdAt,
    this.updatedAt,
  });
}

@MappableEnum()
enum ChatUserRole { admin, member, guest }
