import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:screwdriver/screwdriver.dart';

class ChatTextField extends StatelessWidget {
  final ChatController controller;
  final Future<bool> Function(ChatMessage message)? onSend;
  const ChatTextField({super.key, required this.controller, this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.appBarTheme.backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller.messageController,
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Type a message',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  if (controller.messageController.text.trim().isNullOrEmpty) {
                    return;
                  }
                  final message = ChatMessage(
                    message: controller.messageController.text.trim(),
                    senderId: controller.currentUser.id,
                    type: ChatMessageType.chat,
                    status: ChatMessageStatus.sent,
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    roomId: "63e2364b-e0b5-4b30-b392-595944f2955b",
                  );
                  controller.addMessage(message);
                  final result = await onSend?.call(message);
                  if (result == true) {
                    message.status = ChatMessageStatus.delivered;
                    controller.updateMessage(message);
                  }
                  controller.messageController.clear();
                },
              ),
            ),
            onSubmitted: (value) async {
              if (value.trim().isNullOrEmpty) return;
              final message = ChatMessage(
                message: value.trim(),
                senderId: controller.currentUser.id,
                type: ChatMessageType.chat,
                status: ChatMessageStatus.sent,
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                roomId: "63e2364b-e0b5-4b30-b392-595944f2955b",
              )..sender = controller.currentUser;
              controller.addMessage(message);
              final result = await onSend?.call(message);
              if (result == true) {
                message.status = ChatMessageStatus.delivered;
                controller.updateMessage(message);
              }
              controller.messageController.clear();
            },
          ),
        ),
      ),
    );
  }
}
