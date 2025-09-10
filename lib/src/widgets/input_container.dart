import 'package:chat_interface/chat_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:screwdriver/screwdriver.dart';

import 'chat_field.dart';

class ChatInputContainer extends StatefulWidget {
  const ChatInputContainer({super.key});

  @override
  State<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends State<ChatInputContainer> {
  bool hideElements = false;
  ChatUiConfig get config => ChatUiConfigProvider.of(context);
  ChatController get controller => ChatControllerProvider.of(context);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // if (mounted) {
      //   config = ChatUiConfigProvider.of(context);
      //   controller = ChatControllerProvider.of(context);
      // }
      controller.messageController.addListener(() {
        setState(() {
          hideElements = controller.messageController.text
              .trim()
              .isNotNullOrEmpty;
        });
      });
    });
  }

  // @override
  // void dispose() {
  //   controller.messageController.removeListener(() {});
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.theme.colorScheme;
    final chatTheme = ChatThemeProvider.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 3.0),
                decoration: BoxDecoration(
                  borderRadius: chatTheme.inputBorderRadius,
                  color: chatTheme.inputBackgroundColor,
                  border: Border.all(
                    color: chatTheme.inputBorderColor,
                    width: chatTheme.inputBorderWidth,
                  ),
                ),
                child: ChatField(
                  leading: config.leading ?? const SizedBox(width: 12),
                  focusNode: controller.focusNode,
                  textController: controller.messageController,
                  onSubmitted: (value) => controller.addMessage(
                    ChatMessage(
                      message: value,
                      senderId: controller.currentUser.id,
                      roomId: controller.currentUser.roomId,
                      chatStatus: ChatMessageStatus.pending,
                      type: ChatMessageType.chat,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      id:
                          controller.uuidGenerator?.call() ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                    ),
                  ),
                  actions:
                      config.actions ??
                      [
                        IconButton(
                          onPressed: () {
                            if (controller.onTapAttachFile != null) {
                              controller.onTapAttachFile?.call();
                            } else {
                              controller.defaultAttachFileAction();
                            }
                          },
                          icon: Icon(
                            controller.attachFileIcon ??
                                Icons.attach_file_rounded,
                            size: 24.0,
                            color: chatTheme.attachmentButtonColor,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: hideElements
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: () {
                                    if (controller.onTapCamera != null) {
                                      controller.onTapCamera?.call();
                                    } else {
                                      controller.defaultCameraAction();
                                    }
                                  },
                                  icon: Icon(
                                    controller.cameraIcon ??
                                        Icons.camera_alt_rounded,
                                    size: 24.0,
                                    color: chatTheme.attachmentButtonColor,
                                  ),
                                ),
                        ),
                      ],
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            IconButton.filled(
              onPressed: () => controller.addMessage(
                ChatMessage(
                  message: controller.messageController.text.trim(),
                  senderId: controller.currentUser.id,
                  roomId: controller.currentUser.roomId,
                  chatStatus: ChatMessageStatus.pending,
                  type: ChatMessageType.chat,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  id:
                      controller.uuidGenerator?.call() ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                ),
              ),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                elevation: 0,
                padding: EdgeInsets.zero,
                enableFeedback: true,
                shadowColor: colorTheme.surfaceContainerHigh,
                iconSize: 24,
                backgroundColor: chatTheme.sendButtonColor,
                foregroundColor: chatTheme.inputBackgroundColor,
                minimumSize: const Size(42, 42),
              ),
              tooltip: 'Send',
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
