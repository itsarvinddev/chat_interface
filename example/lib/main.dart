import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
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
  late final PagingController<int, ChatMessage> _svc;
  // User data
  final List<ChatUser> _otherUsers = [];
  ChatUser? _currentUser;
  List<ChatUser> allUsers = [];
  late ChatController _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _svc = PagingController<int, ChatMessage>(
      getNextPageKey: (PagingState<int, ChatMessage> state) {
        return null;
      },
      fetchPage: (int pageKey) {
        return [];
      },
    );
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _controller = ChatController(
      scrollController: _scrollController,
      otherUsers: _otherUsers,
      currentUser: _currentUser ?? allUsers.first,
      pagingController: _svc,
      focusNode: _focusNode,
    );
  }

  @override
  void dispose() {
    _svc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _themeMode.value = value == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
              });
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          body: ChatUi(controller: _controller),
        ),
      ),
    );
  }
}

extension CamelCaseToSnakeCase on Map<String, dynamic> {
  Map<String, dynamic> toSnakeCase() {
    return map(
      (key, value) => MapEntry(
        key
            .replaceAllMapped(
              RegExp(r'[A-Z]'),
              (Match match) => '_${match.group(0)}',
            )
            .toLowerCase(),
        value,
      ),
    );
  }
}
