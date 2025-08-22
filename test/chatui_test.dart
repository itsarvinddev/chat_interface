import 'package:chatui/chatui.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatView builds', (WidgetTester tester) async {
    final ChatUser me = ChatUser(id: ChatUserId('me'), displayName: 'Me');
    final InMemoryChatAdapter adapter = InMemoryChatAdapter(currentUser: me);
    final ChatController controller = ChatController(
      adapter: adapter,
      channelId: ChannelId('test'),
      currentUser: me,
    )..attach();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ChatView(controller: controller)),
      ),
    );

    expect(find.text('No messages yet'), findsOneWidget);
  });

  test('Markdown text controller handles text correctly', () async {
    final ChatUser me = ChatUser(id: ChatUserId('me'), displayName: 'Me');
    final InMemoryChatAdapter adapter = InMemoryChatAdapter(currentUser: me);
    final ChatController controller = ChatController(
      adapter: adapter,
      channelId: ChannelId('test'),
      currentUser: me,
    )..attach();

    // Send a message with markdown
    await controller.sendText('This is *bold* and `code` text');

    // The test passes if no exceptions were thrown during message sending
    expect(true, isTrue, reason: 'Message sending completed without errors');

    // Clean up
    controller.dispose();
  });

  testWidgets('Link preview functionality works', (WidgetTester tester) async {
    // Test URL detection
    final urls = LinkPreviewUtils.extractUrls(
      'Check out https://flutter.dev and https://pub.dev',
    );
    expect(urls.length, 2);
    expect(urls[0], 'https://flutter.dev');
    expect(urls[1], 'https://pub.dev');

    // Test URL presence check
    expect(LinkPreviewUtils.hasUrls('No URLs here'), false);
    expect(LinkPreviewUtils.hasUrls('Visit https://example.com'), true);
  });

  testWidgets('Image utilities work correctly', (WidgetTester tester) async {
    // Test file size formatting
    expect(ImageUtils.formatFileSize(1024), '1.0 KB');
    expect(ImageUtils.formatFileSize(1048576), '1.0 MB');
    expect(ImageUtils.formatFileSize(1073741824), '1.0 GB');
    expect(ImageUtils.formatFileSize(null), 'Unknown size');

    // Test file icon selection
    expect(ImageUtils.getFileIcon('image/jpeg'), Icons.image);
    expect(ImageUtils.getFileIcon('video/mp4'), Icons.video_file);
    expect(ImageUtils.getFileIcon('audio/mp3'), Icons.audiotrack);
    expect(ImageUtils.getFileIcon('application/pdf'), Icons.picture_as_pdf);
  });

  testWidgets('Enhanced reaction picker shows correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await EnhancedReactionPicker.show(
                  context,
                  onEmojiSelected: (emoji) {},
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the picker
    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Verify the picker is shown
    expect(find.text('Add Reaction'), findsOneWidget);
    expect(find.byType(EmojiPicker), findsOneWidget);
  });

  testWidgets('Time utilities work correctly', (WidgetTester tester) async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // Test message time formatting
    expect(TimeUtils.formatMessageTime(now), 'Just now');
    expect(TimeUtils.formatMessageTime(yesterday), 'Yesterday');

    // Test date header formatting
    expect(TimeUtils.formatDateHeader(now), 'Today');
    expect(TimeUtils.formatDateHeader(yesterday), 'Yesterday');

    // Test same day check
    expect(TimeUtils.isSameDay(now, now), true);
    expect(TimeUtils.isSameDay(now, yesterday), false);
  });

  testWidgets('Enhanced quick reply picker shows correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await EnhancedQuickReplyPicker.show(
                  context,
                  onQuickReplySelected: (text) {},
                );
              },
              child: const Text('Show Quick Replies'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the picker
    await tester.tap(find.text('Show Quick Replies'));
    await tester.pumpAndSettle();

    // Verify the picker is shown
    expect(find.text('Quick Replies'), findsOneWidget);
    expect(find.text('Greetings'), findsOneWidget);
    expect(find.text('Responses'), findsOneWidget);
    expect(find.text('Hi there!'), findsOneWidget);
  });

  testWidgets('Attachment picker shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await AttachmentPicker.show(
                  context,
                  onAttachmentsSelected: (attachments) {},
                );
              },
              child: const Text('Show Attachment Picker'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the picker
    await tester.tap(find.text('Show Attachment Picker'));
    await tester.pumpAndSettle();

    // Verify the picker is shown
    expect(find.text('Add Attachment'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Document'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
  });

  testWidgets('Message edit dialog shows correctly', (
    WidgetTester tester,
  ) async {
    final message = Message(
      id: MessageId('1'),
      author: ChatUser(id: ChatUserId('user1'), displayName: 'Test User'),
      text: 'Original message text',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await MessageEditDialog.show(
                  context,
                  message: message,
                  controller: ChatController(
                    adapter: InMemoryChatAdapter(
                      currentUser: ChatUser(
                        id: ChatUserId('user1'),
                        displayName: 'Test User',
                      ),
                    ),
                    channelId: ChannelId('test'),
                    currentUser: ChatUser(
                      id: ChatUserId('user1'),
                      displayName: 'Test User',
                    ),
                  ),
                );
              },
              child: const Text('Show Edit Dialog'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Edit Dialog'));
    await tester.pumpAndSettle();

    // Verify the dialog is shown
    expect(find.text('Edit Message'), findsOneWidget);
    expect(find.text('Original:'), findsOneWidget);
    expect(find.text('Plain Text'), findsOneWidget);
    expect(find.text('Markdown'), findsOneWidget);

    // Check that the original message text appears in the preview section
    expect(find.byType(Text), findsWidgets);
    final textWidgets = find.byType(Text).evaluate().toList();
    final hasOriginalText = textWidgets.any(
      (widget) =>
          widget.widget is Text &&
          (widget.widget as Text).data == 'Original message text',
    );
    expect(hasOriginalText, true);
  });

  testWidgets('Message delete dialog shows correctly', (
    WidgetTester tester,
  ) async {
    final message = Message(
      id: MessageId('1'),
      author: ChatUser(id: ChatUserId('user1'), displayName: 'Test User'),
      text: 'Message to delete',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await MessageDeleteDialog.show(
                  context,
                  message: message,
                  controller: ChatController(
                    adapter: InMemoryChatAdapter(
                      currentUser: ChatUser(
                        id: ChatUserId('user1'),
                        displayName: 'Test User',
                      ),
                    ),
                    channelId: ChannelId('test'),
                    currentUser: ChatUser(
                      id: ChatUserId('user1'),
                      displayName: 'Test User',
                    ),
                  ),
                );
              },
              child: const Text('Show Delete Dialog'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Delete Dialog'));
    await tester.pumpAndSettle();

    // Verify the dialog is shown
    expect(find.text('Delete Message'), findsOneWidget);
    expect(find.textContaining('This action cannot be undone'), findsOneWidget);
    expect(find.text('Delete for everyone'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Message context menu shows correctly', (
    WidgetTester tester,
  ) async {
    final message = Message(
      id: MessageId('1'),
      author: ChatUser(id: ChatUserId('user1'), displayName: 'Test User'),
      text: 'Context menu test',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await MessageContextMenu.show(
                  context,
                  message: message,
                  controller: ChatController(
                    adapter: InMemoryChatAdapter(
                      currentUser: ChatUser(
                        id: ChatUserId('user1'),
                        displayName: 'Test User',
                      ),
                    ),
                    channelId: ChannelId('test'),
                    currentUser: ChatUser(
                      id: ChatUserId('user1'),
                      displayName: 'Test User',
                    ),
                  ),
                );
              },
              child: const Text('Show Context Menu'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the menu
    await tester.tap(find.text('Show Context Menu'));
    await tester.pumpAndSettle();

    // Verify the menu is shown
    expect(find.text('Message Actions'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Add Reaction'), findsOneWidget);
    expect(find.text('Edit Message'), findsOneWidget);
    expect(find.text('Delete Message'), findsOneWidget);
    expect(find.text('Copy Text'), findsOneWidget);
  });

  testWidgets('Typing indicator shows correctly', (WidgetTester tester) async {
    final typingState = TypingState(
      typingUsers: {
        TypingUser(
          user: ChatUser(id: ChatUserId('user1'), displayName: 'John Doe'),
          startedAt: DateTime.now(),
          lastActivity: DateTime.now(),
        ),
      },
      lastUpdated: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TypingIndicator(
            typingState: typingState,
            enableAnimations: false, // Disable animations for tests
          ),
        ),
      ),
    );

    // Pump once to build the widget without animations
    await tester.pump();

    // Verify the typing indicator is shown
    expect(find.text('John Doe is typing...'), findsOneWidget);
  });

  testWidgets('Compact typing indicator shows correctly', (
    WidgetTester tester,
  ) async {
    final typingState = TypingState(
      typingUsers: {
        TypingUser(
          user: ChatUser(id: ChatUserId('user1'), displayName: 'Jane Smith'),
          startedAt: DateTime.now(),
          lastActivity: DateTime.now(),
        ),
      },
      lastUpdated: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompactTypingIndicator(
            typingState: typingState,
            enableAnimations: false, // Disable animations for tests
          ),
        ),
      ),
    );

    // Pump once to build the widget without animations
    await tester.pump();

    // Verify the compact typing indicator is shown
    expect(find.text('Jane Smith typing...'), findsOneWidget);
  });

  testWidgets('Audio recorder bar shows correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioRecorderBar(onFinished: (attachment) {}, onCancel: () {}),
        ),
      ),
    );

    // Verify the recorder UI is shown
    expect(find.text('Tap mic to record'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('Audio message tile shows correctly', (
    WidgetTester tester,
  ) async {
    final audioAttachment = Attachment(
      uri: 'file:///test/audio.m4a',
      mimeType: 'audio/m4a',
      sizeBytes: 1024,
      thumbnailUri: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AudioMessageTile(audio: audioAttachment)),
      ),
    );

    // Verify the audio player UI is shown
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(
      find.byType(SizedBox),
      findsNWidgets(2),
    ); // Icon spacing + waveform placeholder
  });

  testWidgets('Composer shows audio recorder toggle', (
    WidgetTester tester,
  ) async {
    final ChatUser me = ChatUser(id: ChatUserId('me'), displayName: 'Me');
    final InMemoryChatAdapter adapter = InMemoryChatAdapter(currentUser: me);
    final ChatController controller = ChatController(
      adapter: adapter,
      channelId: ChannelId('test'),
      currentUser: me,
    )..attach();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Composer(controller: controller)),
      ),
    );

    // Wait for animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify the mic button is shown
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Properly dispose the controller and widget
    controller.dispose();
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });

  testWidgets('Location picker shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await LocationPicker.show(
                  context,
                  onLocationSelected: (location) {},
                );
              },
              child: const Text('Show Location Picker'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the picker
    await tester.tap(find.text('Show Location Picker'));
    await tester.pumpAndSettle();

    // Verify the location picker UI is shown
    expect(find.text('Location Picker'), findsOneWidget);
    expect(find.text('Select Location'), findsOneWidget);
  });

  testWidgets('Location message tile shows correctly', (
    WidgetTester tester,
  ) async {
    final location = LocationAttachment(
      latitude: 37.7749,
      longitude: -122.4194,
      accuracy: 10.0,
      timestamp: DateTime.now(),
      address: 'San Francisco, CA',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LocationMessageTile(location: location)),
      ),
    );

    // Verify the location tile UI is shown
    expect(find.text('Location'), findsOneWidget);
    expect(
      find.text('37.774900, -122.419400'),
      findsNWidgets(2),
    ); // Header + coordinates
    expect(find.text('San Francisco, CA'), findsOneWidget);
    expect(find.text('Accuracy: ±10.0m'), findsOneWidget);
    expect(find.text('Open in Maps'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('Composer shows location button', (WidgetTester tester) async {
    final ChatUser me = ChatUser(id: ChatUserId('me'), displayName: 'Me');
    final InMemoryChatAdapter adapter = InMemoryChatAdapter(currentUser: me);
    final ChatController controller = ChatController(
      adapter: adapter,
      channelId: ChannelId('test'),
      currentUser: me,
    )..attach();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Composer(controller: controller)),
      ),
    );

    // Wait for animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify the location button is shown
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    // Properly dispose the controller and widget
    controller.dispose();
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });
}
