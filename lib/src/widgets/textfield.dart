import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:screwdriver/screwdriver.dart';

class ChatTextField extends StatelessWidget {
  final ChatController controller;
  final Future<void> Function(ChatMessage message)? onSend;
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
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Type a message',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (controller.messageController.text.trim().isNullOrEmpty) {
                    return;
                  }
                  final message = ChatMessage(
                    message: controller.messageController.text.trim(),
                    senderId: controller.currentUser.id,
                    type: ChatMessageType.chat,
                    status: ChatMessageStatus.delivered,
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    roomId: "63e2364b-e0b5-4b30-b392-595944f2955b",
                  );
                  onSend?.call(message);
                  controller.addMessage(message);
                  controller.messageController.clear();
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNullOrEmpty) return;
              final message = ChatMessage(
                message: value.trim(),
                senderId: controller.currentUser.id,
                type: ChatMessageType.chat,
                status: ChatMessageStatus.delivered,
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                roomId: "63e2364b-e0b5-4b30-b392-595944f2955b",
              )..sender = controller.currentUser;
              onSend?.call(message);
              controller.addMessage(message);
              controller.messageController.clear();
            },
          ),
        ),
      ),
    );
  }
}
