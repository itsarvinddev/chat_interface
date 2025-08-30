import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import 'widgets/bubble.dart';
import 'widgets/textfield.dart';

class ChatUi extends StatelessWidget {
  final ChatController controller;
  final Future<void> Function(ChatMessage message)? onSend;

  const ChatUi({super.key, required this.controller, this.onSend});

  @override
  Widget build(BuildContext context) {
    if (!InitializationChecker.isInitialized) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              ChatUINotInitializedException(
                'ChatUI not initialized when trying to build ChatUi, please call initializeChatUI() in your main.dart',
              ).toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://web.whatsapp.com/img/bg-chat-tile-dark_a4be512e7195b6b733d9110b408f075d.png",
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              context.theme.colorScheme.surfaceContainerHigh,
              BlendMode.srcATop,
            ),
          ),
        ),
        child: PagingListener(
          controller: controller.pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, ChatMessage>(
                state: state,
                fetchNextPage: fetchNextPage,
                reverse: true,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) => ChatBubble(
                    controller: controller,
                    item: item,
                    index: index,
                  ),
                ),
              ),
        ),
      ),
      bottomNavigationBar: ChatTextField(controller: controller, onSend: onSend),
    );
  }
}
