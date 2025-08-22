# ChatUI API Documentation

A comprehensive, production-ready Flutter chat UI package with advanced features including threading, polls, contact sharing, and smooth animations.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Components](#core-components)
- [Advanced Features](#advanced-features)
- [Theming & Customization](#theming--customization)
- [Performance](#performance)
- [Error Handling](#error-handling)
- [API Reference](#api-reference)

## Installation

Add `chatui` to your `pubspec.yaml`:

```yaml
dependencies:
  chatui: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Setup

```dart
import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatController controller;

  @override
  void initState() {
    super.initState();

    // Create users
    final currentUser = ChatUser(
      id: ChatUserId('current_user'),
      displayName: 'You',
      avatarUrl: 'https://example.com/avatar.jpg',
      isOnline: true,
    );

    // Initialize controller with adapter
    controller = ChatController(
      adapter: InMemoryChatAdapter(currentUser: currentUser),
      currentUser: currentUser,
      channelId: ChannelId('chat_channel'),
    );

    // Attach streams
    controller.attach();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: ChatView(
        controller: controller,
        theme: ChatThemeData.light(), // or ChatThemeData.dark()
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

### With Performance Optimization

```dart
// Use performance-enhanced controller for better performance
controller = PerformanceEnhancedChatController(
  adapter: YourCustomAdapter(currentUser: currentUser),
  currentUser: currentUser,
  channelId: ChannelId('chat_channel'),
);

// Wrap with performance monitoring
Widget build(BuildContext context) {
  return PerformanceMonitor(
    child: ChatView(
      controller: controller,
      theme: ChatThemeData.light(),
    ),
  );
}
```

## Core Components

### ChatController

The main controller that orchestrates chat functionality.

```dart
class ChatController extends ChangeNotifier {
  // Core properties
  final ValueNotifier<List<Message>> messages;
  final ValueNotifier<TypingState> typing;
  final ValueNotifier<Channel?> channel;

  // Threading
  final ValueNotifier<List<Thread>> threads;
  final ValueNotifier<Thread?> activeThread;

  // Methods
  Future<void> sendText(String text);
  Future<void> toggleReaction(Message message, String emoji);
  void setReplyTo(Message message);
  Future<void> editMessageText(Message message, String newText);
  Future<void> deleteMessage(Message message);

  // Threading methods
  Future<Thread> createThread({required Message originalMessage, required String title});
  Future<ThreadMessage> sendThreadMessage({required String threadId, required String content});
  void openThread(Thread thread);
  void closeActiveThread();
}
```

### ChatView

The main chat interface widget.

```dart
ChatView({
  required ChatController controller,
  ChatThemeData? theme,
  bool enableAnimations = true,
  ScrollController? scrollController,
  Widget Function(ChatError)? errorBuilder,
})
```

### MessageBubble

Individual message display widget with animations.

```dart
MessageBubble({
  required Message message,
  required bool isMe,
  required ChatController controller,
  bool enableAnimations = true,
  int? animationIndex,
})
```

### Composer

Message input widget with attachments support.

```dart
Composer({
  required ChatController controller,
  bool enableAnimations = true,
})
```

## Advanced Features

### Threading System

Create and manage threaded conversations:

```dart
// Create a thread
final thread = await controller.createThread(
  originalMessage: message,
  title: 'Discussion Thread',
  description: 'Let\'s discuss this topic',
  priority: ThreadPriority.high,
);

// Send message in thread
await controller.sendThreadMessage(
  threadId: thread.id,
  content: 'This is a threaded message',
  type: ThreadMessageType.text,
);

// Open thread view
controller.openThread(thread);
```

### Polls & Voting

Create interactive polls:

```dart
// Create a poll
final poll = Poll(
  id: 'poll_1',
  question: 'What\'s your favorite color?',
  options: [
    PollOption(id: 'red', text: 'Red'),
    PollOption(id: 'blue', text: 'Blue'),
    PollOption(id: 'green', text: 'Green'),
  ],
  settings: PollSettings(
    allowMultipleChoices: false,
    isAnonymous: true,
    deadline: DateTime.now().add(Duration(days: 1)),
  ),
);

// Use PollCreator widget
final poll = await PollCreator.show(context: context);
```

### Contact Sharing

Share and display contact information:

```dart
// Share a contact
final contact = Contact(
  displayName: 'John Doe',
  phoneNumbers: ['+1234567890'],
  emailAddresses: ['john@example.com'],
);

final contactAttachment = ContactAttachment(
  contact: contact,
  timestamp: DateTime.now(),
);

controller.addAttachment(contactAttachment.toAttachment());
```

### Reactions

Add emoji reactions to messages:

```dart
// Toggle reaction
await controller.toggleReaction(message, '👍');

// Use reaction picker
await EnhancedReactionPicker.show(
  context,
  onEmojiSelected: (emoji) {
    controller.toggleReaction(message, emoji);
  },
);
```

## Theming & Customization

### Professional Themes

```dart
// Light theme
ChatThemeData.light()

// Dark theme
ChatThemeData.dark()

// Custom theme
ChatThemeData(
  incomingBubbleColor: Colors.grey[200]!,
  outgoingBubbleColor: Colors.blue,
  incomingTextColor: Colors.black,
  outgoingTextColor: Colors.white,
  messageTextStyle: TextStyle(fontSize: 16),
  bubbleRadius: 16,
  enableBubbleShadows: true,
  enableScaleAnimations: true,
  messageAnimationDuration: Duration(milliseconds: 250),
)
```

### Animation Configuration

```dart
// Design tokens for consistent animations
ChatDesignTokens.fastAnimation     // 150ms
ChatDesignTokens.normalAnimation   // 250ms
ChatDesignTokens.slowAnimation     // 350ms

// Animation curves
ChatDesignTokens.defaultCurve      // easeInOutCubic
ChatDesignTokens.bounceCurve       // elasticOut
ChatDesignTokens.smoothCurve       // easeOutQuart
```

### Custom Message Types

```dart
// Extend MessageKind for custom types
enum CustomMessageKind {
  payment,
  calendar,
  voice,
}

// Create custom message tile
class PaymentMessageTile extends StatelessWidget {
  final PaymentData payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, color: Colors.green),
          Text('Payment: \$${payment.amount}'),
          Text('To: ${payment.recipient}'),
        ],
      ),
    );
  }
}
```

## Performance

### Optimization Features

- **Lazy Loading**: Messages loaded on demand
- **Message Caching**: Smart caching with LRU eviction
- **Image Optimization**: Automatic resizing and caching
- **Memory Management**: Automatic cleanup and monitoring
- **Batched Operations**: Reduced UI updates
- **Throttled Typing**: Optimized typing indicators

### Performance Monitoring

```dart
// Enable performance monitoring
PerformanceMonitor(
  enabled: true,
  child: ChatView(controller: controller),
)

// Get performance stats
final stats = controller.getPerformanceStats();
print('Memory usage: ${stats['memoryStats']['usagePercentage']}%');
```

### Memory Optimization

```dart
// Configure performance settings
final controller = PerformanceEnhancedChatController(
  adapter: adapter,
  currentUser: currentUser,
  channelId: channelId,
);

// Manual optimization
controller.optimizeMemory();
```

## Error Handling

### Error Boundaries

```dart
ChatErrorBoundary(
  child: ChatView(controller: controller),
  onError: (error) {
    print('Chat error: ${error.message}');
  },
  errorBuilder: (error) => CustomErrorWidget(error),
)
```

### Network Error Handling

```dart
// Initialize network service
final networkService = NetworkErrorService();
networkService.initialize();

// Execute with retry
final result = await networkService.executeWithRetry(
  operationId: 'send_message',
  operation: () => sendMessage(text),
  config: RetryConfig.chat,
);

if (result.isSuccess) {
  print('Message sent successfully');
} else {
  print('Failed to send message: ${result.error?.userMessage}');
}
```

### Error Types

```dart
// Network errors
ChatError.network(message: 'Connection failed');

// Authentication errors
ChatError.authentication(message: 'Invalid credentials');

// Permission errors
ChatError.permission(message: 'Camera access required');

// Validation errors
ChatError.validation(message: 'Invalid message format');
```

## API Reference

### Models

#### Message

```dart
class Message {
  final MessageId id;
  final ChatUser author;
  final MessageKind kind;
  final String? text;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime? editedAt;
  final MessageId? replyTo;
  final Map<String, ReactionSummary> reactions;
  final List<MessageEdit> editHistory;
}
```

#### ChatUser

```dart
class ChatUser {
  final ChatUserId id;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final UserStatus status;
}
```

#### Thread

```dart
class Thread {
  final String id;
  final String title;
  final String? description;
  final String originalMessageId;
  final String createdBy;
  final DateTime createdAt;
  final List<ThreadMessage> messages;
  final List<ThreadParticipant> participants;
  final ThreadPriority priority;
  final ThreadSettings settings;
}
```

#### Poll

```dart
class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final PollSettings settings;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, PollVote> votes;
}
```

### Services

#### PerformanceService

- Message caching with LRU eviction
- Image optimization and caching
- Memory usage tracking
- Lazy loading state management

#### ErrorHandlingService

- Centralized error handling
- Error categorization and logging
- Error history and statistics
- Recovery mechanisms

#### NetworkErrorService

- Network connectivity monitoring
- Retry logic with exponential backoff
- Operation queuing for offline scenarios
- Connection state management

#### ThreadService

- Thread creation and management
- Message threading
- Participant management
- Thread statistics and search

### Widgets

#### Core Widgets

- `ChatView`: Main chat interface
- `MessageBubble`: Individual message display
- `Composer`: Message input interface
- `MessageListView`: Optimized message list
- `TypingIndicator`: Real-time typing status

#### Utility Widgets

- `ScrollToBottomButton`: Smart scroll button with unread count
- `ChatErrorBoundary`: Error handling wrapper
- `PerformanceMonitor`: Performance monitoring
- `NetworkAwareWidget`: Network state awareness

#### Specialized Widgets

- `PollMessageTile`: Poll display and voting
- `ContactMessageTile`: Contact information display
- `ThreadView`: Threaded conversation interface
- `EnhancedReactionPicker`: Emoji reaction interface
- `AttachmentPicker`: File attachment selection

### Adapters

#### ChatAdapter Interface

```dart
abstract class ChatAdapter {
  Stream<List<Message>> watchMessages(ChannelId channelId);
  Stream<TypingState> watchTyping(ChannelId channelId);
  Stream<Channel> watchChannel(ChannelId channelId);

  Future<void> sendMessage(ChannelId channelId, Message message);
  Future<void> editMessage(ChannelId channelId, MessageId messageId, {String? text, List<Attachment>? attachments});
  Future<void> deleteMessage(ChannelId channelId, MessageId messageId, {bool hard = false});
  Future<void> react(ChannelId channelId, MessageId messageId, String key, {required bool add});
  Future<void> markTyping(ChannelId channelId, {required bool isTyping});
  Future<void> markRead(ChannelId channelId, MessageId messageId);
}
```

#### InMemoryChatAdapter

Built-in adapter for development and testing:

```dart
final adapter = InMemoryChatAdapter(currentUser: currentUser);
```

### Constants

#### Design Tokens

- Animation durations and curves
- Spacing scale (2px to 32px)
- Border radius scale (4px to 24px)
- Shadow elevations (2dp to 12dp)

#### Message Kinds

- `text`: Plain text messages
- `image`: Image attachments
- `audio`: Audio messages
- `location`: Location sharing
- `poll`: Interactive polls
- `contact`: Contact information
- `thread`: Threaded messages

#### Error Types

- `network`: Network connectivity issues
- `authentication`: Authentication failures
- `permission`: Permission requirements
- `validation`: Input validation errors
- `storage`: Storage/persistence issues
- `attachment`: File processing errors
- `unknown`: Unspecified errors

This documentation provides a comprehensive guide to using the ChatUI package. For more detailed examples and advanced usage patterns, see the implementation guides and examples.
