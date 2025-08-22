import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/chat_theme.dart';

class EnhancedReactionPicker extends StatefulWidget {
  final Function(String emoji) onEmojiSelected;
  final VoidCallback onClose;
  final bool enableAnimations;

  const EnhancedReactionPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onClose,
    this.enableAnimations = true,
  });

  /// Show the emoji picker as a bottom sheet with smooth animations
  static Future<void> show(
    BuildContext context, {
    required Function(String emoji) onEmojiSelected,
    bool enableAnimations = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      transitionAnimationController: enableAnimations
          ? AnimationController(
              duration: ChatDesignTokens.normalAnimation,
              vsync: Navigator.of(context),
            )
          : null,
      builder: (context) => EnhancedReactionPicker(
        onEmojiSelected: onEmojiSelected,
        onClose: () => Navigator.of(context).pop(),
        enableAnimations: enableAnimations,
      ),
    );
  }

  @override
  State<EnhancedReactionPicker> createState() => _EnhancedReactionPickerState();
}

class _EnhancedReactionPickerState extends State<EnhancedReactionPicker>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    if (!widget.enableAnimations) return;

    _slideController = AnimationController(
      duration: ChatDesignTokens.normalAnimation,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: ChatDesignTokens.fastAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: ChatDesignTokens.smoothCurve,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: ChatDesignTokens.defaultCurve,
      ),
    );
  }

  void _startEntryAnimation() {
    if (!widget.enableAnimations) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.enableAnimations) {
      _slideController.dispose();
      _fadeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    Widget content = Container(
      height: 420,
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ChatDesignTokens.radiusXl),
        ),
        boxShadow: theme.enableBubbleShadows && theme.bubbleShadow != null
            ? [
                theme.bubbleShadow!.copyWith(
                  color: theme.bubbleShadow!.color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: ChatDesignTokens.spaceSm),
            decoration: BoxDecoration(
              color: theme.borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with enhanced styling
          _buildHeader(theme),

          // Quick reactions bar
          _buildQuickReactions(theme),

          // Search bar with smooth animations
          _buildSearchBar(theme),

          // Emoji picker with enhanced configuration
          _buildEmojiPicker(theme),
        ],
      ),
    );

    if (!widget.enableAnimations) {
      return content;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: content),
        );
      },
    );
  }

  Widget _buildHeader(ChatThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ChatDesignTokens.spaceLg),
      child: Row(
        children: [
          Icon(Icons.emoji_emotions, color: theme.accentColor, size: 24),
          SizedBox(width: ChatDesignTokens.spaceXs),
          Text(
            'Add Reaction',
            style: theme.headerTextStyle.copyWith(color: theme.accentColor),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(ChatDesignTokens.radiusSm),
              onTap: widget.onClose,
              child: Container(
                padding: EdgeInsets.all(ChatDesignTokens.spaceXs),
                child: Icon(Icons.close, color: theme.timestampColor, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReactions(ChatThemeData theme) {
    return QuickReactionBar(
      onEmojiSelected: (emoji) {
        HapticFeedback.lightImpact();
        widget.onEmojiSelected(emoji);
        widget.onClose();
      },
      theme: theme,
      enableAnimations: widget.enableAnimations,
    );
  }

  Widget _buildSearchBar(ChatThemeData theme) {
    return AnimatedContainer(
      duration: ChatDesignTokens.fastAnimation,
      curve: ChatDesignTokens.defaultCurve,
      margin: EdgeInsets.symmetric(
        horizontal: ChatDesignTokens.spaceLg,
        vertical: ChatDesignTokens.spaceXs,
      ),
      child: TextField(
        controller: _searchController,
        style: theme.messageTextStyle,
        decoration: InputDecoration(
          hintText: 'Search emojis...',
          hintStyle: theme.timestampTextStyle,
          prefixIcon: Icon(Icons.search, color: theme.timestampColor, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      ChatDesignTokens.radiusSm,
                    ),
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(ChatDesignTokens.spaceXs),
                      child: Icon(
                        Icons.clear,
                        color: theme.timestampColor,
                        size: 18,
                      ),
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.backgroundColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ChatDesignTokens.spaceLg,
            vertical: ChatDesignTokens.spaceMd,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
        onTap: () {
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  Widget _buildEmojiPicker(ChatThemeData theme) {
    return Expanded(
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          HapticFeedback.lightImpact();
          widget.onEmojiSelected(emoji.emoji);
          widget.onClose();
        },
        textEditingController: _searchController,
        config: Config(
          columns: 8,
          emojiSizeMax: 26.0,
          bgColor: Colors.transparent,
          indicatorColor: theme.accentColor,
          iconColor: theme.timestampColor,
          iconColorSelected: theme.accentColor,
          backspaceColor: theme.accentColor,
          skinToneDialogBgColor: theme.surfaceColor,
          skinToneIndicatorColor: theme.timestampColor,
          enableSkinTones: true,
          recentTabBehavior: RecentTabBehavior.RECENT,
          recentsLimit: 32,
          categoryIcons: CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
          checkPlatformCompatibility: true,
        ),
      ),
    );
  }
}

/// Quick reaction bar for frequently used emojis with enhanced animations
class QuickReactionBar extends StatefulWidget {
  final Function(String emoji) onEmojiSelected;
  final List<String> quickEmojis;
  final ChatThemeData theme;
  final bool enableAnimations;

  const QuickReactionBar({
    super.key,
    required this.onEmojiSelected,
    required this.theme,
    this.quickEmojis = const ['👍', '❤️', '😂', '😮', '😢', '😡'],
    this.enableAnimations = true,
  });

  @override
  State<QuickReactionBar> createState() => _QuickReactionBarState();
}

class _QuickReactionBarState extends State<QuickReactionBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimations) {
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.quickEmojis.length,
      (index) => AnimationController(
        duration: ChatDesignTokens.fastAnimation,
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: controller,
          curve: ChatDesignTokens.bounceCurve,
        ),
      );
    }).toList();

    // Staggered entry animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _controllers.length; i++) {
        if (mounted) {
          Future.delayed(Duration(milliseconds: i * 50), () {
            if (mounted) {
              _controllers[i].forward();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      for (final controller in _controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ChatDesignTokens.spaceLg,
        vertical: ChatDesignTokens.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.quickEmojis.asMap().entries.map((entry) {
          final index = entry.key;
          final emoji = entry.value;

          Widget emojiButton = Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
              onTap: () => _handleEmojiTap(index, emoji),
              onTapDown: (_) => _handleTapDown(index),
              onTapUp: (_) => _handleTapUp(index),
              onTapCancel: () => _handleTapUp(index),
              child: AnimatedContainer(
                duration: ChatDesignTokens.fastAnimation,
                curve: ChatDesignTokens.defaultCurve,
                padding: EdgeInsets.all(ChatDesignTokens.spaceMd),
                decoration: BoxDecoration(
                  color: _pressedIndex == index
                      ? widget.theme.accentColor.withOpacity(0.1)
                      : widget.theme.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    ChatDesignTokens.radiusLg,
                  ),
                  border: Border.all(
                    color: widget.theme.borderColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow:
                      widget.theme.enableBubbleShadows &&
                          widget.theme.bubbleShadow != null
                      ? [
                          widget.theme.bubbleShadow!.copyWith(
                            color: widget.theme.bubbleShadow!.color.withOpacity(
                              0.1,
                            ),
                          ),
                        ]
                      : null,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          );

          if (!widget.enableAnimations) {
            return emojiButton;
          }

          return AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: emojiButton,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _handleEmojiTap(int index, String emoji) {
    widget.onEmojiSelected(emoji);

    if (widget.enableAnimations) {
      _controllers[index].reverse().then((_) {
        _controllers[index].forward();
      });
    }
  }

  void _handleTapDown(int index) {
    if (mounted) {
      setState(() => _pressedIndex = index);
    }
  }

  void _handleTapUp(int index) {
    if (mounted) {
      setState(() => _pressedIndex = null);
    }
  }
}
