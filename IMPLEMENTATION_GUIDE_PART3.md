# ChatUI Implementation Guide - Part 3

## Integration Patterns

### 1. BLoC Integration Example

```dart
// blocs/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatui/chatui.dart';

// Events
abstract class ChatEvent {}
class ChatInitializeEvent extends ChatEvent {
  final String channelId;
  final ChatUser currentUser;
  ChatInitializeEvent({required this.channelId, required this.currentUser});
}
class ChatSendMessageEvent extends ChatEvent {
  final String text;
  ChatSendMessageEvent({required this.text});
}

// States
abstract class ChatState {}
class ChatInitialState extends ChatState {}
class ChatLoadingState extends ChatState {}
class ChatLoadedState extends ChatState {
  final ChatController controller;
  ChatLoadedState({required this.controller});
}
class ChatErrorState extends ChatState {
  final String message;
  ChatErrorState({required this.message});
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatController? _controller;

  ChatBloc() : super(ChatInitialState()) {
    on<ChatInitializeEvent>(_onInitialize);
    on<ChatSendMessageEvent>(_onSendMessage);
  }

  Future<void> _onInitialize(ChatInitializeEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoadingState());
      final adapter = FirebaseChatAdapter(currentUser: event.currentUser);
      _controller = ChatController(
        adapter: adapter,
        currentUser: event.currentUser,
        channelId: ChannelId(event.channelId),
      );
      await _controller!.attach();
      emit(ChatLoadedState(controller: _controller!));
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(ChatSendMessageEvent event, Emitter<ChatState> emit) async {
    if (_controller != null) {
      try {
        await _controller!.sendText(event.text);
      } catch (e) {
        emit(ChatErrorState(message: 'Failed to send message: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
```

### 2. Provider Integration Example

```dart
// providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import 'package:chatui/chatui.dart';

class ChatProvider extends ChangeNotifier {
  ChatController? _controller;
  bool _isLoading = false;
  String? _error;

  ChatController? get controller => _controller;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeChat({
    required String channelId,
    required ChatUser currentUser,
    required ChatAdapter adapter,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _controller = ChatController(
        adapter: adapter,
        currentUser: currentUser,
        channelId: ChannelId(channelId),
      );
      await _controller!.attach();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> sendMessage(String text) async {
    if (_controller == null) return;
    try {
      await _controller!.sendText(text);
    } catch (e) {
      _error = 'Failed to send message: ${e.toString()}';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

## Best Practices

### 1. Error Handling

```dart
// utils/chat_error_handler.dart
import 'package:flutter/material.dart';
import 'package:chatui/chatui.dart';

