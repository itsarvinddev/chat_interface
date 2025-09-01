import 'dart:async';

import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:screwdriver/screwdriver.dart';

import 'chat_field.dart';

class ChatInputContainer extends StatelessWidget {
  final ChatController controller;
  final Future<bool> Function(ChatMessage message)? onSend;
  final Widget? leading;
  const ChatInputContainer({
    super.key,
    required this.controller,
    this.onSend,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.theme.colorScheme;
    final hideElements = controller.messageController.text
        .trim()
        .isNotNullOrEmpty;

    return SafeArea(
      //  bottom: defaultTargetPlatform.isAndroid,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 3.0, top: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorTheme.surface
                      : colorTheme.surfaceContainer,
                ),
                child: ChatField(
                  leading: leading ?? const SizedBox(width: 12),
                  focusNode: controller.focusNode,
                  textController: controller.messageController,
                  onSubmitted: (value) => controller.addMessage(
                    ChatMessage(
                      message: value,
                      senderId: controller.currentUser.id,
                      roomId: controller.currentUser.roomId,
                      status: ChatMessageStatus.pending,
                      type: ChatMessageType.chat,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ),
                  actions: [
                    IconButton(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(22, 22),
                      ),
                      onPressed: () {
                        //   onAttachmentsIconPressed(context);
                      },
                      icon: Icon(
                        Icons.attach_file_rounded,
                        size: 24.0,
                        color: context.theme.colorScheme.secondary,
                      ),
                    ),
                    if (!hideElements) ...[
                      IconButton(
                        style: IconButton.styleFrom(
                          minimumSize: const Size(22, 22),
                        ),
                        onPressed: () {
                          //  controllerProvider.navigateToCameraView(context);
                        },
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 24.0,
                          color: context.theme.colorScheme.secondary,
                        ),
                      ),
                    ],
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
                  status: ChatMessageStatus.pending,
                  type: ChatMessageType.chat,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                elevation: 0,
                padding: EdgeInsets.zero,
                enableFeedback: true,
                shadowColor: colorTheme.surfaceContainerHigh,
                iconSize: 24,
                backgroundColor: colorTheme.primary,
                foregroundColor: colorTheme.surface,
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
