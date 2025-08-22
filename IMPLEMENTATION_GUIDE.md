# ChatUI Implementation Guide

Complete implementation guides and practical examples for integrating the ChatUI package into your Flutter applications.

## Table of Contents

- [Quick Setup](#quick-setup)
- [Custom Adapters](#custom-adapters)
- [Advanced Features](#advanced-features)
- [Theming Examples](#theming-examples)
- [Integration Patterns](#integration-patterns)
- [Best Practices](#best-practices)

## Quick Setup

### 1. Basic Chat Implementation

Create a complete chat screen with minimal setup:

```dart
// pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:chatui/chatui.dart';

class ChatPage extends StatefulWidget {
  final String channelId;
  final ChatUser currentUser;
  final ChatUser otherUser;

  const ChatPage({
    super.key,
    required this.channelId,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatController controller;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Create an adapter (using in-memory for demo)
    final adapter = InMemoryChatAdapter(currentUser: widget.currentUser);

    // Initialize controller
    controller = ChatController(
      adapter: adapter,
      currentUser: widget.currentUser,
      channelId: ChannelId(widget.channelId),
    );

    // Attach to start listening to streams
    controller.attach();

    // Add some sample messages for demo
    _addSampleMessages();
  }

  void _addSampleMessages() {
    // This would typically come from your backend
    final messages = [
      Message(
        id: MessageId('1'),
        author: widget.otherUser,
        text: 'Hey! How are you doing?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        kind: MessageKind.text,
        attachments: [],
        reactions: {},
        editHistory: [],
      ),
      Message(
        id: MessageId('2'),
        author: widget.currentUser,
        text: 'I\'m doing great! Thanks for asking 😊',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        kind: MessageKind.text,
        attachments: [],
        reactions: {'👍': ReactionSummary(emoji: '👍', count: 1, userIds: [widget.otherUser.id.value])},
        editHistory: [],
      ),
    ];

    // Add messages to controller (this would be done by your adapter)
    for (final message in messages) {
      controller.messages.value = [...controller.messages.value, message];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUser.avatarUrl != null
                  ? NetworkImage(widget.otherUser.avatarUrl!)
                  : null,
              child: widget.otherUser.avatarUrl == null
                  ? Text(widget.otherUser.displayName[0])
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.otherUser.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.otherUser.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: ChatErrorBoundary(
        child: ChatView(
          controller: controller,
          theme: ChatThemeData.light(),
        ),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat error: ${error.userMessage}')),
          );
        },
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Chat Info'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to chat info page
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('View Threads'),
            onTap: () {
              Navigator.pop(context);
              controller.toggleThreadsView();
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Clear Chat'),
            onTap: () {
              Navigator.pop(context);
              _confirmClearChat();
            },
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear messages
              controller.messages.value = [];
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### 2. App Integration Example

```dart
// main.dart
import 'package:flutter/material.dart';
import 'pages/chat_page.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatUI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatListPage(),
    );
  }
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = ChatUser(
      id: ChatUserId('current_user'),
      displayName: 'You',
      avatarUrl: 'https://example.com/your-avatar.jpg',
      isOnline: true,
    );

    final contacts = [
      ChatUser(
        id: ChatUserId('user_1'),
        displayName: 'Alice Johnson',
        avatarUrl: 'https://example.com/alice.jpg',
        isOnline: true,
      ),
      ChatUser(
        id: ChatUserId('user_2'),
        displayName: 'Bob Smith',
        avatarUrl: 'https://example.com/bob.jpg',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewChatDialog(context, currentUser),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: contact.avatarUrl != null
                  ? NetworkImage(contact.avatarUrl!)
                  : null,
              child: contact.avatarUrl == null
                  ? Text(contact.displayName[0])
                  : null,
            ),
            title: Text(contact.displayName),
            subtitle: Text(
              contact.isOnline
                  ? 'Online'
                  : 'Last seen ${_formatLastSeen(contact.lastSeen)}',
            ),
            trailing: contact.isOnline
                ? const Icon(Icons.circle, color: Colors.green, size: 12)
                : null,
            onTap: () => _openChat(context, currentUser, contact),
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, ChatUser currentUser, ChatUser contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          channelId: 'channel_${currentUser.id.value}_${contact.id.value}',
          currentUser: currentUser,
          otherUser: contact,
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, ChatUser currentUser) {
    // Implementation for creating new chats
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: const Text('New chat functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Long time ago';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
```

## Custom Adapters

### 1. Firebase Adapter Example

```dart
// adapters/firebase_chat_adapter.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatui/chatui.dart';

class FirebaseChatAdapter implements ChatAdapter {
  final FirebaseFirestore _firestore;
  final ChatUser currentUser;

  FirebaseChatAdapter({
    required this.currentUser,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Message>> watchMessages(ChannelId channelId) {
    return _firestore
        .collection('channels')
        .doc(channelId.value)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _messageFromFirestore(doc))
            .toList());
  }

  @override
  Stream<TypingState> watchTyping(ChannelId channelId) {
    return _firestore
        .collection('channels')
        .doc(channelId.value)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
      final typingUsers = <ChatUser>[];
      for (final doc in snapshot.docs) {
        if (doc.data()['isTyping'] == true &&
            doc.id != currentUser.id.value) {
          // Convert doc to ChatUser
          typingUsers.add(_userFromFirestore(doc));
        }
      }
      return TypingState(users: typingUsers);
    });
  }

  @override
  Future<void> sendMessage(ChannelId channelId, Message message) async {
    final messageData = _messageToFirestore(message);

    await _firestore
        .collection('channels')
        .doc(channelId.value)
        .collection('messages')
        .doc(message.id.value)
        .set(messageData);

    // Update channel's last message
    await _firestore
        .collection('channels')
        .doc(channelId.value)
        .update({
      'lastMessage': messageData,
      'lastActivity': FieldValue.serverTimestamp(),
    });
  }

  // Additional methods and helper functions...
  // (Implementation continues with other required methods)
}
```

### 2. WebSocket Adapter Example

```dart
// adapters/websocket_chat_adapter.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chatui/chatui.dart';

class WebSocketChatAdapter implements ChatAdapter {
  final String wsUrl;
  final String authToken;
  final ChatUser currentUser;

  WebSocketChannel? _channel;
  final StreamController<List<Message>> _messagesController =
      StreamController.broadcast();
  final StreamController<TypingState> _typingController =
      StreamController.broadcast();

  final List<Message> _messageCache = [];

  WebSocketChatAdapter({
    required this.wsUrl,
    required this.authToken,
    required this.currentUser,
  });

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?token=$authToken'),
      );

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Send authentication
      _sendMessage({
        'type': 'auth',
        'token': authToken,
        'userId': currentUser.id.value,
      });
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }

  @override
  Stream<List<Message>> watchMessages(ChannelId channelId) {
    // Join channel
    _sendMessage({
      'type': 'join_channel',
      'channelId': channelId.value,
    });

    return _messagesController.stream;
  }

  @override
  Future<void> sendMessage(ChannelId channelId, Message message) async {
    _sendMessage({
      'type': 'send_message',
      'channelId': channelId.value,
      'message': _messageToJson(message),
    });
  }

  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data);

      switch (message['type']) {
        case 'message_received':
          _handleNewMessage(message['data']);
          break;
        case 'typing_update':
          _handleTypingUpdate(message['data']);
          break;
        case 'message_edited':
          _handleMessageEdit(message['data']);
          break;
        case 'message_deleted':
          _handleMessageDelete(message['data']);
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final message = _messageFromJson(data);
    _messageCache.add(message);
    _messagesController.add(List.from(_messageCache));
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  // Additional implementation methods...
}
```

Continue reading [IMPLEMENTATION_GUIDE_PART2.md](IMPLEMENTATION_GUIDE_PART2.md) for advanced features, theming, and best practices.
