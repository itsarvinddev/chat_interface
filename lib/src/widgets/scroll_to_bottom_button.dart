import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/chat_theme.dart';

class ScrollToBottomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool visible;
  final int unreadCount;
  final bool enableAnimations;

  const ScrollToBottomButton({
    super.key,
    required this.onPressed,
    required this.visible,
    this.unreadCount = 0,
    this.enableAnimations = true,
  });

  @override
  State<ScrollToBottomButton> createState() => _ScrollToBottomButtonState();
}

class _ScrollToBottomButtonState extends State<ScrollToBottomButton>
    with TickerProviderStateMixin {
  late AnimationController _visibilityController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    if (!widget.enableAnimations) return;

    _visibilityController = AnimationController(
      duration: ChatDesignTokens.normalAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _visibilityController,
        curve: ChatDesignTokens.bounceCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _visibilityController,
        curve: ChatDesignTokens.defaultCurve,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _visibilityController,
            curve: ChatDesignTokens.smoothCurve,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulse animation if there are unread messages
    if (widget.unreadCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScrollToBottomButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enableAnimations) return;

    // Handle visibility changes
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _visibilityController.forward();
      } else {
        _visibilityController.reverse();
      }
    }

    // Handle unread count changes
    if (widget.unreadCount != oldWidget.unreadCount) {
      if (widget.unreadCount > 0 && oldWidget.unreadCount == 0) {
        _pulseController.repeat(reverse: true);
      } else if (widget.unreadCount == 0 && oldWidget.unreadCount > 0) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      _visibilityController.dispose();
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    Widget button = Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.accentColor,
          shape: BoxShape.circle,
          boxShadow: theme.enableBubbleShadows && theme.bubbleShadow != null
              ? [
                  theme.bubbleShadow!.copyWith(
                    color: theme.bubbleShadow!.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onPressed();
          },
          child: SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main icon
                Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.surfaceColor,
                  size: 28,
                ),

                // Unread count badge
                if (widget.unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.errorColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.surfaceColor, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        widget.unreadCount > 99
                            ? '99+'
                            : '${widget.unreadCount}',
                        style: theme.captionTextStyle.copyWith(
                          color: theme.surfaceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.enableAnimations) {
      return Positioned(bottom: 16, right: 16, child: button);
    }

    return Positioned(
      bottom: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: Listenable.merge([_visibilityController, _pulseController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Transform.scale(
                  scale: widget.unreadCount > 0 ? _pulseAnimation.value : 1.0,
                  child: button,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
