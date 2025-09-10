// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'enums.dart';

class ChatMessageTypeMapper extends EnumMapper<ChatMessageType> {
  ChatMessageTypeMapper._();

  static ChatMessageTypeMapper? _instance;
  static ChatMessageTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatMessageTypeMapper._());
    }
    return _instance!;
  }

  static ChatMessageType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatMessageType decode(dynamic value) {
    switch (value) {
      case r'chat':
        return ChatMessageType.chat;
      case r'action':
        return ChatMessageType.action;
      case r'custom':
        return ChatMessageType.custom;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatMessageType self) {
    switch (self) {
      case ChatMessageType.chat:
        return r'chat';
      case ChatMessageType.action:
        return r'action';
      case ChatMessageType.custom:
        return r'custom';
    }
  }
}

extension ChatMessageTypeMapperExtension on ChatMessageType {
  String toValue() {
    ChatMessageTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatMessageType>(this) as String;
  }
}

class ChatTypeWriterStatusMapper extends EnumMapper<ChatTypeWriterStatus> {
  ChatTypeWriterStatusMapper._();

  static ChatTypeWriterStatusMapper? _instance;
  static ChatTypeWriterStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatTypeWriterStatusMapper._());
    }
    return _instance!;
  }

  static ChatTypeWriterStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatTypeWriterStatus decode(dynamic value) {
    switch (value) {
      case r'typing':
        return ChatTypeWriterStatus.typing;
      case r'typed':
        return ChatTypeWriterStatus.typed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatTypeWriterStatus self) {
    switch (self) {
      case ChatTypeWriterStatus.typing:
        return r'typing';
      case ChatTypeWriterStatus.typed:
        return r'typed';
    }
  }
}

extension ChatTypeWriterStatusMapperExtension on ChatTypeWriterStatus {
  String toValue() {
    ChatTypeWriterStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatTypeWriterStatus>(this)
        as String;
  }
}

class ChatMessageStatusMapper extends EnumMapper<ChatMessageStatus> {
  ChatMessageStatusMapper._();

  static ChatMessageStatusMapper? _instance;
  static ChatMessageStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatMessageStatusMapper._());
    }
    return _instance!;
  }

  static ChatMessageStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatMessageStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return ChatMessageStatus.pending;
      case r'sent':
        return ChatMessageStatus.sent;
      case r'delivered':
        return ChatMessageStatus.delivered;
      case r'seen':
        return ChatMessageStatus.seen;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatMessageStatus self) {
    switch (self) {
      case ChatMessageStatus.pending:
        return r'pending';
      case ChatMessageStatus.sent:
        return r'sent';
      case ChatMessageStatus.delivered:
        return r'delivered';
      case ChatMessageStatus.seen:
        return r'seen';
    }
  }
}

extension ChatMessageStatusMapperExtension on ChatMessageStatus {
  String toValue() {
    ChatMessageStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatMessageStatus>(this) as String;
  }
}

class ChatImageTypeMapper extends EnumMapper<ChatImageType> {
  ChatImageTypeMapper._();

  static ChatImageTypeMapper? _instance;
  static ChatImageTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatImageTypeMapper._());
    }
    return _instance!;
  }

  static ChatImageType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatImageType decode(dynamic value) {
    switch (value) {
      case r'asset':
        return ChatImageType.asset;
      case r'network':
        return ChatImageType.network;
      case r'base64':
        return ChatImageType.base64;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatImageType self) {
    switch (self) {
      case ChatImageType.asset:
        return r'asset';
      case ChatImageType.network:
        return r'network';
      case ChatImageType.base64:
        return r'base64';
    }
  }
}

extension ChatImageTypeMapperExtension on ChatImageType {
  String toValue() {
    ChatImageTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatImageType>(this) as String;
  }
}

class ChatViewStateMapper extends EnumMapper<ChatViewState> {
  ChatViewStateMapper._();

  static ChatViewStateMapper? _instance;
  static ChatViewStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatViewStateMapper._());
    }
    return _instance!;
  }

  static ChatViewState fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatViewState decode(dynamic value) {
    switch (value) {
      case r'hasMessages':
        return ChatViewState.hasMessages;
      case r'noData':
        return ChatViewState.noData;
      case r'loading':
        return ChatViewState.loading;
      case r'error':
        return ChatViewState.error;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatViewState self) {
    switch (self) {
      case ChatViewState.hasMessages:
        return r'hasMessages';
      case ChatViewState.noData:
        return r'noData';
      case ChatViewState.loading:
        return r'loading';
      case ChatViewState.error:
        return r'error';
    }
  }
}

extension ChatViewStateMapperExtension on ChatViewState {
  String toValue() {
    ChatViewStateMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatViewState>(this) as String;
  }
}

class ChatAttachmentTypeMapper extends EnumMapper<ChatAttachmentType> {
  ChatAttachmentTypeMapper._();

  static ChatAttachmentTypeMapper? _instance;
  static ChatAttachmentTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatAttachmentTypeMapper._());
    }
    return _instance!;
  }

  static ChatAttachmentType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatAttachmentType decode(dynamic value) {
    switch (value) {
      case r'image':
        return ChatAttachmentType.image;
      case r'video':
        return ChatAttachmentType.video;
      case r'audio':
        return ChatAttachmentType.audio;
      case r'voice':
        return ChatAttachmentType.voice;
      case r'document':
        return ChatAttachmentType.document;
      case r'location':
        return ChatAttachmentType.location;
      case r'contact':
        return ChatAttachmentType.contact;
      case r'custom':
        return ChatAttachmentType.custom;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatAttachmentType self) {
    switch (self) {
      case ChatAttachmentType.image:
        return r'image';
      case ChatAttachmentType.video:
        return r'video';
      case ChatAttachmentType.audio:
        return r'audio';
      case ChatAttachmentType.voice:
        return r'voice';
      case ChatAttachmentType.document:
        return r'document';
      case ChatAttachmentType.location:
        return r'location';
      case ChatAttachmentType.contact:
        return r'contact';
      case ChatAttachmentType.custom:
        return r'custom';
    }
  }
}

extension ChatAttachmentTypeMapperExtension on ChatAttachmentType {
  String toValue() {
    ChatAttachmentTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatAttachmentType>(this) as String;
  }
}

class UploadStatusMapper extends EnumMapper<UploadStatus> {
  UploadStatusMapper._();

  static UploadStatusMapper? _instance;
  static UploadStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UploadStatusMapper._());
    }
    return _instance!;
  }

  static UploadStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  UploadStatus decode(dynamic value) {
    switch (value) {
      case r'notUploading':
        return UploadStatus.notUploading;
      case r'preparing':
        return UploadStatus.preparing;
      case r'uploading':
        return UploadStatus.uploading;
      case r'uploaded':
        return UploadStatus.uploaded;
      case r'failed':
        return UploadStatus.failed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(UploadStatus self) {
    switch (self) {
      case UploadStatus.notUploading:
        return r'notUploading';
      case UploadStatus.preparing:
        return r'preparing';
      case UploadStatus.uploading:
        return r'uploading';
      case UploadStatus.uploaded:
        return r'uploaded';
      case UploadStatus.failed:
        return r'failed';
    }
  }
}

extension UploadStatusMapperExtension on UploadStatus {
  String toValue() {
    UploadStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<UploadStatus>(this) as String;
  }
}

