import 'dart:async';
import 'dart:developer';

import 'package:chatui/chatui.dart';
import 'package:flutter/widgets.dart';

base class ChatController {
  ChatController({
    required this.scrollController,
    required List<ChatUser> otherUsers,
    required this.currentUser,
    required this.pagingController,
    this.textController,
  }) : _otherUsers = otherUsers.toMap<String, ChatUser>(
         getKey: (user) => user.id,
       );

  ScrollController scrollController;

  final Map<String, ChatUser> _otherUsers;

  PagingController<int, ChatMessage> pagingController;

  MarkdownTextEditingController? textController;

  /// Provides current user which is sending messages.
  final ChatUser currentUser;

  /// Represents list of chat users
  List<ChatUser> get otherUsers => _otherUsers.values.toList();

  List<ChatMessage> get initialMessageList =>
      pagingController.items ??
      pagingController.pages?.expand((page) => page).toList() ??
      [];

  /// Used to add message in message list.
  void addMessage(ChatMessage message) {
    final pages = List<List<ChatMessage>>.from(pagingController.pages!);
    pages.first = [message, ...pages.first];
    pagingController.value = pagingController.value.copyWith(pages: pages);
  }

  void updateMessage(ChatMessage message) {
    try {
      pagingController.mapItems(
        (item) => item.id == message.id
            ? item.copyWith(status: message.status)
            : item,
      );
    } catch (e) {
      log('error: $e');
    }
  }

  /// Function to scroll to last messages in chat view
  void scrollToLastMessage() => Timer(Duration(milliseconds: 100), () {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.positions.last.minScrollExtent,
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: 320),
    );
  });

  bool isMessageBySelf(ChatMessage message) =>
      message.senderId == currentUser.id;

  /// Function for checking if the previous message is by the same user.
  /// if the continues messages are by the same user, then it will return true.
  /// for chat bubble tail to show in only one message.
  bool tailForIndex(int index) {
    final items =
        pagingController.pages?.expand((page) => page).toList() ??
        initialMessageList;
    final msg = items[index];
    final next = index + 1 < items.length ? items[index + 1] : null;
    return next == null || next.senderId != msg.senderId;
  }

  late MarkdownTextEditingController messageController =
      textController ??
      MarkdownTextEditingController(styles: MarkdownTextStyles());

  /// Used to dispose ValueNotifiers and Streams.
  void dispose() {
    scrollController.dispose();
    pagingController.dispose();
    messageController.dispose();
  }
}
