import 'package:flutter/material.dart';

import '../models/quick_replies.dart';

class EnhancedQuickReplyPicker extends StatefulWidget {
  final Function(String text) onQuickReplySelected;
  final VoidCallback onClose;
  final List<QuickReplyCategory> categories;
  final bool showSearch;

  const EnhancedQuickReplyPicker({
    super.key,
    required this.onQuickReplySelected,
    required this.onClose,
    this.categories = DefaultQuickReplies.categories,
    this.showSearch = true,
  });

  /// Show the quick reply picker as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(String text) onQuickReplySelected,
    List<QuickReplyCategory>? categories,
    bool showSearch = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedQuickReplyPicker(
        onQuickReplySelected: onQuickReplySelected,
        onClose: () => Navigator.of(context).pop(),
        categories: categories ?? DefaultQuickReplies.categories,
        showSearch: showSearch,
      ),
    );
  }

  @override
  State<EnhancedQuickReplyPicker> createState() => _EnhancedQuickReplyPickerState();
}

class _EnhancedQuickReplyPickerState extends State<EnhancedQuickReplyPicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  List<QuickReplyCategory> _filteredCategories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.categories.length, vsync: this);
    _searchController = TextEditingController();
    _filteredCategories = widget.categories;
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories.map((category) {
          final filteredReplies = category.replies.where((reply) {
            return reply.text.toLowerCase().contains(_searchQuery) ||
                   (reply.emoji != null && reply.emoji!.contains(_searchQuery));
          }).toList();
          
          return QuickReplyCategory(
            id: category.id,
            name: category.name,
            icon: category.icon,
            replies: filteredReplies,
          );
        }).where((category) => category.replies.isNotEmpty).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  'Quick Replies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Search bar
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search quick replies...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

          // Category tabs
          if (_filteredCategories.length > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                tabs: _filteredCategories.map((category) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category.icon != null) ...[
                          Text(category.icon!),
                          const SizedBox(width: 4),
                        ],
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Quick replies content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _filteredCategories.map((category) {
                return _QuickReplyGrid(
                  category: category,
                  onQuickReplySelected: widget.onQuickReplySelected,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReplyGrid extends StatelessWidget {
  final QuickReplyCategory category;
  final Function(String text) onQuickReplySelected;

  const _QuickReplyGrid({
    required this.category,
    required this.onQuickReplySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: category.replies.length,
      itemBuilder: (context, index) {
        final reply = category.replies[index];
        return _QuickReplyChip(
          reply: reply,
          onTap: () => onQuickReplySelected(reply.text),
        );
      },
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final QuickReply reply;
  final VoidCallback onTap;

  const _QuickReplyChip({
    required this.reply,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: reply.type == QuickReplyType.emoji
              ? Text(
                  reply.text,
                  style: const TextStyle(fontSize: 24),
                )
              : Text(
                  reply.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}
