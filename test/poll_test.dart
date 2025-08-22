import 'package:chatui/src/models/models.dart';
import 'package:chatui/src/widgets/poll_creator.dart';
import 'package:chatui/src/widgets/poll_message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Poll Models Tests', () {
    test('PollOption creation and properties', () {
      final option = PollOption(
        id: 'opt1',
        text: 'Option 1',
        voteCount: 5,
        isVotedByCurrentUser: true,
      );

      expect(option.id, 'opt1');
      expect(option.text, 'Option 1');
      expect(option.voteCount, 5);
      expect(option.isVotedByCurrentUser, true);
    });

    test('PollOption copyWith method', () {
      final original = PollOption(
        id: 'opt1',
        text: 'Option 1',
        voteCount: 5,
        isVotedByCurrentUser: false,
      );

      final updated = original.copyWith(
        voteCount: 10,
        isVotedByCurrentUser: true,
      );

      expect(updated.id, 'opt1');
      expect(updated.text, 'Option 1');
      expect(updated.voteCount, 10);
      expect(updated.isVotedByCurrentUser, true);
    });

    test('PollOption JSON serialization', () {
      final option = PollOption(
        id: 'opt1',
        text: 'Option 1',
        voteCount: 5,
        isVotedByCurrentUser: true,
      );

      final json = option.toJson();
      expect(json['id'], 'opt1');
      expect(json['text'], 'Option 1');
      expect(json['voteCount'], 5);
      expect(json['isVotedByCurrentUser'], true);

      final restored = PollOption.fromJson(json);
      expect(restored, option);
    });

    test('Poll creation and properties', () {
      final now = DateTime.now();
      final deadline = now.add(Duration(days: 1));

      final options = [
        PollOption(id: 'opt1', text: 'Option 1'),
        PollOption(id: 'opt2', text: 'Option 2'),
      ];

      final poll = Poll(
        id: 'poll1',
        question: 'What is your favorite color?',
        options: options,
        type: PollType.singleChoice,
        status: PollStatus.active,
        isAnonymous: false,
        deadline: deadline,
        createdAt: now,
        createdBy: 'user1',
        creatorName: 'John Doe',
      );

      expect(poll.id, 'poll1');
      expect(poll.question, 'What is your favorite color?');
      expect(poll.options.length, 2);
      expect(poll.type, PollType.singleChoice);
      expect(poll.status, PollStatus.active);
      expect(poll.isAnonymous, false);
      expect(poll.deadline, deadline);
      expect(poll.createdAt, now);
      expect(poll.createdBy, 'user1');
      expect(poll.creatorName, 'John Doe');
    });

    test('Poll computed properties', () {
      final now = DateTime.now();
      final pastDeadline = now.subtract(Duration(hours: 1));
      final futureDeadline = now.add(Duration(hours: 1));

      // Test hasEnded with status
      final endedPoll = Poll(
        id: 'poll1',
        question: 'Test',
        options: [],
        createdAt: now,
        createdBy: 'user1',
        status: PollStatus.ended,
      );
      expect(endedPoll.hasEnded, true);

      // Test hasEnded with past deadline
      final expiredPoll = Poll(
        id: 'poll2',
        question: 'Test',
        options: [],
        createdAt: now,
        createdBy: 'user1',
        deadline: pastDeadline,
      );
      expect(expiredPoll.hasEnded, true);

      // Test active poll
      final activePoll = Poll(
        id: 'poll3',
        question: 'Test',
        options: [],
        createdAt: now,
        createdBy: 'user1',
        deadline: futureDeadline,
      );
      expect(activePoll.hasEnded, false);

      // Test allowsMultipleSelections
      final singleChoicePoll = Poll(
        id: 'poll4',
        question: 'Test',
        options: [],
        createdAt: now,
        createdBy: 'user1',
        type: PollType.singleChoice,
      );
      expect(singleChoicePoll.allowsMultipleSelections, false);

      final multipleChoicePoll = Poll(
        id: 'poll5',
        question: 'Test',
        options: [],
        createdAt: now,
        createdBy: 'user1',
        type: PollType.multipleChoice,
      );
      expect(multipleChoicePoll.allowsMultipleSelections, true);
    });

    test('Poll voting calculations', () {
      final now = DateTime.now();
      final options = [
        PollOption(
          id: 'opt1',
          text: 'Option 1',
          voteCount: 10,
          isVotedByCurrentUser: true,
        ),
        PollOption(id: 'opt2', text: 'Option 2', voteCount: 5),
        PollOption(id: 'opt3', text: 'Option 3', voteCount: 10),
      ];

      final poll = Poll(
        id: 'poll1',
        question: 'Test poll',
        options: options,
        createdAt: now,
        createdBy: 'user1',
      );

      // Test totalVotes
      expect(poll.totalVotes, 25);

      // Test hasCurrentUserVoted
      expect(poll.hasCurrentUserVoted, true);

      // Test winningOptions (should return both options with 10 votes)
      expect(poll.winningOptions.length, 2);
      expect(poll.winningOptions[0].id, 'opt1');
      expect(poll.winningOptions[1].id, 'opt3');

      // Test currentUserVotes
      expect(poll.currentUserVotes.length, 1);
      expect(poll.currentUserVotes[0].id, 'opt1');
    });

    test('Poll JSON serialization', () {
      final now = DateTime.now();
      final options = [
        PollOption(id: 'opt1', text: 'Option 1'),
        PollOption(id: 'opt2', text: 'Option 2'),
      ];

      final poll = Poll(
        id: 'poll1',
        question: 'Test poll',
        options: options,
        type: PollType.multipleChoice,
        isAnonymous: true,
        maxSelections: 2,
        createdAt: now,
        createdBy: 'user1',
        creatorName: 'John Doe',
      );

      final json = poll.toJson();
      expect(json['id'], 'poll1');
      expect(json['question'], 'Test poll');
      expect(json['type'], 'multipleChoice');
      expect(json['isAnonymous'], true);
      expect(json['maxSelections'], 2);

      final restored = Poll.fromJson(json);
      expect(restored.id, poll.id);
      expect(restored.question, poll.question);
      expect(restored.type, poll.type);
      expect(restored.isAnonymous, poll.isAnonymous);
      expect(restored.maxSelections, poll.maxSelections);
    });
  });

  group('PollAttachment Tests', () {
    test('PollAttachment creation and conversion', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'poll1',
        question: 'Test poll',
        options: [],
        createdAt: now,
        createdBy: 'user1',
      );

      final pollAttachment = PollAttachment(poll: poll, timestamp: now);

      expect(pollAttachment.poll, poll);
      expect(pollAttachment.timestamp, now);

      final attachment = pollAttachment.toAttachment();
      expect(attachment.uri, 'poll:poll1');
      expect(attachment.mimeType, 'application/poll');
    });
  });

  group('Poll Widget Tests', () {
    testWidgets('PollCreator shows correctly', (tester) async {
      Poll? createdPoll;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollCreator(
              onPollCreated: (poll) {
                createdPoll = poll;
              },
            ),
          ),
        ),
      );

      // Verify the main elements are present
      expect(
        find.text('Create Poll'),
        findsAtLeastNWidgets(1),
      ); // Allow for multiple instances
      expect(find.text('Poll Question'), findsOneWidget);
      expect(find.text('Options'), findsOneWidget);
      expect(find.text('Poll Type'), findsOneWidget);

      // Check if there are initial option fields
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);

      // Check poll type options
      expect(find.text('Single Choice'), findsOneWidget);
      expect(find.text('Multiple Choice'), findsOneWidget);
    });

    testWidgets('PollCreator validation works', (tester) async {
      Poll? createdPoll;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollCreator(
              onPollCreated: (poll) {
                createdPoll = poll;
              },
            ),
          ),
        ),
      );

      // Try to create poll without question
      await tester.tap(find.byIcon(Icons.poll));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a question'), findsOneWidget);
      expect(createdPoll, isNull);
    });

    testWidgets('PollMessageTile displays poll correctly', (tester) async {
      final poll = Poll(
        id: 'poll1',
        question: 'What is your favorite color?',
        options: [
          PollOption(id: 'opt1', text: 'Red', voteCount: 10),
          PollOption(
            id: 'opt2',
            text: 'Blue',
            voteCount: 5,
            isVotedByCurrentUser: true,
          ),
          PollOption(id: 'opt3', text: 'Green', voteCount: 3),
        ],
        createdAt: DateTime.now(),
        createdBy: 'user1',
        totalVoters: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollMessageTile(
              poll: poll,
              currentUserId: 'current_user',
              isFromCurrentUser: false,
            ),
          ),
        ),
      );

      // Verify poll content is displayed
      expect(find.text('Poll'), findsOneWidget);
      expect(find.text('What is your favorite color?'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);

      // Verify vote counts and percentages
      expect(find.text('10'), findsOneWidget); // Red votes
      expect(find.text('5'), findsOneWidget); // Blue votes
      expect(find.text('3'), findsOneWidget); // Green votes

      // Verify total votes display
      expect(find.text('18 votes'), findsOneWidget); // Total of all votes
    });

    testWidgets('PollMessageTile handles voting', (tester) async {
      List<String>? votedOptions;
      String? votedPollId;

      final poll = Poll(
        id: 'poll1',
        question: 'What is your favorite color?',
        options: [
          PollOption(id: 'opt1', text: 'Red', voteCount: 10),
          PollOption(id: 'opt2', text: 'Blue', voteCount: 5),
        ],
        type: PollType.singleChoice,
        createdAt: DateTime.now(),
        createdBy: 'user1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollMessageTile(
              poll: poll,
              currentUserId: 'current_user',
              isFromCurrentUser: false,
              onVote: (pollId, optionIds) {
                votedPollId = pollId;
                votedOptions = optionIds;
              },
            ),
          ),
        ),
      );

      // Tap on the first option (Red)
      await tester.tap(find.text('Red'));
      await tester.pump();

      // Wait for any async operations to complete
      await tester.pumpAndSettle();

      // Verify vote was cast
      expect(votedPollId, 'poll1');
      expect(votedOptions, ['opt1']);
    });

    testWidgets('PollMessageTile shows ended poll state', (tester) async {
      final poll = Poll(
        id: 'poll1',
        question: 'What is your favorite color?',
        options: [
          PollOption(id: 'opt1', text: 'Red', voteCount: 10),
          PollOption(id: 'opt2', text: 'Blue', voteCount: 5),
        ],
        status: PollStatus.ended,
        createdAt: DateTime.now(),
        createdBy: 'user1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollMessageTile(
              poll: poll,
              currentUserId: 'current_user',
              isFromCurrentUser: false,
            ),
          ),
        ),
      );

      // Verify ended state is shown
      expect(find.text('Ended'), findsOneWidget);
    });

    testWidgets('PollMessageTile shows multiple choice poll correctly', (
      tester,
    ) async {
      final poll = Poll(
        id: 'poll1',
        question: 'Which features do you want?',
        options: [
          PollOption(id: 'opt1', text: 'Feature A', voteCount: 10),
          PollOption(id: 'opt2', text: 'Feature B', voteCount: 5),
          PollOption(id: 'opt3', text: 'Feature C', voteCount: 8),
        ],
        type: PollType.multipleChoice,
        maxSelections: 2,
        createdAt: DateTime.now(),
        createdBy: 'user1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollMessageTile(
              poll: poll,
              currentUserId: 'current_user',
              isFromCurrentUser: false,
            ),
          ),
        ),
      );

      // Verify multiple choice indicator
      expect(find.text('Multiple choice'), findsOneWidget);

      // Verify checkbox icons are used instead of radio buttons
      expect(
        find.byIcon(Icons.check_box_outline_blank),
        findsAtLeastNWidgets(3),
      );
    });
  });

  group('Poll Integration Tests', () {
    test('Message with poll attachment', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'poll1',
        question: 'Test poll',
        options: [PollOption(id: 'opt1', text: 'Option 1')],
        createdAt: now,
        createdBy: 'user1',
      );

      final pollAttachment = PollAttachment(poll: poll, timestamp: now);

      final message = Message(
        id: MessageId('msg1'),
        author: ChatUser(id: ChatUserId('user1'), displayName: 'John Doe'),
        kind: MessageKind.poll,
        pollAttachment: pollAttachment,
        createdAt: now,
      );

      expect(message.kind, MessageKind.poll);
      expect(message.pollAttachment, pollAttachment);
      expect(message.pollAttachment!.poll.question, 'Test poll');
    });
  });
}
