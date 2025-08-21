/// Represents a category of quick replies
class QuickReplyCategory {
  final String id;
  final String name;
  final String? icon;
  final List<QuickReply> replies;

  const QuickReplyCategory({
    required this.id,
    required this.name,
    this.icon,
    required this.replies,
  });
}

/// Represents a single quick reply option
class QuickReply {
  final String id;
  final String text;
  final String? emoji;
  final QuickReplyType type;

  const QuickReply({
    required this.id,
    required this.text,
    this.emoji,
    this.type = QuickReplyType.text,
  });
}

/// Types of quick replies
enum QuickReplyType { text, emoji, action }

/// Default quick reply categories for common chat scenarios
class DefaultQuickReplies {
  static const List<QuickReplyCategory> categories = [
    QuickReplyCategory(
      id: 'greetings',
      name: 'Greetings',
      icon: '👋',
      replies: [
        QuickReply(id: 'hi', text: 'Hi there!', emoji: '👋'),
        QuickReply(id: 'hello', text: 'Hello!', emoji: '👋'),
        QuickReply(id: 'good_morning', text: 'Good morning!', emoji: '🌅'),
        QuickReply(id: 'good_evening', text: 'Good evening!', emoji: '🌆'),
        QuickReply(id: 'how_are_you', text: 'How are you?', emoji: '🤔'),
      ],
    ),
    QuickReplyCategory(
      id: 'responses',
      name: 'Responses',
      icon: '💬',
      replies: [
        QuickReply(id: 'yes', text: 'Yes', emoji: '✅'),
        QuickReply(id: 'no', text: 'No', emoji: '❌'),
        QuickReply(id: 'maybe', text: 'Maybe', emoji: '🤷'),
        QuickReply(id: 'thanks', text: 'Thanks!', emoji: '🙏'),
        QuickReply(id: 'you_welcome', text: "You're welcome!", emoji: '😊'),
        QuickReply(id: 'ok', text: 'OK', emoji: '👌'),
        QuickReply(id: 'sure', text: 'Sure!', emoji: '👍'),
      ],
    ),
    QuickReplyCategory(
      id: 'questions',
      name: 'Questions',
      icon: '❓',
      replies: [
        QuickReply(id: 'what_time', text: 'What time?', emoji: '🕐'),
        QuickReply(id: 'where', text: 'Where?', emoji: '📍'),
        QuickReply(id: 'when', text: 'When?', emoji: '📅'),
        QuickReply(id: 'how', text: 'How?', emoji: '🤔'),
        QuickReply(id: 'why', text: 'Why?', emoji: '🤷'),
      ],
    ),
    QuickReplyCategory(
      id: 'actions',
      name: 'Actions',
      icon: '⚡',
      replies: [
        QuickReply(id: 'on_my_way', text: "I'm on my way!", emoji: '🚶'),
        QuickReply(id: 'be_there_soon', text: 'Be there soon!', emoji: '⏰'),
        QuickReply(id: 'call_me', text: 'Call me', emoji: '📞'),
        QuickReply(id: 'text_me', text: 'Text me', emoji: '💬'),
        QuickReply(id: 'meet_later', text: 'Meet later?', emoji: '🤝'),
      ],
    ),
    QuickReplyCategory(
      id: 'emotions',
      name: 'Emotions',
      icon: '😊',
      replies: [
        QuickReply(
          id: 'happy',
          text: '😊',
          emoji: '😊',
          type: QuickReplyType.emoji,
        ),
        QuickReply(
          id: 'sad',
          text: '😢',
          emoji: '😢',
          type: QuickReplyType.emoji,
        ),
        QuickReply(
          id: 'laugh',
          text: '😂',
          emoji: '😂',
          type: QuickReplyType.emoji,
        ),
        QuickReply(
          id: 'love',
          text: '❤️',
          emoji: '❤️',
          type: QuickReplyType.emoji,
        ),
        QuickReply(
          id: 'wow',
          text: '😮',
          emoji: '😮',
          type: QuickReplyType.emoji,
        ),
        QuickReply(
          id: 'angry',
          text: '😡',
          emoji: '😡',
          type: QuickReplyType.emoji,
        ),
      ],
    ),
  ];
}
