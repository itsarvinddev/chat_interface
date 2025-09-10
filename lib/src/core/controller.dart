import 'dart:async';

import 'package:chat_interface/chat_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screwdriver/screwdriver.dart';

/// Controller for managing chat state, messages, and scrolling.
class ChatController {
  ChatController({
    required this.scrollController,
    required List<ChatUser> otherUsers,
    required this.currentUser,
    required this.pagingController,
    MarkdownTextEditingController? textController,
    this.focusNode,
  }) : _otherUsers = {for (final user in otherUsers) user.id: user},
       messageController =
           textController ??
           MarkdownTextEditingController(styles: MarkdownTextStyles());

  /// Focus node for the message input field
  final FocusNode? focusNode;

  /// Scroll controller for chat list view.
  final ScrollController scrollController;

  /// Current logged-in user.
  final ChatUser currentUser;

  /// Paging controller for infinite scroll messages.
  final PagingController<int, ChatMessage> pagingController;

  /// Internal map of other users for quick lookup.
  final Map<String, ChatUser> _otherUsers;

  /// ValueNotifier for the input text field show/hide.
  final ValueNotifier<bool> _showInputField = ValueNotifier<bool>(true);

  /// Get the valueNotifier for the input text field show/hide.
  ValueNotifier<bool> get showInputField => _showInputField;

  /// Toggle the input text field show/hide.
  void toggleInputField() {
    _showInputField.value = !_showInputField.value;
  }

  /// Text controller for composing messages.
  late final MarkdownTextEditingController messageController;

  /// Callback when a message is marked as seen.
  Future<void> Function(ChatMessage message)? onMarkAsSeen;

  /// Callback when a new message is added.
  Future<void> Function(ChatMessage message)? onMessageAdded;

  /// Callback when a message is updated.
  Future<void> Function(ChatMessage message)? onMessageUpdated;

  /// Callback when tap on camera button.
  Future<void> Function()? onTapCamera;

  /// Camera icon.
  IconData? cameraIcon;

  /// Attach file icon.
  IconData? attachFileIcon;

  /// Callback when tap on attach file button.
  Future<void> Function()? onTapAttachFile;

  /// Default camera action - picks image from camera and sends as message
  Future<void> defaultCameraAction() async {
    try {
      final XFile? image = await FilePickerUtils.pickImageFromCamera();
      if (image != null) {
        final attachment = await FilePickerUtils.createAttachmentFromXFile(
          image,
        );
        await _sendAttachmentMessage(attachment);
      }
    } catch (e) {
      debugPrint('Error in default camera action: $e');
    }
  }

