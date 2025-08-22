import 'package:flutter/material.dart';
import 'package:chatui/chatui.dart';

void main() {
  runApp(const TestFixApp());
}

class TestFixApp extends StatelessWidget {
  const TestFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatUI Test Fix',
      home: const TestChatPage(),
    );
  }
}

class TestChatPage extends StatefulWidget {
  const TestChatPage({super.key});

  @override
  State<TestChatPage> createState() => _TestChatPageState();
}

class _TestChatPageState extends State<TestChatPage> {
  late ChatController controller;

  @override
  void initState() {
    super.initState();
    
    final currentUser = ChatUser(
      id: const ChatUserId('test_user'),
      displayName: 'Test User',
      isOnline: true,
    );

    controller = ChatController(
      adapter: InMemoryChatAdapter(currentUser: currentUser),
      currentUser: currentUser,
      channelId: const ChannelId('test_channel'),
    );
    
    controller.attach();
    
    // Add a test message
    final message = Message(
      id: const MessageId('test_msg'),
      author: currentUser,
      kind: MessageKind.text,
      text: 'Test message to verify inheritance widget fix',
      createdAt: DateTime.now(),
    );
    
    controller.adapter.sendMessage(const ChannelId('test_channel'), message);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatUI Fix Test'),
      ),
      body: ChatTheme(
        data: ChatThemeData.light(),
        child: ChatView(controller: controller),
      ),
    );
  }
}