import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/thread_service.dart';
import '../theme/chat_theme.dart';

/// A widget for managing thread participants
class ThreadParticipantManager extends StatefulWidget {
  /// The thread to manage participants for
  final Thread thread;

  /// Current user ID for permissions
  final String currentUserId;

  /// Called when participants are updated
  final void Function(Thread updatedThread)? onParticipantsUpdated;

  /// Called when user wants to add participants
  final void Function()? onAddParticipants;

  /// Called when user wants to invite external users
  final void Function()? onInviteUsers;

  /// Available users that can be added to the thread
  final List<ChatUser>? availableUsers;

  /// Theme configuration
  final ChatThemeData? theme;

  const ThreadParticipantManager({
    super.key,
    required this.thread,
    required this.currentUserId,
    this.onParticipantsUpdated,
    this.onAddParticipants,
    this.onInviteUsers,
    this.availableUsers,
    this.theme,
  });

  /// Show participant manager as a modal bottom sheet
  static Future<void> showModal({
    required BuildContext context,
    required Thread thread,
    required String currentUserId,
    void Function(Thread updatedThread)? onParticipantsUpdated,
    List<ChatUser>? availableUsers,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ThreadParticipantManager(
          thread: thread,
          currentUserId: currentUserId,
          onParticipantsUpdated: onParticipantsUpdated,
          availableUsers: availableUsers,
        ),
      ),
    );
  }

  @override
  State<ThreadParticipantManager> createState() =>
      _ThreadParticipantManagerState();
}

