import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import 'utils/chat_by_date.dart';
import 'widgets/bubble.dart';
import 'widgets/textfield.dart';

class ChatUi extends StatelessWidget {
  final ChatController controller;
  final Future<bool> Function(ChatMessage message)? onSend;
  final Widget Function(
    ChatController controller,
    ChatMessage message,
    int index,
  )?
  customMessageBuilder;

  const ChatUi({
    super.key,
    required this.controller,
    this.onSend,
    this.customMessageBuilder,
  });

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
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, ChatMessage>(
              state: state,
              fetchNextPage: fetchNextPage,
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollController: controller.scrollController,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, item, index) {
                  // Figure out the previous message (for date comparison)
                  final ChatMessage? prevMessage =
                      (index < controller.initialMessageList.length - 1)
                      ? controller.initialMessageList[index + 1]
                      : null;

                  // Show header if this is the first message OR date is different from previous
                  final bool showDateHeader = !ChatDateUtils.isSameDay(
                    item.createdAt?.toLocal() ?? DateTime.now(),
                    prevMessage?.createdAt?.toLocal() ?? DateTime.now(),
                  );

                  return ChatBubble(
                    controller: controller,
                    message: item,
                    index: index,
                    showHeader: showDateHeader,
                    customMessageBuilder: customMessageBuilder,
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ChatTextField(
        controller: controller,
        onSend: onSend,
      ),
    );
  }
}