class ChatErrorHandler {
  static void handleError(BuildContext context, ChatError error, {VoidCallback? onRetry}) {
    String message;
    IconData icon;
    Color color;

    switch (error.type) {
      case ChatErrorType.network:
        message = error.userMessage ?? 'Network connection failed';
        icon = Icons.wifi_off;
        color = Colors.orange;
        break;
      case ChatErrorType.authentication:
        message = error.userMessage ?? 'Authentication failed';
        icon = Icons.lock;
        color = Colors.red;
        break;
      default:
        message = error.userMessage ?? 'An error occurred';
        icon = Icons.error_outline;
        color = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: const Text('RETRY', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Widget buildErrorWidget(ChatError error, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              error.userMessage ?? 'Something went wrong',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 2. Performance Optimization

```dart
// utils/chat_performance_optimizer.dart
import 'package:flutter/material.dart';
import 'package:chatui/chatui.dart';

class ChatPerformanceOptimizer {
  static const int _maxVisibleMessages = 50;

  static Widget optimizedMessageList({
    required List<Message> messages,
    required ChatController controller,
    required ChatThemeData theme,
    ScrollController? scrollController,
  }) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        // Use RepaintBoundary for better performance
        return RepaintBoundary(
          child: MessageBubble(
            message: message,
            isMe: message.author.id == controller.currentUser.id,
            controller: controller,
            enableAnimations: index < _maxVisibleMessages,
            animationIndex: index,
          ),
        );
      },
    );
  }

  static Widget optimizedImageMessage({
    required String imageUrl,
    required Size size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: size.width,
                height: size.height,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size.width,
                height: size.height,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

### 3. Testing Utilities

```dart
// test/utils/chat_test_utils.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chatui/chatui.dart';

class ChatTestUtils {
  static ChatUser createTestUser({
    String id = 'test_user',
    String displayName = 'Test User',
    String? avatarUrl,
    bool isOnline = true,
  }) {
    return ChatUser(
      id: ChatUserId(id),
      displayName: displayName,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
    );
  }

  static Message createTestMessage({
    String id = 'test_message',
    required ChatUser author,
    String text = 'Test message',
    MessageKind kind = MessageKind.text,
    DateTime? createdAt,
  }) {
    return Message(
      id: MessageId(id),
      author: author,
      text: text,
      kind: kind,
      createdAt: createdAt ?? DateTime.now(),
      attachments: [],
      reactions: {},
      editHistory: [],
    );
  }

  static ChatController createTestController({
    required ChatUser currentUser,
    String channelId = 'test_channel',
    List<Message> initialMessages = const [],
  }) {
    final adapter = MockChatAdapter(
      currentUser: currentUser,
      initialMessages: initialMessages,
    );

    return ChatController(
      adapter: adapter,
      currentUser: currentUser,
      channelId: ChannelId(channelId),
    );
  }

  static Future<void> sendTestMessage(WidgetTester tester, String message) async {
    final textField = find.byType(TextField);
    await tester.enterText(textField, message);

    final sendButton = find.byIcon(Icons.send);
    await tester.tap(sendButton);

    await tester.pump();
  }

  static void verifyMessageExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  static void verifyMessageCount(int expectedCount) {
    expect(find.byType(MessageBubble), findsNWidgets(expectedCount));
  }
}
```

### 4. Accessibility Guidelines

```dart
// utils/chat_accessibility.dart
import 'package:flutter/material.dart';
import 'package:chatui/chatui.dart';

class ChatAccessibilityHelper {
  static Widget accessibleMessageBubble({
    required Widget child,
    required Message message,
    required bool isMe,
    VoidCallback? onTap,
  }) {
    final semanticsLabel = _buildMessageSemantics(message, isMe);

    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      onTap: onTap,
      child: ExcludeSemantics(child: child),
    );
  }

  static String _buildMessageSemantics(Message message, bool isMe) {
    final buffer = StringBuffer();

    if (isMe) {
      buffer.write('You said: ');
    } else {
      buffer.write('${message.author.displayName} said: ');
    }

    switch (message.kind) {
      case MessageKind.text:
        buffer.write(message.text ?? '');
        break;
      case MessageKind.image:
        buffer.write('sent an image');
        break;
      case MessageKind.poll:
        buffer.write('created a poll');
        break;
      default:
        buffer.write('sent a message');
    }

    if (message.reactions.isNotEmpty) {
      final reactionCount = message.reactions.values.fold<int>(0, (sum, reaction) => sum + reaction.count);
      buffer.write('. Has $reactionCount reactions');
    }

    return buffer.toString();
  }
}
```

## Configuration Examples

### Environment-Based Configuration

```dart
// config/chat_config.dart
class ChatConfig {
  static const bool enableAnimations = bool.fromEnvironment('CHAT_ANIMATIONS', defaultValue: true);
  static const bool enablePerformanceMonitoring = bool.fromEnvironment('CHAT_PERFORMANCE', defaultValue: false);
  static const int messagePageSize = int.fromEnvironment('CHAT_PAGE_SIZE', defaultValue: 50);
  static const Duration typingTimeout = Duration(seconds: 3);

  static ChatThemeData getTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? ChatThemeData.dark()
        : ChatThemeData.light();
  }
}
```

This implementation guide provides comprehensive examples for integrating ChatUI into production Flutter applications with proper error handling, performance optimization, and accessibility support.
