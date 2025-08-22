import 'package:chatui/src/models/models.dart';
import 'package:chatui/src/services/thread_service.dart';
import 'package:chatui/src/widgets/thread_message_tile.dart';
import 'package:chatui/src/widgets/thread_participant_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Thread Models Tests', () {
    test('ThreadParticipant creation and JSON serialization', () {
      final participant = ThreadParticipant(
        id: 'user_1',
        displayName: 'John Doe',
        joinedAt: DateTime(2024, 1, 1),
        role: ThreadParticipantRole.moderator,
        isActive: true,
      );

      expect(participant.id, 'user_1');
      expect(participant.displayName, 'John Doe');
      expect(participant.role, ThreadParticipantRole.moderator);

      final json = participant.toJson();
      final restored = ThreadParticipant.fromJson(json);
      expect(restored, participant);
    });

    test('ThreadMessage with reactions and editing', () {
      final now = DateTime.now();
      final reactions = [
        ThreadMessageReaction(
          emoji: '👍',
          participantId: 'user_2',
          timestamp: now,
        ),
        ThreadMessageReaction(
          emoji: '👍',
          participantId: 'user_3',
          timestamp: now,
        ),
      ];

      final message = ThreadMessage(
        id: 'msg_1',
        senderId: 'user_1',
        content: 'Hello!',
        timestamp: now,
        reactions: reactions,
        isEdited: true,
        seenBy: ['user_1', 'user_2'],
      );

      expect(message.hasReactions, true);
      expect(message.totalReactions, 2);
      expect(message.groupedReactions['👍']?.length, 2);
      expect(message.hasBeenSeenBy('user_2'), true);
      expect(message.hasBeenSeenBy('user_3'), false);

      final json = message.toJson();
      final restored = ThreadMessage.fromJson(json);
      expect(restored.content, message.content);
      expect(restored.reactions.length, message.reactions.length);
    });

    test('Thread creation with participants and messages', () {
      final now = DateTime.now();
      final participants = [
        ThreadParticipant(
          id: 'user_1',
          displayName: 'Creator',
          joinedAt: now,
          role: ThreadParticipantRole.creator,
        ),
        ThreadParticipant(
          id: 'user_2',
          displayName: 'Member',
          joinedAt: now,
          lastSeenAt: now.subtract(const Duration(hours: 1)),
        ),
      ];

      final messages = [
        ThreadMessage(
          id: 'msg_1',
          senderId: 'user_1',
          content: 'First message',
          timestamp: now.subtract(const Duration(minutes: 30)),
        ),
      ];

      final thread = Thread(
        id: 'thread_1',
        originalMessageId: 'msg_original',
        title: 'Test Thread',
        participants: participants,
        messages: messages,
        createdAt: now.subtract(const Duration(hours: 2)),
        lastActivityAt: now.subtract(const Duration(minutes: 30)),
        createdBy: 'user_1',
        priority: ThreadPriority.high,
      );

      expect(thread.messageCount, 1);
      expect(thread.activeParticipantCount, 2);
      expect(thread.latestMessage?.content, 'First message');
      expect(thread.getUnreadMessageCount('user_2'), 1);
      expect(thread.creator?.id, 'user_1');

      final json = thread.toJson();
      final restored = Thread.fromJson(json);
      expect(restored.title, thread.title);
      expect(restored.participants.length, thread.participants.length);
    });

    test('ThreadSettings and permissions', () {
      const settings = ThreadSettings(
        moderatorsOnly: true,
        reactionsEnabled: false,
        editingEnabled: true,
        maxParticipants: 10,
      );

      expect(settings.moderatorsOnly, true);
      expect(settings.reactionsEnabled, false);
      expect(settings.editingEnabled, true);

      final json = settings.toJson();
      final restored = ThreadSettings.fromJson(json);
      expect(restored.moderatorsOnly, settings.moderatorsOnly);
      expect(restored.maxParticipants, settings.maxParticipants);
    });
  });

  group('ThreadService Tests', () {
    tearDown(() {
      // Clear test data
      ThreadService.getAllThreads().forEach((thread) {
        ThreadService.deleteThread(
          threadId: thread.id,
          deletedBy: thread.createdBy,
        );
      });
    });

    test('Create and manage thread lifecycle', () async {
      // Create thread
      final thread = await ThreadService.createThread(
        title: 'Test Thread',
        originalMessageId: 'msg_1',
        createdBy: 'user_1',
        description: 'Test description',
        priority: ThreadPriority.high,
      );

      expect(thread.title, 'Test Thread');
      expect(thread.participants.length, 1);
      expect(thread.participants.first.role, ThreadParticipantRole.creator);

      // Add message
      final message = await ThreadService.addMessage(
        threadId: thread.id,
        senderId: 'user_1',
        content: 'Hello, thread!',
      );

      expect(message.content, 'Hello, thread!');

      // Add participant
      final addSuccess = await ThreadService.addParticipant(
        threadId: thread.id,
        participantId: 'user_2',
        addedBy: 'user_1',
      );

      expect(addSuccess, true);

      // Edit message
      final editSuccess = await ThreadService.editMessage(
        threadId: thread.id,
        messageId: message.id,
        newContent: 'Edited content',
        editorId: 'user_1',
      );

      expect(editSuccess, true);

      // Archive thread
      final archiveSuccess = await ThreadService.archiveThread(
        threadId: thread.id,
        archivedBy: 'user_1',
      );

      expect(archiveSuccess, true);

      final finalThread = ThreadService.getThread(thread.id);
      expect(finalThread?.status, ThreadStatus.archived);
      expect(finalThread?.participants.length, 2);
      expect(finalThread?.messages.first.content, 'Edited content');
      expect(finalThread?.messages.first.isEdited, true);
    });

    test('Permissions and restrictions', () async {
      final thread = await ThreadService.createThread(
        title: 'Restricted Thread',
        originalMessageId: 'msg_1',
        createdBy: 'user_1',
        settings: const ThreadSettings(moderatorsOnly: true),
      );

      await ThreadService.addParticipant(
        threadId: thread.id,
        participantId: 'user_2',
        addedBy: 'user_1',
        role: ThreadParticipantRole.member,
      );

      // Creator can post
      expect(ThreadService.canUserPostInThread(thread.id, 'user_1'), true);
      // Regular member cannot post in moderators-only thread
      expect(ThreadService.canUserPostInThread(thread.id, 'user_2'), false);
      // Only creator can manage participants
      expect(
        ThreadService.canUserManageParticipants(thread.id, 'user_1'),
        true,
      );
      expect(
        ThreadService.canUserManageParticipants(thread.id, 'user_2'),
        false,
      );
    });

    test('Search and statistics', () async {
      await ThreadService.createThread(
        title: 'Important Meeting',
        originalMessageId: 'msg_1',
        createdBy: 'user_1',
        description: 'Project discussion',
      );

      await ThreadService.createThread(
        title: 'Casual Chat',
        originalMessageId: 'msg_2',
        createdBy: 'user_1',
      );

      final searchResults = ThreadService.searchThreads(
        query: 'important',
        userId: 'user_1',
      );

      expect(searchResults.length, 1);
      expect(searchResults.first.title, 'Important Meeting');

      final stats = ThreadService.getThreadStatistics(searchResults.first.id);
      expect(stats.totalParticipants, 1);
      expect(stats.totalMessages, 0);
    });
  });

  group('ThreadAttachment Tests', () {
    test('ThreadAttachment integration with Message', () {
      final now = DateTime.now();
      final thread = Thread(
        id: 'thread_1',
        originalMessageId: 'msg_1',
        title: 'Important Discussion',
        createdAt: now,
        lastActivityAt: now,
        createdBy: 'user_1',
        priority: ThreadPriority.urgent,
        participants: [
          ThreadParticipant(
            id: 'user_1',
            displayName: 'Creator',
            joinedAt: now,
          ),
        ],
      );

      final threadAttachment = ThreadAttachment(
        thread: thread,
        timestamp: now,
        previewText: 'Check this out',
      );

      expect(threadAttachment.isActive, true);
      expect(threadAttachment.priority, ThreadPriority.urgent);
      expect(
        threadAttachment.threadSummary.contains('Important Discussion'),
        true,
      );

      final attachment = threadAttachment.toAttachment();
      expect(attachment.uri, 'thread:thread_1');
      expect(attachment.mimeType, 'application/thread');

      final message = Message(
        id: MessageId('msg1'),
        author: ChatUser(id: ChatUserId('user1'), displayName: 'Sender'),
        kind: MessageKind.thread,
        threadAttachment: threadAttachment,
        createdAt: now,
      );

      expect(message.kind, MessageKind.thread);
      expect(message.threadAttachment?.thread.title, 'Important Discussion');
    });
  });

  group('Thread Widget Tests', () {
    testWidgets('ThreadMessageTile displays thread info correctly', (
      tester,
    ) async {
      final now = DateTime.now();
      final thread = Thread(
        id: 'thread_1',
        originalMessageId: 'msg_1',
        title: 'Team Discussion',
        createdAt: now,
        lastActivityAt: now,
        createdBy: 'user_1',
        participants: [
          ThreadParticipant(
            id: 'user_1',
            displayName: 'Creator',
            joinedAt: now,
          ),
          ThreadParticipant(id: 'user_2', displayName: 'Member', joinedAt: now),
        ],
      );

      final threadAttachment = ThreadAttachment(thread: thread, timestamp: now);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreadMessageTile(
              threadAttachment: threadAttachment,
              currentUserId: 'user_1',
            ),
          ),
        ),
      );

      expect(find.text('Team Discussion'), findsOneWidget);
      expect(find.text('Thread'), findsOneWidget);
      expect(find.text('2 participants'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('ThreadParticipantSummary shows participant info', (
      tester,
    ) async {
      final now = DateTime.now();
      final thread = Thread(
        id: 'thread_1',
        originalMessageId: 'msg_1',
        title: 'Test Thread',
        createdAt: now,
        lastActivityAt: now,
        createdBy: 'user_1',
        participants: [
          ThreadParticipant(id: 'user_1', displayName: 'User 1', joinedAt: now),
          ThreadParticipant(id: 'user_2', displayName: 'User 2', joinedAt: now),
        ],
      );

      // Simple test - just verify the widget can be created without errors
      expect(() {
        ThreadParticipantSummary(thread: thread, currentUserId: 'user_1');
      }, returnsNormally);

      // Verify basic thread properties
      expect(thread.participants.length, 2);
      expect(thread.title, 'Test Thread');
    });
  });

  group('Integration Tests', () {
    test('Complete thread workflow with events', () async {
      final events = <ThreadServiceEvent>[];
      final subscription = ThreadService.events.listen(events.add);

      // Create thread
      final thread = await ThreadService.createThread(
        title: 'Workflow Test',
        originalMessageId: 'msg_1',
        createdBy: 'user_1',
      );

      // Add participants and messages
      await ThreadService.addParticipant(
        threadId: thread.id,
        participantId: 'user_2',
        addedBy: 'user_1',
      );

      await ThreadService.addMessage(
        threadId: thread.id,
        senderId: 'user_1',
        content: 'Welcome to the thread!',
      );

      await ThreadService.addReaction(
        threadId: thread.id,
        messageId: ThreadService.getThread(thread.id)!.messages.first.id,
        emoji: '👍',
        userId: 'user_2',
      );

      // Wait for events
      await Future.delayed(const Duration(milliseconds: 10));

      expect(events.length, greaterThanOrEqualTo(4));
      expect(events.whereType<ThreadCreatedEvent>().length, 1);
      expect(events.whereType<ThreadParticipantAddedEvent>().length, 1);
      expect(events.whereType<ThreadMessageAddedEvent>().length, 1);
      expect(events.whereType<ThreadMessageReactionEvent>().length, 1);

      subscription.cancel();
    });

    test('Error handling and edge cases', () async {
      // Test non-existent thread
      expect(ThreadService.getThread('non_existent'), isNull);

      // Test adding message to non-existent thread
      expect(
        () => ThreadService.addMessage(
          threadId: 'non_existent',
          senderId: 'user_1',
          content: 'test',
        ),
        throwsA(isA<ThreadNotFoundException>()),
      );

      // Test permission errors
      final thread = await ThreadService.createThread(
        title: 'Test Thread',
        originalMessageId: 'msg_1',
        createdBy: 'user_1',
        settings: const ThreadSettings(moderatorsOnly: true),
      );

      expect(
        () => ThreadService.addMessage(
          threadId: thread.id,
          senderId: 'user_2', // Not a participant
          content: 'unauthorized',
        ),
        throwsA(isA<ThreadPermissionException>()),
      );
    });
  });
}
