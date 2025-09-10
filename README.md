# ChatUI

A flexible, Chat UI package for Flutter. Build modern chat experiences with infinite scrolling, message grouping, reactions, attachments, link previews, and a fully themable interface.

- **Widgets**: `ChatUi`, `ChatBubble`, input composer
- **State**: `ChatController` to add/update messages, scroll control, input visibility
- **Models**: `ChatMessage`, `ChatUser`, `ChatAttachment`, `ChatReaction`, `ChatMessageStatus`, `ChatMessageType`
- **Paging**: Built on `infinite_scroll_pagination` for smooth, reverse list loading
- **Theming**: `ChatTheme` and `ChatUiConfig` for deep customization
- **Utilities**: Markdown input, image/file picker helpers, debouncer, downloader

## Features

- **Plug-and-play** `ChatUi` widget
- **Infinite scroll** with reverse list and date headers
- **Message composer** with markdown, emoji-ready, and send/attach hooks
- **Attachments**: images, documents, and custom via `ChatController`
- **Message statuses**: pending/sent/delivered/seen (icons included)
- **Reactions** and reply support in the message model
- **Jump to bottom** FAB with viewport-aware visibility
- **Theming**: presets (light/dark) and granular overrides; auto-derive from Material theme

## Early release ⚠️

`This is an early release of the package. It is still under development and may change significantly. So, please use it with caution.`

## Getting started

1. Add dependency in your `pubspec.yaml`:

```yaml
dependencies:
  chatui: ^0.0.1
```

2. Ensure required assets are available (already bundled when using the package):

- `assets/images/PENDING.png`, `SENT.png`, `DELIVERED.png`, `SEEN.png`
- `assets/images/image.png` (default wallpaper)

3. Initialize the package once in `main()`:

```dart
import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeChatUI();
  runApp(const MyApp());
}
```

If you forget to initialize, the UI will show a helpful error with instructions.

## Usage

### Minimal example

```dart
import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';

class MyChatPage extends StatefulWidget {
  const MyChatPage({super.key});
  @override
  State<MyChatPage> createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  late final PagingController<int, ChatMessage> paging;
  late final ChatController controller;
  final currentUser = ChatUser(id: 'u1', name: 'You');

  @override
  void initState() {
    super.initState();
    paging = PagingController<int, ChatMessage>(
      getNextPageKey: (state) => null, // provide your paging key logic
      fetchPage: (pageKey) => <ChatMessage>[], // fetch messages here
    );

    controller = ChatController(
      scrollController: ScrollController(),
      otherUsers: const [],
      currentUser: currentUser,
      pagingController: paging,
      focusNode: FocusNode(),
    );

    // Optionally handle callbacks
    controller.onMessageAdded = (msg) async {
      // Call your API to send message
    };
  }

  @override
  void dispose() {
    paging.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ChatUi(controller: controller),
    );
  }
}
```

### Sending messages

- Programmatically add a text message:

```dart
await controller.addMessage(
  ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    message: 'Hello world',
    type: ChatMessageType.chat,
    senderId: controller.currentUser.id,
    roomId: 'room-1',
    chatStatus: ChatMessageStatus.pending,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
);
```

- Update an existing message:

```dart
await controller.updateMessage(
  message.copyWith(
    message: 'Edited message',
    editedAt: DateTime.now(),
  ),
);
```

### Attachments

Use built-ins or your own picker:

```dart
// Use default helpers
await controller.pickAndSendImageFromGallery();
await controller.pickAndSendImageFromCamera();
await controller.pickAndSendFile();

// Or send your own attachment object
await controller.sendAttachmentMessage(
  ChatAttachment(
    fileName: 'report.pdf',
    fileSize: 1024 * 120,
    mimeType: 'application/pdf',
    // file / bytes source per your flow
  ),
);
```

### Paging and scrolling

- Provide `PagingController<int, ChatMessage>` with your `fetchPage` logic
- The list is `reverse: true`; newest at bottom
- Call `controller.scrollToLastMessage()` to jump to bottom

### Theming

Quick presets or full control via `ChatTheme` and `ChatUiConfig`.

```dart
ChatUi(
  controller: controller,
  config: ChatUiConfig(
    theme: ChatTheme.fromMaterialTheme(Theme.of(context)),
  ),
)
```

See advanced options and examples in [`THEME_CUSTOMIZATION.md`](THEME_CUSTOMIZATION.md).

## API surface

- **Initialize**: `initializeChatUI({bool isDebug = true})`
- **Widget**: `ChatUi(controller: ..., config: ChatUiConfig(...))`
- **Controller**: `ChatController`
  - `addMessage`, `updateMessage`, `scrollToLastMessage`
  - `pickAndSendImageFromGallery`, `pickAndSendImageFromCamera`, `pickAndSendFile`
  - `sendAttachmentMessage`
  - `toggleInputField`, `showInputField`
  - `otherUsers`, `currentUser`, `messages`
- **Models**: `ChatMessage`, `ChatUser`, `ChatAttachment`, `ChatReaction`, `ChatReplyMessage`
- **Enums**: `ChatMessageStatus`, `ChatMessageType`