  /// Default file attach action - shows options to pick files or images
  Future<void> defaultAttachFileAction({
    Widget Function(BuildContext)? builder,
    Future<void> Function(String)? onTap,
  }) async {
    try {
      // Show bottom sheet with options
      final context = focusNode?.context;
      if (context == null) {
        debugPrint('Error in default attach file action: focusNode is null');
        return;
      }

      final result = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            builder ??
            (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: const Text('Photo Library'),
                      onTap: () => Navigator.pop(context, 'gallery'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: const Text('Camera'),
                      onTap: () => Navigator.pop(context, 'camera'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_file),
                      title: const Text('Document'),
                      onTap: () => Navigator.pop(context, 'document'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
      );

      if (result != null) {
        if (onTap != null) {
          await onTap(result);
        } else {
          await handleAttachmentOption(result);
        }
      }
    } catch (e) {
      debugPrint('Error in default attach file action: $e');
    }
  }

  /// Handles the selected attachment option
  Future<void> handleAttachmentOption(String option) async {
    try {
      switch (option) {
        case 'gallery':
          final XFile? image = await FilePickerUtils.pickImageFromGallery();
          if (image != null) {
            final attachment = await FilePickerUtils.createAttachmentFromXFile(
              image,
            );
            await _sendAttachmentMessage(attachment);
          }
          break;
        case 'camera':
          final XFile? image = await FilePickerUtils.pickImageFromCamera();
          if (image != null) {
            final attachment = await FilePickerUtils.createAttachmentFromXFile(
              image,
            );
            await _sendAttachmentMessage(attachment);
          }
          break;
        case 'document':
          final FilePickerResult? result = await FilePickerUtils.pickFile();
          if (result != null && result.files.isNotEmpty) {
            final attachment =
                await FilePickerUtils.createAttachmentFromPlatformFile(
                  result.files.first,
                );
            await _sendAttachmentMessage(attachment);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error handling attachment option: $e');
    }
  }

  /// Sends a message with attachment
  Future<void> _sendAttachmentMessage(ChatAttachment attachment) async {
    try {
      // Validate file size (default 100MB limit)
      if (!FilePickerUtils.isFileSizeValid(attachment.fileSize)) {
        debugPrint(
          'File size too large: ${FilePickerUtils.getReadableFileSize(attachment.fileSize)}',
        );
        return;
      }

      final message = ChatMessage(
        id:
            uuidGenerator?.call() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        message: '', // Empty message for attachment-only messages
        attachment: attachment,
        type: ChatMessageType.chat,
        senderId: currentUser.id,
        roomId: currentUser.roomId,
        chatStatus: ChatMessageStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addMessage(message);
    } catch (e) {
      debugPrint('Error sending attachment message: $e');
    }
  }

  /// Public method to send attachment message (for external use)
  Future<void> sendAttachmentMessage(ChatAttachment attachment) async {
    await _sendAttachmentMessage(attachment);
  }

  /// Public method to pick and send image from gallery
  Future<void> pickAndSendImageFromGallery() async {
    try {
      final XFile? image = await FilePickerUtils.pickImageFromGallery();
      if (image != null) {
        final attachment = await FilePickerUtils.createAttachmentFromXFile(
          image,
        );
        await _sendAttachmentMessage(attachment);
      }
    } catch (e) {
      debugPrint('Error picking and sending image from gallery: $e');
    }
  }

  /// Public method to pick and send image from camera
  Future<void> pickAndSendImageFromCamera() async {
    try {
      final XFile? image = await FilePickerUtils.pickImageFromCamera();
      if (image != null) {
        final attachment = await FilePickerUtils.createAttachmentFromXFile(
          image,
        );
        await _sendAttachmentMessage(attachment);
      }
    } catch (e) {
      debugPrint('Error picking and sending image from camera: $e');
    }
  }

  /// Public method to pick and send file
  Future<void> pickAndSendFile() async {
    try {
      final FilePickerResult? result = await FilePickerUtils.pickFile();
      if (result != null && result.files.isNotEmpty) {
        final attachment =
            await FilePickerUtils.createAttachmentFromPlatformFile(
              result.files.first,
            );
        await _sendAttachmentMessage(attachment);
      }
    } catch (e) {
      debugPrint('Error picking and sending file: $e');
    }
  }

  /// Exposes other users as an unmodifiable list.
  UnmodifiableListView<ChatUser> get otherUsers =>
      UnmodifiableListView(_otherUsers.values);

  /// Returns the all users.
  UnmodifiableListView<ChatUser> get allUsers =>
      UnmodifiableListView([currentUser, ..._otherUsers.values]);

  /// Returns the current list of messages.
  List<ChatMessage> get messages {
    if (pagingController.items != null) {
      return pagingController.items ?? [];
    }
    if (pagingController.pages != null) {
      return pagingController.pages!.expand((page) => page).toList();
    }
    return [];
  }

  String Function()? uuidGenerator;

  /// Adds a new message to the top of the first page.
  Future<void> addMessage(ChatMessage message, {bool callApi = true}) async {
    try {
      final text = message.message.trim();
      final attachment = message.attachment;
      if (text.isNullOrEmpty &&
          (attachment == null || attachment.file == null)) {
        return;
      }
      final pages = List<List<ChatMessage>>.from(pagingController.pages!);
      pages.first = [message, ...pages.first];
      pagingController.value = pagingController.value.copyWith(pages: pages);
      if (callApi) {
        messageController.clear();
        await onMessageAdded?.call(message);
      }
    } catch (e, stack) {
      debugPrint('Error adding message: $e\n$stack');
    }
  }

  /// Updates an existing message by ID.
  Future<void> updateMessage(ChatMessage message, {bool callApi = true}) async {
    try {
      pagingController.mapItems(
        (item) => item.id == message.id
            ? item.copyWith(
                message: message.message,
                status: message.status,
                attachment: message.attachment,
                chatStatus: message.chatStatus,
                reactions: message.reactions,
                replyMessage: message.replyMessage,
                senderId: message.senderId,
                roomId: message.roomId,
                duration: message.duration,
                metadata: message.metadata,
                createdAt: message.createdAt,
                updatedAt: message.updatedAt,
                editedAt: message.editedAt,
                type: message.type,
              )
            : item,
      );
      if (callApi) {
        await onMessageUpdated?.call(message);
      }
    } catch (e, stack) {
      debugPrint('Error updating message: $e\n$stack');
    }
  }

  /// Scrolls to the last (oldest) message in the chat.
  Future<void> scrollToLastMessage({
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    Timer(delay, () async {
      if (!scrollController.hasClients) return;
      await scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 320),
      );
    });
  }

  /// Checks if a message was sent by the current user.
  bool isMessageBySelf(ChatMessage message) =>
      message.senderId == currentUser.id;

  /// Determines if a message should display a tail (last in a sequence).
  bool tailForIndex(int index) {
    final items = messages;
    if (index < 0 || index >= items.length) return true;

    final msg = items[index];
    final next = index + 1 < items.length ? items[index + 1] : null;
    return next == null ||
        next.senderId != msg.senderId ||
        next.type == ChatMessageType.action;
  }

  /// Room object for the chat.
  late Object? _room;

  /// Sets the room object for the chat.
  void setRoom(Object? room) {
    _room = room;
  }

  /// Gets the room object for the chat.
  Object? getRoom() {
    return _room;
  }

  /// Typed room getter for convenience.
  T? getRoomAs<T>() => _room is T ? _room as T : null;

  /// Disposes resources safely.
  void dispose() {
    if (scrollController.hasClients) {
      scrollController.dispose();
    }
    pagingController.dispose();
    messageController.dispose();
    focusNode?.dispose();
    _showInputField.dispose();
    _otherUsers.clear();
    _room = null;
  }
}