class _ThreadParticipantManagerState extends State<ThreadParticipantManager>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  Thread? _updatedThread;
  List<ThreadParticipant> _filteredParticipants = [];
  List<ChatUser> _filteredAvailableUsers = [];
  String _searchQuery = '';
  bool _isLoading = false;

  Thread get currentThread => _updatedThread ?? widget.thread;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateFilteredLists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredLists() {
    final query = _searchQuery.toLowerCase();

    // Filter current participants
    _filteredParticipants = currentThread.participants.where((participant) {
      return participant.displayName.toLowerCase().contains(query);
    }).toList();

    // Filter available users (exclude current participants)
    final participantIds = currentThread.participants.map((p) => p.id).toSet();
    _filteredAvailableUsers = (widget.availableUsers ?? []).where((user) {
      return !participantIds.contains(user.id.value) &&
          user.displayName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Participants'),
          Text(
            '${currentThread.participants.length} participant${currentThread.participants.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        if (_canManageParticipants())
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: widget.onAddParticipants,
            tooltip: 'Add Participants',
          ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            if (_canManageParticipants())
              const PopupMenuItem(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.mail_outline),
                    SizedBox(width: 8),
                    Text('Invite Users'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export List'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search participants...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _updateFilteredLists();
          });
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          text: 'Current (${_filteredParticipants.length})',
          icon: const Icon(Icons.people),
        ),
        if (widget.availableUsers?.isNotEmpty == true)
          Tab(
            text: 'Add (${_filteredAvailableUsers.length})',
            icon: const Icon(Icons.person_add),
          )
        else
          const Tab(text: 'Add', icon: Icon(Icons.person_add)),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [_buildCurrentParticipantsList(), _buildAddParticipantsList()],
    );
  }

  Widget _buildCurrentParticipantsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredParticipants.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: _searchQuery.isNotEmpty
            ? 'No participants found'
            : 'No participants',
        subtitle: _searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'This thread has no participants',
      );
    }

    return ListView.builder(
      itemCount: _filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = _filteredParticipants[index];
        return _buildParticipantTile(participant);
      },
    );
  }

  Widget _buildAddParticipantsList() {
    if (widget.availableUsers?.isEmpty != false) {
      return _buildEmptyState(
        icon: Icons.person_add_outlined,
        title: 'No users available',
        subtitle: 'No additional users can be added to this thread',
        action: widget.onInviteUsers != null
            ? ElevatedButton.icon(
                onPressed: widget.onInviteUsers,
                icon: const Icon(Icons.mail_outline),
                label: const Text('Invite Users'),
              )
            : null,
      );
    }

    if (_filteredAvailableUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No users found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.builder(
      itemCount: _filteredAvailableUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredAvailableUsers[index];
        return _buildAddUserTile(user);
      },
    );
  }

  Widget _buildParticipantTile(ThreadParticipant participant) {
    final isCurrentUser = participant.id == widget.currentUserId;
    final isCreator = participant.id == currentThread.createdBy;
    final canManage = _canManageParticipants() && !isCreator;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildParticipantAvatar(participant),
        title: _buildParticipantTitle(participant, isCurrentUser, isCreator),
        subtitle: _buildParticipantSubtitle(participant),
        trailing: canManage ? _buildParticipantActions(participant) : null,
        onTap: () => _showParticipantDetails(participant),
      ),
    );
  }

  Widget _buildParticipantAvatar(ThreadParticipant participant) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: participant.avatar?.isNotEmpty == true
              ? ClipOval(
                  child: Image.network(
                    participant.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsAvatar(participant.displayName),
                  ),
                )
              : _buildInitialsAvatar(participant.displayName),
        ),

        // Role indicator
        if (participant.role != ThreadParticipantRole.member)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getRoleColor(participant.role),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                _getRoleIcon(participant.role),
                size: 10,
                color: Colors.white,
              ),
            ),
          ),

        // Activity indicator
        if (!participant.isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String displayName) {
    final initials = displayName.isNotEmpty
        ? displayName
              .split(' ')
              .map((n) => n.isNotEmpty ? n[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildParticipantTitle(
    ThreadParticipant participant,
    bool isCurrentUser,
    bool isCreator,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            participant.displayName + (isCurrentUser ? ' (You)' : ''),
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),

        // Role badge
        if (participant.role != ThreadParticipantRole.member)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getRoleColor(participant.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getRoleLabel(participant.role),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(participant.role),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantSubtitle(ThreadParticipant participant) {
    final subtitleParts = <String>[];

    // Joined date
    final joinedAgo = _formatTimeAgo(participant.joinedAt);
    subtitleParts.add('Joined $joinedAgo');

    // Last seen
    if (participant.lastSeenAt != null) {
      final lastSeenAgo = _formatTimeAgo(participant.lastSeenAt!);
      subtitleParts.add('Last seen $lastSeenAgo');
    }

    // Status
    if (!participant.isActive) {
      subtitleParts.add('Inactive');
    } else if (participant.isTyping) {
      subtitleParts.add('Typing...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitleParts.join(' • ')),
        if (participant.role == ThreadParticipantRole.creator)
          Text(
            'Thread Creator',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantActions(ThreadParticipant participant) {
    return PopupMenuButton<String>(
      onSelected: (action) => _handleParticipantAction(participant, action),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'promote',
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings),
              SizedBox(width: 8),
              Text('Promote to Moderator'),
            ],
          ),
        ),
        if (participant.role == ThreadParticipantRole.moderator)
          const PopupMenuItem(
            value: 'demote',
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('Remove Moderator'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_remove, color: Colors.red),
              SizedBox(width: 8),
              Text('Remove from Thread', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddUserTile(ChatUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: user.avatarUrl?.isNotEmpty == true
              ? ClipOval(
                  child: Image.network(
                    user.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsAvatar(user.displayName),
                  ),
                )
              : _buildInitialsAvatar(user.displayName),
        ),
        title: Text(user.displayName),
        subtitle: user.isOnline
            ? const Text('Online', style: TextStyle(color: Colors.green))
            : const Text('Offline', style: TextStyle(color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: () => _addUserToThread(user),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 24), action],
        ],
      ),
    );
  }

  Color _getRoleColor(ThreadParticipantRole role) {
    switch (role) {
      case ThreadParticipantRole.creator:
        return Colors.purple[600]!;
      case ThreadParticipantRole.moderator:
        return Colors.blue[600]!;
      case ThreadParticipantRole.observer:
        return Colors.grey[600]!;
      default:
        return Colors.green[600]!;
    }
  }

  IconData _getRoleIcon(ThreadParticipantRole role) {
    switch (role) {
      case ThreadParticipantRole.creator:
        return Icons.star;
      case ThreadParticipantRole.moderator:
        return Icons.shield;
      case ThreadParticipantRole.observer:
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }

  String _getRoleLabel(ThreadParticipantRole role) {
    switch (role) {
      case ThreadParticipantRole.creator:
        return 'Creator';
      case ThreadParticipantRole.moderator:
        return 'Moderator';
      case ThreadParticipantRole.observer:
        return 'Observer';
      default:
        return 'Member';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  bool _canManageParticipants() {
    return ThreadService.canUserManageParticipants(
      currentThread.id,
      widget.currentUserId,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'invite':
        widget.onInviteUsers?.call();
        break;
      case 'export':
        _exportParticipantList();
        break;
    }
  }

  void _handleParticipantAction(ThreadParticipant participant, String action) {
    switch (action) {
      case 'promote':
        _promoteParticipant(participant);
        break;
      case 'demote':
        _demoteParticipant(participant);
        break;
      case 'remove':
        _removeParticipant(participant);
        break;
    }
  }

  Future<void> _addUserToThread(ChatUser user) async {
    setState(() => _isLoading = true);

    try {
      final success = await ThreadService.addParticipant(
        threadId: currentThread.id,
        participantId: user.id.value,
        addedBy: widget.currentUserId,
      );

      if (success) {
        final updatedThread = ThreadService.getThread(currentThread.id);
        if (updatedThread != null) {
          setState(() {
            _updatedThread = updatedThread;
            _updateFilteredLists();
          });
          widget.onParticipantsUpdated?.call(updatedThread);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.displayName} added to thread')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add participant: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeParticipant(ThreadParticipant participant) async {
    final confirmed = await _showConfirmDialog(
      'Remove Participant',
      'Are you sure you want to remove ${participant.displayName} from this thread?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final success = await ThreadService.removeParticipant(
        threadId: currentThread.id,
        participantId: participant.id,
        removedBy: widget.currentUserId,
      );

      if (success) {
        final updatedThread = ThreadService.getThread(currentThread.id);
        if (updatedThread != null) {
          setState(() {
            _updatedThread = updatedThread;
            _updateFilteredLists();
          });
          widget.onParticipantsUpdated?.call(updatedThread);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${participant.displayName} removed from thread'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove participant: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteParticipant(ThreadParticipant participant) async {
    // Implementation would depend on ThreadService having role management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Role management coming soon!')),
    );
  }

  Future<void> _demoteParticipant(ThreadParticipant participant) async {
    // Implementation would depend on ThreadService having role management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Role management coming soon!')),
    );
  }

  void _showParticipantDetails(ThreadParticipant participant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: participant.avatar?.isNotEmpty == true
                  ? ClipOval(
                      child: Image.network(
                        participant.avatar!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsAvatar(participant.displayName),
                      ),
                    )
                  : _buildInitialsAvatar(participant.displayName),
            ),
            const SizedBox(height: 16),
            Text(
              participant.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _getRoleLabel(participant.role),
              style: TextStyle(
                fontSize: 14,
                color: _getRoleColor(participant.role),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Joined', _formatTimeAgo(participant.joinedAt)),
            if (participant.lastSeenAt != null)
              _buildDetailRow(
                'Last seen',
                _formatTimeAgo(participant.lastSeenAt!),
              ),
            _buildDetailRow(
              'Status',
              participant.isActive ? 'Active' : 'Inactive',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _exportParticipantList() {
    // Implementation for exporting participant list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }
}

/// A simplified widget for showing participant count and quick actions
class ThreadParticipantSummary extends StatelessWidget {
  /// The thread to show participant summary for
  final Thread thread;

  /// Current user ID
  final String currentUserId;

  /// Called when user wants to manage participants
  final VoidCallback? onManageParticipants;

  /// Called when user wants to add participants
  final VoidCallback? onAddParticipants;

  /// Maximum number of participant avatars to show
  final int maxAvatars;

  const ThreadParticipantSummary({
    super.key,
    required this.thread,
    required this.currentUserId,
    this.onManageParticipants,
    this.onAddParticipants,
    this.maxAvatars = 5,
  });

  @override
  Widget build(BuildContext context) {
    final activeParticipants = thread.participants
        .where((p) => p.isActive)
        .toList();
    final displayParticipants = activeParticipants.take(maxAvatars).toList();
    final remainingCount =
        activeParticipants.length - displayParticipants.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Participant avatars
          if (displayParticipants.isNotEmpty)
            SizedBox(
              height: 32,
              child: Stack(
                children: [
                  ...displayParticipants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final participant = entry.value;

                    return Positioned(
                      left: index * 20.0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: participant.avatar?.isNotEmpty == true
                            ? ClipOval(
                                child: Image.network(
                                  participant.avatar!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildInitials(participant.displayName),
                                ),
                              )
                            : _buildInitials(participant.displayName),
                      ),
                    );
                  }),

                  // Remaining count indicator
                  if (remainingCount > 0)
                    Positioned(
                      left: displayParticipants.length * 20.0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[400],
                        child: Text(
                          '+$remainingCount',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(width: 12),

          // Participant count and actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activeParticipants.length} participant${activeParticipants.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (thread.participants.length != activeParticipants.length)
                  Text(
                    '${thread.participants.length - activeParticipants.length} inactive',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          // Action buttons
          if (ThreadService.canUserManageParticipants(thread.id, currentUserId))
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: onAddParticipants,
              tooltip: 'Add Participants',
            ),

          IconButton(
            icon: const Icon(Icons.people),
            onPressed: onManageParticipants,
            tooltip: 'Manage Participants',
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String displayName) {
    final initials = displayName.isNotEmpty
        ? displayName
              .split(' ')
              .map((n) => n.isNotEmpty ? n[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
