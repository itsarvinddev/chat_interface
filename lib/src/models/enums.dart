import 'package:chatui/src/extensions/extensions.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'enums.mapper.dart';

/// {@template chatui.enumeration.MessageType}
/// Defines the various message types in ChatView.
/// - [chat]: A default message type.
/// - [action]: An action message type.
/// - [custom]: A custom message type.
/// {@endtemplate}
@MappableEnum()
enum ChatMessageType {
  chat,
  action,
  custom;

  bool get isDefault => this == chat;
  bool get isAction => this == action;

  bool get isCustom => this == custom;

  static ChatMessageType? tryParse(String? value) {
    return ChatMessageType.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == value?.trim().toLowerCase(),
    );
  }
}

/// {@template chatui.enumeration.TypeWriterStatus}
/// Indicates whether the user is currently typing or has finished typing.
/// - [typing]: User is still typing.
/// - [typed]: User has completed typing.
/// {@endtemplate}
@MappableEnum()
enum ChatTypeWriterStatus {
  typing,
  typed;

  bool get isTyping => this == typing;

  bool get isTyped => this == typed;
}

/// {@template chatui.enumeration.MessageStatus}
/// Represents the current state of a message from sending to delivery.
/// - [pending]: Message is being sent.
/// - [sent]: Message is sent.
/// - [delivered]: Message is delivered.
/// - [seen]: Message is seen.
/// {@endtemplate}
@MappableEnum()
enum ChatMessageStatus {
  pending,
  sent,
  delivered,
  seen;

  bool get isSeen => this == seen;

  bool get isDelivered => this == delivered;

  bool get isSent => this == sent;

  bool get isPending => this == pending;

  static ChatMessageStatus? tryParse(String? value) {
    return ChatMessageStatus.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == value?.trim().toLowerCase(),
    );
  }
}

/// {@template chatui.enumeration.ImageType}
/// Defines the different types of image sources.
/// - [asset]: Image from local assets.
/// - [network]: Image from a network URL.
/// - [base64]: Image encoded in base64 format.
/// {@endtemplate}
@MappableEnum()
enum ChatImageType {
  asset,
  network,
  base64;

  bool get isNetwork => this == network;

  bool get isAsset => this == asset;

  bool get isBase64 => this == base64;

  static ChatImageType? tryParse(String? value) {
    return ChatImageType.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == value?.trim().toLowerCase(),
    );
  }
}

/// {@template chatui.enumeration.ChatViewState}
/// Represents the different states of the chat view.
/// - [hasMessages]: Chat has messages to display.
/// - [noData]: No messages available.
/// - [loading]: Messages are being loaded.
/// - [error]: An error occurred while loading messages.
/// {@endtemplate}
@MappableEnum()
enum ChatViewState {
  hasMessages,
  noData,
  loading,
  error;

  bool get isHasMessages => this == hasMessages;

  bool get isNoData => this == noData;

  bool get isLoading => this == loading;

  bool get isError => this == error;

  static ChatViewState? tryParse(String? value) {
    return ChatViewState.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == value?.trim().toLowerCase(),
    );
  }
}

/// {@template chatui.enumeration.AttachmentType}
/// Defines the different types of attachments.
/// - [image]: An image attachment.
/// - [video]: A video attachment.
/// - [audio]: An audio attachment.
/// - [voice]: A voice attachment.
/// - [document]: A document attachment.
/// - [location]: A location attachment.
/// - [contact]: A contact attachment.
/// - [custom]: A custom attachment.
/// {@endtemplate}
@MappableEnum()
enum ChatAttachmentType {
  image,
  video,
  audio,
  voice,
  document,
  location,
  contact,
  custom;

  bool get isImage => this == image;

  bool get isVideo => this == video;

  bool get isAudio => this == audio;

  bool get isVoice => this == voice;

  bool get isDocument => this == document;

  bool get isLocation => this == location;

  bool get isContact => this == contact;

  bool get isCustom => this == custom;

  static ChatAttachmentType? tryParse(String? value) {
    return ChatAttachmentType.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == value?.trim().toLowerCase(),
    );
  }
}

/// {@template chatui.enumeration.UploadStatus}
/// Defines the different statuses of the upload.
/// - [notUploading]: The upload is not uploading.
/// - [preparing]: The upload is preparing.
/// - [uploading]: The upload is uploading.
/// - [uploaded]: The upload is uploaded.
/// - [failed]: The upload failed.
/// {@endtemplate}
@MappableEnum()
enum UploadStatus {
  notUploading,
  preparing,
  uploading,
  uploaded,
  failed;

  bool get isNotUploading => this == notUploading;

  bool get isPreparing => this == preparing;

  bool get isUploading => this == uploading;

  bool get isUploaded => this == uploaded;

  bool get isFailed => this == failed;

  static UploadStatus? tryParse(String? value) {
    return UploadStatus.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == value?.trim().toLowerCase(),
    );
  }
}
