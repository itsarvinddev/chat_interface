import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/chat_theme.dart';

/// A widget that displays a list of threads with filtering and management options
class ThreadListView extends StatefulWidget {
  /// List of threads to display
  final List<Thread> threads;

  /// Current user ID for permissions and unread counts
  final String currentUserId;

  /// Called when user wants to view a thread
  final void Function(Thread thread)? onViewThread;

  /// Called when user wants to create a new thread
  final void Function()? onCreateThread;

  /// Called when user wants to archive a thread
  final void Function(Thread thread)? onArchiveThread;

  /// Called when user wants to delete a thread
  final void Function(Thread thread)? onDeleteThread;

  /// Called when user wants to pin/unpin a thread
  final void Function(Thread thread, bool isPinned)? onTogglePin;

  /// Called when user wants to change thread priority
  final void Function(Thread thread, ThreadPriority priority)? onChangePriority;

  /// Called when user wants to search threads
  final void Function(String query)? onSearch;

  /// Whether to show search functionality
  final bool enableSearch;

  /// Whether to show create thread button
  final bool enableCreate;

  /// Initial filter to apply
  final ThreadListFilter initialFilter;

  /// Theme configuration
  final ChatThemeData? theme;

  const ThreadListView({
    super.key,
    required this.threads,
    required this.currentUserId,
    this.onViewThread,
    this.onCreateThread,
    this.onArchiveThread,
    this.onDeleteThread,
    this.onTogglePin,
    this.onChangePriority,
    this.onSearch,
    this.enableSearch = true,
    this.enableCreate = true,
    this.initialFilter = ThreadListFilter.all,
    this.theme,
  });

  @override
  State<ThreadListView> createState() => _ThreadListViewState();
}

