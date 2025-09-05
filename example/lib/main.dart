import 'dart:developer';

import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_pagination_service.dart';

ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hyycwsqoszrjcznvgyzp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh5eWN3c3Fvc3pyamN6bnZneXpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1NTY5MzEsImV4cCI6MjA3MjEzMjkzMX0._78SdMgC8uWzv4NdiPy0150fz10De3LtwzK-1sAHh0c',
  );
  initializeChatUI();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PagingController<int, ChatMessage> _svc = controller();
  // User data
  List<ChatUser> _otherUsers = [];
  ChatUser? _currentUser;
  bool _isLoadingUsers = true;
  List<ChatUser> allUsers = [];
  late ChatController _controller;

  @override
  void initState() {
    super.initState();
    _loadUsers().then((value) {
      _controller.onMessageAdded = (message) async {
        try {
          final result =
              await Supabase.instance.client.from('chat_messages').insert({
            "message": message.message,
            "sender_id": message.senderId,
            "type": message.type.name,
            "status": ChatMessageStatus.sent.name,
            "room_id": "63e2364b-e0b5-4b30-b392-595944f2955b",
          });
          log(result.toString());
          _controller.updateMessage(
            message.copyWith(chatStatus: ChatMessageStatus.sent),
          );
          return;
        } catch (e) {
          log(e.toString());
          return;
        }
      };
    });
  }

  @override
  void dispose() {
    _svc.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      // Load all users from Supabase
      final usersResponse =
          await Supabase.instance.client.from('chat_users').select('*');

      if (usersResponse.isEmpty) {
        setState(() {
          _isLoadingUsers = false;
        });
        return;
      }

      // Map to ChatUser objects
      allUsers = usersResponse
          .map<ChatUser>(
            (data) => ChatUser(
              id: data['id'] ?? '',
              name: data['name'] ?? '',
              avatar: data['avatar'],
              imageType: ChatImageType.tryParse(data['image_type']) ??
                  ChatImageType.network,
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
              role: ChatUserRole.values.firstWhere(
                (e) => e.name == data['role'],
                orElse: () => ChatUserRole.member,
              ),
              lastReadAt: data['last_read_at'] != null
                  ? DateTime.parse(data['last_read_at'])
                  : DateTime.now(),
            ),
          )
          .toList();
      if (allUsers.isEmpty) {
        setState(() {
          _isLoadingUsers = false;
        });
        return;
      }

      _currentUser = allUsers.first;

      // Remove current user from other users list
      final otherUsers =
          allUsers.where((user) => user.id != _currentUser?.id).toList();

      setState(() {
        _currentUser = _currentUser;
        _otherUsers = otherUsers;
        _isLoadingUsers = false;
        stream(_currentUser ?? allUsers.first, _svc, allUsers);
      });
      _controller = ChatController(
        scrollController: ScrollController(),
        otherUsers: _otherUsers,
        currentUser: _currentUser ?? allUsers.first,
        pagingController: _svc,
      );
    } catch (error) {
      print('Error loading users: $error');
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, value, child) => MaterialApp(
        themeMode: value,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          floatingActionButton: FloatingActionButton.small(
            elevation: 0,
            child: const Icon(Icons.brightness_4),
            onPressed: () {
              setState(() {
                _themeMode.value =
                    value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                _currentUser = allUsers.last;
                _otherUsers = allUsers
                    .where((user) => user.id != _currentUser?.id)
                    .toList();
                stream(_currentUser ?? allUsers.last, _svc, allUsers);
              });
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          body: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _currentUser == null
                  ? const Center(child: Text('No users found'))
                  : ChatUi(controller: _controller),
        ),
      ),
    );
  }
}
