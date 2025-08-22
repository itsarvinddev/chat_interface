import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/chat_theme.dart';

class TypingIndicator extends StatefulWidget {
  final TypingState typingState;
  final bool showNames;
  final bool enableAnimations;

  const TypingIndicator({
    super.key,
    required this.typingState,
    this.showNames = true,
    this.enableAnimations = true,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    if (!widget.enableAnimations) return;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animations when typing users are present
    if (widget.typingState.hasTypingUsers) {
      _slideController.forward();
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enableAnimations) {
      if (widget.typingState.hasTypingUsers &&
          !oldWidget.typingState.hasTypingUsers) {
        _slideController.forward();
        _fadeController.forward();
      } else if (!widget.typingState.hasTypingUsers &&
          oldWidget.typingState.hasTypingUsers) {
        _slideController.reverse();
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      _slideController.dispose();
      _fadeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    if (!widget.typingState.hasTypingUsers) {
      return const SizedBox.shrink();
    }

    final activeUsers = widget.typingState.activeTypingUsers;
    if (activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget content = Container(
      margin: EdgeInsets.symmetric(
        horizontal: ChatDesignTokens.spaceLg,
        vertical: ChatDesignTokens.spaceXs,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ChatDesignTokens.spaceMd,
        vertical: ChatDesignTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: theme.incomingBubbleColor,
        borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
        boxShadow: theme.enableBubbleShadows && theme.bubbleShadow != null
            ? [
                theme.bubbleShadow!.copyWith(
                  color: theme.bubbleShadow!.color.withOpacity(0.1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced typing animation
          _EnhancedTypingDots(
            theme: theme,
            enableAnimations: widget.enableAnimations,
          ),
          SizedBox(width: ChatDesignTokens.spaceXs),
          // Typing text with enhanced styling
          Flexible(
            child: Text(
              _buildTypingText(activeUsers),
              style: theme.timestampTextStyle.copyWith(
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (!widget.enableAnimations) {
      return Align(alignment: Alignment.centerLeft, child: content);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(alignment: Alignment.centerLeft, child: content),
          ),
        );
      },
    );
  }

  String _buildTypingText(List<TypingUser> users) {
    if (users.length == 1) {
      return '${users.first.user.displayName} is typing...';
    } else if (users.length == 2) {
      return '${users.first.user.displayName} and ${users.last.user.displayName} are typing...';
    } else if (users.length == 3) {
      return '${users.first.user.displayName}, ${users[1].user.displayName}, and ${users.last.user.displayName} are typing...';
    } else {
      return '${users.length} people are typing...';
    }
  }
}

class _EnhancedTypingDots extends StatefulWidget {
  final ChatThemeData theme;
  final bool enableAnimations;

  const _EnhancedTypingDots({
    required this.theme,
    this.enableAnimations = true,
  });

  @override
  State<_EnhancedTypingDots> createState() => _EnhancedTypingDotsState();
}

class _EnhancedTypingDotsState extends State<_EnhancedTypingDots>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<double>> _scaleAnimations = [];
  List<Animation<double>> _opacityAnimations = [];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    if (!widget.enableAnimations) return;

    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start animations with staggered timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted && !_disposed) {
            _controllers[i].repeat(reverse: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    if (_controllers.isNotEmpty) {
      for (final controller in _controllers) {
        controller.stop();
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimations) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 1),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.theme.timestampColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _opacityAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.theme.accentColor.withOpacity(
                    _opacityAnimations[index].value,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.accentColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Compact typing indicator for use in channel headers
class CompactTypingIndicator extends StatelessWidget {
  final TypingState typingState;
  final bool enableAnimations;

  const CompactTypingIndicator({
    super.key,
    required this.typingState,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    if (!typingState.hasTypingUsers) {
      return const SizedBox.shrink();
    }

    final activeUsers = typingState.activeTypingUsers;
    if (activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: ChatDesignTokens.fastAnimation,
      child: Container(
        key: const ValueKey('typing'),
        padding: EdgeInsets.symmetric(
          horizontal: ChatDesignTokens.spaceXs,
          vertical: ChatDesignTokens.space2xs,
        ),
        decoration: BoxDecoration(
          color: theme.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ChatDesignTokens.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EnhancedTypingDots(
              theme: theme,
              enableAnimations: enableAnimations,
            ),
            SizedBox(width: ChatDesignTokens.space2xs),
            Text(
              _buildCompactText(activeUsers),
              style: theme.captionTextStyle.copyWith(
                color: theme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildCompactText(List<TypingUser> users) {
    if (users.length == 1) {
      return '${users.first.user.displayName} typing...';
    } else if (users.length == 2) {
      return '${users.first.user.displayName} +1 typing...';
    } else {
      return '${users.length} typing...';
    }
  }
}
