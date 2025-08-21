import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EnhancedReactionPicker extends StatefulWidget {
  final Function(String emoji) onEmojiSelected;
  final VoidCallback onClose;

  const EnhancedReactionPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onClose,
  });

  /// Show the emoji picker as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(String emoji) onEmojiSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedReactionPicker(
        onEmojiSelected: onEmojiSelected,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<EnhancedReactionPicker> createState() => _EnhancedReactionPickerState();
}

class _EnhancedReactionPickerState extends State<EnhancedReactionPicker> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Add Reaction',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search emojis...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
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
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Emoji picker
          Expanded(
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                widget.onEmojiSelected(emoji.emoji);
                widget.onClose();
              },
              textEditingController: _searchController,
              config: Config(
                columns: 7,
                emojiSizeMax: 28.0,
                bgColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.primary,
                iconColor: Colors.grey,
                iconColorSelected: Theme.of(context).colorScheme.primary,
                backspaceColor: Theme.of(context).colorScheme.primary,
                skinToneDialogBgColor: Theme.of(context).colorScheme.surface,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                recentTabBehavior: RecentTabBehavior.RECENT,
                recentsLimit: 28,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL,
                checkPlatformCompatibility: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick reaction bar for frequently used emojis
class QuickReactionBar extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;
  final List<String> quickEmojis;

  const QuickReactionBar({
    super.key,
    required this.onEmojiSelected,
    this.quickEmojis = const ['👍', '❤️', '😂', '😮', '😢', '😡'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: quickEmojis.map((emoji) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onEmojiSelected(emoji),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
