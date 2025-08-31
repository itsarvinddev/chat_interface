import 'dart:async';
import 'dart:developer';

import 'package:chatui/chatui.dart';
import 'package:flutter/foundation.dart';
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

  /// Represents list of chat users
  List<ChatUser> get otherUsers => _otherUsers.values.toList();

  Map<String, ChatUser> get otherUsersMap => Map.of(_otherUsers);

  /// Provides current user which is sending messages.
  final ChatUser currentUser;

  /// Allow user to show typing indicator defaults to false.
  final ValueNotifier<bool> _showTypingIndicator = ValueNotifier(false);

  /// TypingIndicator as [ValueListenable] for `GroupedChatList` widget's
  /// typingIndicator [ValueListenableBuilder].
  ///  Use this for listening typing indicators
  ///   ```dart
  ///    chatController.typingIndicatorNotifier.addListener((){});
  ///  ```
  /// For more functionalities see [ValueListenable].
  ValueListenable<bool> get typingIndicatorNotifier => _showTypingIndicator;

  /// Indicates whether the typing indicator is displayed.
  /// Returns `true` if the typing indicator is shown, otherwise `false`
  bool get showTypingIndicator => _showTypingIndicator.value;

  /// Setter for changing values of typingIndicator
  /// ```dart
  ///  chatController.setTypingIndicator = true; // for showing indicator
  ///  chatController.setTypingIndicator = false; // for hiding indicator
  ///  ````
  set setTypingIndicator(bool value) => _showTypingIndicator.value = value;

  /// Allow user to add reply suggestions defaults to empty.
  final ValueNotifier<List<ChatReplyMessage>> _replySuggestion = ValueNotifier(
    [],
  );

  /// newSuggestions as [ValueListenable] for `SuggestionList` widget's
  /// [ValueListenableBuilder].
  ///  Use this to listen when suggestion gets added
  ///   ```dart
  ///    chatController.newSuggestions.addListener((){});
  ///  ```
  /// For more functionalities see [ValueListenable].
  ValueListenable<List<ChatReplyMessage>> get newSuggestions =>
      _replySuggestion;

  /// Used to add reply suggestions.
  void addReplySuggestions(List<ChatReplyMessage> suggestions) =>
      _replySuggestion.value = suggestions;

  /// Used to remove reply suggestions.
  void removeReplySuggestions() => _replySuggestion.value = [];

  /// Used to add message in message list.
  void addMessage(ChatMessage message) {
    // PagingState(
    //   keys: pagingController.keys,
    //   pages: pagingController.pages?.map((page) => [message, ...page]).toList(),
    //   hasNextPage: pagingController.hasNextPage,
    //   error: pagingController.error,
    //   isLoading: pagingController.isLoading,
    // )
    pagingController.value = pagingController.value.copyWith(
      pages: pagingController.pages?.map((page) => [message, ...page]).toList(),
    );
  }

  void updateMessage(ChatMessage message) {
    try {
      // List<ChatMessage> messages = List<ChatMessage>.of(
      //   pagingController.items ?? [],
      // );
      // final index = messages.indexOf(message);
      // messages[index] = message;
      // final pages = pagingController.pages
      //     ?.map((page) => [...messages])
      //     .toList();
      // pagingController.value = pagingController.value.copyWith(pages: pages);
      pagingController.mapItems(
        (item) => item.copyWith(status: message.status),
      );
    } catch (e) {
      log('error: $e');
    }
  }

  List<ChatMessage> get initialMessageList =>
      pagingController.pages?.expand((page) => page).toList() ?? [];

  /// Function for setting reaction on specific chat bubble
  void setReaction({
    required String emoji,
    required String messageId,
    required String userId,
  }) {
    final message = initialMessageList.firstWhereOrNull(
      (message) => message.id == messageId,
    );
    if (message == null) throw Exception('Message Not Found!');
    final reactedUserIds = message.reactedUserIds;
    final indexOfMessage = initialMessageList.indexOf(message);
    final userIndex = reactedUserIds.indexOf(userId);
    if (userIndex != -1) {
      if (message.reactions[userIndex].reaction == emoji) {
        message.reactions.removeAt(userIndex);
      } else {
        message.reactions[userIndex].reaction = emoji;
      }
    } else {
      message.reactions.add(ChatReaction(reaction: emoji, userId: userId));
    }
    initialMessageList[indexOfMessage] = ChatMessage(
      id: messageId,
      message: message.message,
      createdAt: message.createdAt,
      senderId: message.senderId,
      replyMessage: message.replyMessage,
      reactions: message.reactions,
      type: message.type,
      status: message.status,
    );
    pagingController.value = pagingController.value.copyWith(
      pages: pagingController.pages?.map((page) => [message, ...page]).toList(),
    );
  }

  /// Function to scroll to last messages in chat view
  void scrollToLastMessage() => Timer(Duration(milliseconds: 100), () {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.positions.last.minScrollExtent,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 100),
    );
  });

  /// Function for getting ChatUser object from user id
  ChatUser getUserFromId(String userId) {
    final user = userId == currentUser.id ? currentUser : _otherUsers[userId];
    if (user == null) throw Exception('User with ID $userId not found!');
    return user;
  }

  /// Function for updating the details of an existing user (other users).
  ///
  /// **Parameters:**
  /// - (required): [chatUser] The updated `ChatUser` object containing new
  /// user details.
  void updateOtherUser(ChatUser chatUser) =>
      _otherUsers[chatUser.id] = chatUser;

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
    _showTypingIndicator.dispose();
    _replySuggestion.dispose();
    scrollController.dispose();
    pagingController.dispose();
    messageController.dispose();
  }
}
