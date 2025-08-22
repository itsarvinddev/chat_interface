import 'dart:async';
import 'dart:math';

import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatUIDemoApp());
}

class ChatUIDemoApp extends StatelessWidget {
  const ChatUIDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatUI Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SimpleChatDemo(),
    );
  }
}

class SimpleChatDemo extends StatefulWidget {
  const SimpleChatDemo({super.key});

  @override
  State<SimpleChatDemo> createState() => _SimpleChatDemoState();
}

class ChatAppState {
  final Map<String, ChatUser> users = {};
  final Map<String, List<Message>> channels = {};
  final Map<String, TypingState> typingStates = {};
  final Random _random = Random();

  static final ChatAppState _instance = ChatAppState._internal();
  factory ChatAppState() => _instance;
  ChatAppState._internal();

  void addMessage(String channelId, Message message) {
    channels.putIfAbsent(channelId, () => []);
    channels[channelId]!.insert(0, message);
  }

  String generateMessageId() =>
      'msg_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
}

class _SimpleChatDemoState extends State<SimpleChatDemo>
    with TickerProviderStateMixin {
  late ChatController controller;
  late ChatAppState appState;
  late TabController tabController;
  String selectedChannelId = 'general';

  final List<String> channelNames = [
    'general',
    'random',
    'development',
    'design',
  ];
  final List<IconData> channelIcons = [
    Icons.chat,
    Icons.people,
    Icons.code,
    Icons.palette,
  ];

  @override
  void initState() {
    super.initState();
    appState = ChatAppState();
    tabController = TabController(length: 4, vsync: this);
    _initializeDemo();
    _startSimulation();
  }

  void _initializeDemo() {
    // Create sample users
    final currentUser = ChatUser(
      id: const ChatUserId('current_user'),
      displayName: 'Alex Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      isOnline: true,
    );

    final users = [
      ChatUser(
        id: const ChatUserId('alice'),
        displayName: 'Alice Cooper',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
      ),
      ChatUser(
        id: const ChatUserId('bob'),
        displayName: 'Bob Smith',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        isOnline: true,
      ),
      ChatUser(
        id: const ChatUserId('charlie'),
        displayName: 'Charlie Brown',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        isOnline: false,
      ),
      ChatUser(
        id: const ChatUserId('diana'),
        displayName: 'Diana Prince',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        isOnline: true,
      ),
    ];

    // Store users in app state
    appState.users['current_user'] = currentUser;
    for (final user in users) {
      appState.users[user.id.value] = user;
    }

    // Initialize controller
    controller = ChatController(
      adapter: InMemoryChatAdapter(currentUser: currentUser),
      currentUser: currentUser,
      channelId: ChannelId(selectedChannelId),
    );

    controller.attach();
    _createSampleMessages(currentUser, users);
  }

  void _createSampleMessages(ChatUser currentUser, List<ChatUser> users) {
    final sampleMessages = [
      Message(
        id: MessageId(appState.generateMessageId()),
        author: users[0], // Alice
        kind: MessageKind.text,
        text: 'Good morning team! 🌅 Ready for another productive day?',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        reactions: {
          '👋': const ReactionSummary(
            key: '👋',
            by: {
              ChatUserId('bob'),
              ChatUserId('current_user'),
              ChatUserId('diana'),
            },
          ),
          '☕': const ReactionSummary(key: '☕', by: {ChatUserId('charlie')}),
        },
      ),
      Message(
        id: MessageId(appState.generateMessageId()),
        author: currentUser,
        kind: MessageKind.text,
        text:
            'Absolutely! Just grabbed my coffee and ready to tackle the sprint goals ☕',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 3, minutes: 45),
        ),
      ),
      Message(
        id: MessageId(appState.generateMessageId()),
        author: users[1], // Bob
        kind: MessageKind.text,
        text:
            'Let\'s decide on our team lunch spot for Friday! 🍕 (Poll feature would be interactive in production)',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        reactions: {
          '🍕': const ReactionSummary(
            key: '🍕',
            by: {ChatUserId('alice'), ChatUserId('current_user')},
          ),
          '🍜': const ReactionSummary(key: '🍜', by: {ChatUserId('diana')}),
        },
      ),
      Message(
        id: MessageId(appState.generateMessageId()),
        author: users[2], // Charlie
        kind: MessageKind.image,
        text: 'New UI mockups are ready for review! 🎨',
        attachments: [
          const Attachment(
            uri: 'https://picsum.photos/800/600?random=1',
            mimeType: 'image/jpeg',
            sizeBytes: 1245760,
            thumbnailUri: 'https://picsum.photos/200/150?random=1',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        reactions: {
          '🔥': const ReactionSummary(
            key: '🔥',
            by: {ChatUserId('alice'), ChatUserId('current_user')},
          ),
        },
      ),
      Message(
        id: MessageId(appState.generateMessageId()),
        author: users[3], // Diana
        kind: MessageKind.location,
        text: 'I\'m at the client meeting location 📍',
        location: LocationAttachment(
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'TechCorp HQ, 123 Innovation Drive, San Francisco, CA',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          accuracy: 5.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: MessageId(appState.generateMessageId()),
        author: currentUser,
        kind: MessageKind.contact,
        text: 'Here\'s the contact info for our new DevOps consultant',
        contactAttachment: ContactAttachment(
          contact: Contact(
            id: 'consultant_1',
            displayName: 'Michael Chen',
            company: 'CloudOps Solutions',
            jobTitle: 'Senior DevOps Engineer',
            phoneNumbers: [
              const ContactPhoneNumber(number: '+1-555-0123', type: 'work'),
            ],
            emails: [
              const ContactEmail(
                email: 'michael.chen@cloudops.com',
                type: 'work',
              ),
            ],
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    // Add messages to the adapter
    for (final message in sampleMessages.reversed) {
      controller.adapter.sendMessage(ChannelId(selectedChannelId), message);
      appState.addMessage(selectedChannelId, message);
    }
  }

  void _startSimulation() {
    // Simulate random user activity every 10-20 seconds
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && appState._random.nextDouble() < 0.3) {
        _simulateIncomingMessage();
      } else if (!mounted) {
        timer.cancel();
      }
    });
  }

  void _simulateIncomingMessage() {
    final userIds = appState.users.keys
        .where((id) => id != 'current_user')
        .toList();
    if (userIds.isEmpty) return;

    final userId = userIds[appState._random.nextInt(userIds.length)];
    final user = appState.users[userId]!;

    final randomMessages = [
      'That sounds great! 👍',
      'I agree with the approach',
      'Let me check on that...',
      'Thanks for the update!',
      'Looking good so far 🚀',
      'Perfect timing!',
      'Can we schedule a quick call?',
      'Nice work everyone! 👏',
    ];

    final message = Message(
      id: MessageId(appState.generateMessageId()),
      author: user,
      kind: MessageKind.text,
      text: randomMessages[appState._random.nextInt(randomMessages.length)],
      createdAt: DateTime.now(),
    );

    controller.adapter.sendMessage(ChannelId(selectedChannelId), message);
    appState.addMessage(selectedChannelId, message);
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text(
          'This $feature feature would connect to a real backend in a production app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                appState.users['current_user']!.avatarUrl!,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#$selectedChannelId',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${appState.users.length} members • ${appState.users.values.where((u) => u.isOnline).length} online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _showFeatureDialog('Video Call'),
            tooltip: 'Start video call',
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _showFeatureDialog('Voice Call'),
            tooltip: 'Start voice call',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'members',
                child: Row(
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 8),
                    Text('View Members'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Channel Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Search Messages'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _showFeatureDialog(value.toString()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 60,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: List.generate(channelNames.length, (index) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(channelIcons[index], size: 18),
                      const SizedBox(width: 6),
                      Text(channelNames[index]),
                    ],
                  ),
                );
              }),
              onTap: (index) {
                setState(() {
                  selectedChannelId = channelNames[index];
                });
                // In a real app, this would switch channels
                _showFeatureDialog('Channel Switch to ${channelNames[index]}');
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Status bar showing typing indicators
          if (appState.typingStates[selectedChannelId]?.hasTypingUsers == true)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: TypingIndicator(
                typingState: appState.typingStates[selectedChannelId]!,
                showNames: true,
              ),
            ),

          // Chat Interface
          Expanded(
            child: ChatView(
              controller: controller,
              theme: ChatThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                incomingBubbleColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainer,
                outgoingBubbleColor: Theme.of(context).colorScheme.primary,
                incomingTextColor: Theme.of(context).colorScheme.onSurface,
                outgoingTextColor: Theme.of(context).colorScheme.onPrimary,
                messageTextStyle: Theme.of(context).textTheme.bodyMedium!,
                bubbleRadius: 18,
                enableBubbleShadows: true,
                bubbleShadow: BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                accentColor: Theme.of(context).colorScheme.primary,
                timestampColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                timestampTextStyle: Theme.of(context).textTheme.labelSmall!,
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for features
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFeaturesBottomSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Features'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _showFeaturesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ChatUI Package Features',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This demo showcases all the features available in the ChatUI package:',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip('💬 Text Messages'),
                _buildFeatureChip('😊 Reactions & Emojis'),
                _buildFeatureChip('✏️ Message Editing'),
                _buildFeatureChip('📍 Location Sharing'),
                _buildFeatureChip('🖼️ Image Attachments'),
                _buildFeatureChip('🎤 Audio Messages'),
                _buildFeatureChip('📊 Polls & Voting'),
                _buildFeatureChip('📞 Contact Sharing'),
                _buildFeatureChip('🧵 Message Threads'),
                _buildFeatureChip('⌨️ Typing Indicators'),
                _buildFeatureChip('📁 File Attachments'),
                _buildFeatureChip('🎨 Custom Themes'),
                _buildFeatureChip('📏 Quick Replies'),
                _buildFeatureChip('🔄 Real-time Updates'),
                _buildFeatureChip('📱 Mobile Optimized'),
                _buildFeatureChip('♾️ Material Design 3'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue Exploring'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
