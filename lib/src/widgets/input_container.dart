import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:screwdriver/screwdriver.dart';

import 'chat_field.dart';

class ChatInputContainer extends StatefulWidget {
  final ChatController controller;
  final ChatUiConfig config;
  const ChatInputContainer({
    super.key,
    required this.controller,
    this.config = const ChatUiConfig(),
  });

  @override
  State<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends State<ChatInputContainer> {
  bool hideElements = false;

  @override
  void initState() {
    super.initState();
    widget.controller.messageController.addListener(() {
      setState(() {
        hideElements = widget.controller.messageController.text
            .trim()
            .isNotNullOrEmpty;
      });
    });
  }

  @override
  void dispose() {
    widget.controller.messageController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.theme.colorScheme;
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
                  borderRadius: BorderRadius.circular(24.0),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorTheme.surface
                      : colorTheme.surfaceContainer,
                ),
                child: ChatField(
                  leading: widget.config.leading ?? const SizedBox(width: 12),
                  focusNode: widget.controller.focusNode,
                  textController: widget.controller.messageController,
                  onSubmitted: (value) => widget.controller.addMessage(
                    ChatMessage(
                      message: value,
                      senderId: widget.controller.currentUser.id,
                      roomId: widget.controller.currentUser.roomId,
                      status: ChatMessageStatus.pending,
                      type: ChatMessageType.chat,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ),
                  actions:
                      widget.config.actions ??
                      [
                        IconButton(
                          onPressed: () =>
                              widget.controller.onTapAttachFile?.call(),
                          icon: Icon(
                            Icons.attach_file_rounded,
                            size: 24.0,
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: hideElements
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: () =>
                                      widget.controller.onTapCamera?.call(),
                                  icon: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 24.0,
                                    color: context.theme.colorScheme.secondary,
                                  ),
                                ),
                        ),
                      ],
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            IconButton.filled(
              onPressed: () => widget.controller.addMessage(
                ChatMessage(
                  message: widget.controller.messageController.text.trim(),
                  senderId: widget.controller.currentUser.id,
                  roomId: widget.controller.currentUser.roomId,
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