class _ThreadListViewState extends State<ThreadListView> {
  final TextEditingController _searchController = TextEditingController();
  late ThreadListFilter _currentFilter;
  ThreadListSort _currentSort = ThreadListSort.lastActivity;
  bool _isSearchActive = false;
  List<Thread> _filteredThreads = [];

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _updateFilteredThreads();
  }

  @override
  void didUpdateWidget(ThreadListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threads != widget.threads) {
      _updateFilteredThreads();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredThreads() {
    List<Thread> filtered = List.from(widget.threads);

    // Apply search filter
    final searchQuery = _searchController.text.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((thread) {
        return thread.title.toLowerCase().contains(searchQuery) ||
            thread.description?.toLowerCase().contains(searchQuery) == true ||
            thread.participants.any(
              (p) => p.displayName.toLowerCase().contains(searchQuery),
            );
      }).toList();
    }

    // Apply status filter
    switch (_currentFilter) {
      case ThreadListFilter.active:
        filtered = filtered.where((t) => t.isActive).toList();
        break;
      case ThreadListFilter.archived:
        filtered = filtered.where((t) => t.isArchived).toList();
        break;
      case ThreadListFilter.pinned:
        filtered = filtered.where((t) => t.isPinned).toList();
        break;
      case ThreadListFilter.unread:
        filtered = filtered
            .where((t) => t.getUnreadMessageCount(widget.currentUserId) > 0)
            .toList();
        break;
      case ThreadListFilter.participating:
        filtered = filtered
            .where(
              (t) => t.participants.any(
                (p) => p.id == widget.currentUserId && p.isActive,
              ),
            )
            .toList();
        break;
      case ThreadListFilter.all:
        // No additional filtering
        break;
    }

    // Apply sorting
    switch (_currentSort) {
      case ThreadListSort.lastActivity:
        filtered.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
        break;
      case ThreadListSort.created:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ThreadListSort.title:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ThreadListSort.priority:
        filtered.sort((a, b) => _comparePriority(a.priority, b.priority));
        break;
      case ThreadListSort.messageCount:
        filtered.sort((a, b) => b.messageCount.compareTo(a.messageCount));
        break;
    }

    // Pinned threads always go to top (except when filtering for pinned only)
    if (_currentFilter != ThreadListFilter.pinned) {
      final pinned = filtered.where((t) => t.isPinned).toList();
      final unpinned = filtered.where((t) => !t.isPinned).toList();
      filtered = [...pinned, ...unpinned];
    }

    setState(() {
      _filteredThreads = filtered;
    });
  }

  int _comparePriority(ThreadPriority a, ThreadPriority b) {
    const priorityOrder = {
      ThreadPriority.urgent: 4,
      ThreadPriority.high: 3,
      ThreadPriority.normal: 2,
      ThreadPriority.low: 1,
    };
    return (priorityOrder[b] ?? 0).compareTo(priorityOrder[a] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildThreadsList()),
        ],
      ),
      floatingActionButton: widget.enableCreate && widget.onCreateThread != null
          ? FloatingActionButton(
              onPressed: widget.onCreateThread,
              child: const Icon(Icons.add_comment),
            )
          : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearchActive ? _buildSearchField() : const Text('Threads'),
      actions: [
        if (widget.enableSearch)
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        PopupMenuButton<ThreadListSort>(
          icon: const Icon(Icons.sort),
          onSelected: (sort) {
            setState(() => _currentSort = sort);
            _updateFilteredThreads();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: ThreadListSort.lastActivity,
              child: Text('Last Activity'),
            ),
            const PopupMenuItem(
              value: ThreadListSort.created,
              child: Text('Created Date'),
            ),
            const PopupMenuItem(
              value: ThreadListSort.title,
              child: Text('Title'),
            ),
            const PopupMenuItem(
              value: ThreadListSort.priority,
              child: Text('Priority'),
            ),
            const PopupMenuItem(
              value: ThreadListSort.messageCount,
              child: Text('Message Count'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: 'Search threads...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      autofocus: true,
      onChanged: (value) {
        _updateFilteredThreads();
        widget.onSearch?.call(value);
      },
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ThreadListFilter.values.map((filter) {
          final isSelected = filter == _currentFilter;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _currentFilter = filter);
                _updateFilteredThreads();
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(ThreadListFilter filter) {
    switch (filter) {
      case ThreadListFilter.all:
        return 'All';
      case ThreadListFilter.active:
        return 'Active';
      case ThreadListFilter.archived:
        return 'Archived';
      case ThreadListFilter.pinned:
        return 'Pinned';
      case ThreadListFilter.unread:
        return 'Unread';
      case ThreadListFilter.participating:
        return 'Participating';
    }
  }

  Widget _buildThreadsList() {
    if (_filteredThreads.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _filteredThreads.length,
      itemBuilder: (context, index) {
        final thread = _filteredThreads[index];
        return _buildThreadTile(thread);
      },
    );
  }

  Widget _buildThreadTile(Thread thread) {
    final unreadCount = thread.getUnreadMessageCount(widget.currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildThreadAvatar(thread),
        title: _buildThreadTitle(thread, unreadCount),
        subtitle: _buildThreadSubtitle(thread),
        trailing: _buildThreadTrailing(thread),
        onTap: () => widget.onViewThread?.call(thread),
        onLongPress: () => _showThreadActions(thread),
      ),
    );
  }

  Widget _buildThreadAvatar(Thread thread) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: _getThreadColor(thread),
          child: Icon(Icons.forum, color: Colors.white, size: 20),
        ),

        // Priority indicator
        if (thread.priority != ThreadPriority.normal)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getPriorityColor(thread.priority),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                _getPriorityIcon(thread.priority),
                size: 8,
                color: Colors.white,
              ),
            ),
          ),

        // Pin indicator
        if (thread.isPinned)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.amber[600],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Icon(Icons.push_pin, size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildThreadTitle(Thread thread, int unreadCount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            thread.title,
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              color: thread.isActive ? Colors.black87 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Unread count badge
        if (unreadCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[500],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // Status indicators
        const SizedBox(width: 4),
        if (!thread.isActive) _buildStatusIcon(thread),
      ],
    );
  }

  Widget _buildThreadSubtitle(Thread thread) {
    final latestMessage = thread.latestMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thread stats
        Row(
          children: [
            Icon(Icons.message, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 2),
            Text(
              '${thread.messageCount}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.people, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 2),
            Text(
              '${thread.activeParticipantCount}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              _formatLastActivity(thread.lastActivityAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),

        // Latest message preview
        if (latestMessage != null) ...[
          const SizedBox(height: 2),
          Text(
            latestMessage.content.length > 50
                ? '${latestMessage.content.substring(0, 50)}...'
                : latestMessage.content,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildThreadTrailing(Thread thread) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Participant avatars
        if (thread.participants.isNotEmpty)
          _buildParticipantAvatars(thread.participants.take(3).toList()),

        const SizedBox(height: 4),

        // More participants indicator
        if (thread.participants.length > 3)
          Text(
            '+${thread.participants.length - 3}',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildParticipantAvatars(List<ThreadParticipant> participants) {
    return SizedBox(
      width: 60,
      height: 20,
      child: Stack(
        children: participants.asMap().entries.map((entry) {
          final index = entry.key;
          final participant = entry.value;

          return Positioned(
            left: index * 15.0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.grey[300],
              child: participant.avatar?.isNotEmpty == true
                  ? ClipOval(
                      child: Image.network(
                        participant.avatar!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildParticipantInitials(participant.displayName),
                      ),
                    )
                  : _buildParticipantInitials(participant.displayName),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParticipantInitials(String displayName) {
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
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Thread thread) {
    IconData icon;
    Color color;

    switch (thread.status) {
      case ThreadStatus.archived:
        icon = Icons.archive;
        color = Colors.grey;
        break;
      case ThreadStatus.closed:
        icon = Icons.lock;
        color = Colors.red;
        break;
      case ThreadStatus.deleted:
        icon = Icons.delete;
        color = Colors.red;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;

    switch (_currentFilter) {
      case ThreadListFilter.unread:
        message = 'No unread threads';
        subtitle = 'All caught up!';
        break;
      case ThreadListFilter.pinned:
        message = 'No pinned threads';
        subtitle = 'Pin important threads to keep them at the top';
        break;
      case ThreadListFilter.archived:
        message = 'No archived threads';
        subtitle = 'Archived threads will appear here';
        break;
      default:
        message = 'No threads yet';
        subtitle = 'Start a conversation with a new thread';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (widget.enableCreate && widget.onCreateThread != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onCreateThread,
              icon: const Icon(Icons.add_comment),
              label: const Text('Create Thread'),
            ),
          ],
        ],
      ),
    );
  }

  Color _getThreadColor(Thread thread) {
    if (!thread.isActive) return Colors.grey;

    switch (thread.priority) {
      case ThreadPriority.urgent:
        return Colors.red[600]!;
      case ThreadPriority.high:
        return Colors.orange[600]!;
      case ThreadPriority.low:
        return Colors.grey[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  Color _getPriorityColor(ThreadPriority priority) {
    switch (priority) {
      case ThreadPriority.urgent:
        return Colors.red[600]!;
      case ThreadPriority.high:
        return Colors.orange[600]!;
      case ThreadPriority.low:
        return Colors.grey[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getPriorityIcon(ThreadPriority priority) {
    switch (priority) {
      case ThreadPriority.urgent:
        return Icons.keyboard_double_arrow_up;
      case ThreadPriority.high:
        return Icons.keyboard_arrow_up;
      case ThreadPriority.low:
        return Icons.keyboard_arrow_down;
      default:
        return Icons.remove;
    }
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _updateFilteredThreads();
      }
    });
  }

  void _showThreadActions(Thread thread) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                thread.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(thread.isPinned ? 'Unpin Thread' : 'Pin Thread'),
              onTap: () {
                Navigator.pop(context);
                widget.onTogglePin?.call(thread, !thread.isPinned);
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Change Priority'),
              onTap: () {
                Navigator.pop(context);
                _showPriorityDialog(thread);
              },
            ),
            if (thread.isActive)
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archive Thread'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onArchiveThread?.call(thread);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Thread',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(thread);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityDialog(Thread thread) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThreadPriority.values.map((priority) {
            return RadioListTile<ThreadPriority>(
              title: Text(_getPriorityLabel(priority)),
              value: priority,
              groupValue: thread.priority,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  widget.onChangePriority?.call(thread, value);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getPriorityLabel(ThreadPriority priority) {
    switch (priority) {
      case ThreadPriority.urgent:
        return 'Urgent';
      case ThreadPriority.high:
        return 'High';
      case ThreadPriority.normal:
        return 'Normal';
      case ThreadPriority.low:
        return 'Low';
    }
  }

  void _confirmDelete(Thread thread) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread'),
        content: Text(
          'Are you sure you want to delete "${thread.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteThread?.call(thread);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Filter options for thread list
enum ThreadListFilter { all, active, archived, pinned, unread, participating }

/// Sort options for thread list
enum ThreadListSort { lastActivity, created, title, priority, messageCount }