## Example app

A runnable sample is available under [`example/`](example/). It demonstrates Supabase initialization, Riverpod-driven controller creation, paging setup, theming, and the core `ChatUi` widget.

### Example (Supabase + Riverpod)

Key excerpts from the example app to mirror the setup.

Main entry (`example/lib/main.dart`):

```dart
import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  initializeChatUI();
  runApp(MaterialApp(home: ChatPage(roomId: 'room-1')));
}

class ChatPage extends HookConsumerWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});
  // ... uses chatControllerXProvider to get a ChatController and renders ChatUi
}
```

Using the `ChatController` from a Riverpod provider and passing it to `ChatUi`:

```dart
// inside ChatPage build → snapshot.when(...)
return ChatUi(
  controller: controller,
  config: ChatUiConfig(
    scaffold: ChatExtra.scaffoldConfig(context),
    theme: ChatExtra.chatTheme(context),
    customMessage: (controller, message, index) => CustomChatCard(
      controller: controller,
      message: message,
      index: index,
    ),
  ),
);
```

Provider that constructs `ChatController` (`example/lib/provider.dart`):

```dart
@riverpod
Future<ChatController?> chatControllerX(
  Ref ref, {
  required String roomId,
  required FocusNode focusNode,
  required ScrollController scrollController,
}) async {
  try {
    const pageSize = 100;
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final roomCurrentUser = ChatUser(
      id: currentUser?.id ?? '',
      name: currentUser?.email ?? '',
    );
    if (currentUser == null) {
      return null;
    }
    final room = await supabase
        .from('rooms')
        .select('*')
        .eq('id', roomId)
        .single();
    final pagingController = PagingController<int, ChatMessage>(
      getNextPageKey: (state) {
        final keys = state.keys ?? [];
        final pages = state.pages;
        if (keys.isEmpty) return 0;
        if (pages != null && pages.last.length < pageSize) return null;
        return keys.last + 1;
      },
      fetchPage: (pageKey) async {
        final queries = supabase
            .from('messages')
            .select('*, sender:messages_room_member_fk(*)')
            .eq('room_id', roomId)
            .order('created_at', ascending: false)
            .range(pageKey, pageKey + pageSize - 1)
            .limit(pageSize);
        final data = await queries;
        if (data == null || data.isEmpty) {
          throw Exception('No data found');
        }
        return data.map((e) => ChatMessageMapper.fromMap(e)).toList();
      },
    );
    final controller = ChatController(
      scrollController: scrollController,
      currentUser: roomCurrentUser,
      otherUsers: const [],
      pagingController: pagingController,
      focusNode: focusNode,
    );
    controller.uuidGenerator = () => Uuid().v4();
    controller.onMessageAdded = (message) async {
      // call your api to send message
    };
    controller.onMarkAsSeen = (message) async {
      // call your api to mark message as seen
    };
    controller.setRoom(room);
    controller.onTapCamera = () async {
      // custom camera action
    };
    return controller;
  } catch (e) {
    return null;
  }
}
```

Optional theming and background helpers used in the example:

```dart
class ChatExtra {
  static ScaffoldConfig scaffoldConfig(BuildContext context) => ScaffoldConfig(
    background: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            ImageWrapper(imageId: 'chat-background-1.png', bucketId: 'assets')
                    .toSupabaseUrl ??
                'https://web.whatsapp.com/img/bg-chat-tile-dark_a4be512e7195b6b733d9110b408f075d.png',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            context.colors.neutral100,
            BlendMode.exclusion,
          ),
          alignment: Alignment.center,
          opacity: 0.6,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
        color: context.colors.backgroundPrimary,
      ),
    ),
  );

  static ChatTheme chatTheme(BuildContext context) =>
      ChatTheme.fromMaterialTheme(context.theme).copyWith(
        inputTextStyle: context.bodyMedium.copyWith(
          color: context.colors.contentPrimary,
        ),
        receivedMessageTextStyle: context.bodyMedium.copyWith(
          color: context.colors.contentPrimary,
        ),
        timestampColor: context.colors.onSurfaceVariant,
        attachmentButtonColor: context.colors.borderInverseOpaque,
        sentMessageTextStyle: context.bodyMedium.copyWith(
          color: context.colors.contentInversePrimary,
        ),
      );
}
```

Note: The Supabase schema and authentication flow are out of scope for this package; the example assumes you already have `rooms` and `messages` tables and an authenticated user.

## FAQ

- **I see an initialization error in the UI.**
  Call `initializeChatUI()` in `main()` before running the app.

- **Do I have to use the built-in pickers?**
  No. Use your own flow and call `sendAttachmentMessage` with a `ChatAttachment`.

- **How do I customize the look?**
  Use `ChatTheme` and `ChatUiConfig`, or start with `ChatTheme.light()` / `ChatTheme.dark()` and `copyWith`.

## Contributing

Issues and PRs are welcome. Please run format/lints and include screenshots/GIFs for UI changes.

## License

This project is available under the terms of the license in [`LICENSE`](LICENSE).
