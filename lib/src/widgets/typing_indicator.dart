import 'package:flutter/material.dart';

import '../models/models.dart';

class TypingIndicator extends StatelessWidget {
  final TypingState typingState;
  final bool showNames;

  const TypingIndicator({
    super.key,
    required this.typingState,
    this.showNames = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!typingState.hasTypingUsers) {
      return const SizedBox.shrink();
    }

    final activeUsers = typingState.activeTypingUsers;
    if (activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Typing animation dots
          _TypingDots(),
          const SizedBox(width: 8),

          // Typing text
          Expanded(
            child: Text(
              _buildTypingText(activeUsers),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
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

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start animations with staggered timing
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted && !_disposed) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final controller in _controllers) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                  0.3 + (_animations[index].value * 0.7),
                ),
                shape: BoxShape.circle,
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

  const CompactTypingIndicator({super.key, required this.typingState});

  @override
  Widget build(BuildContext context) {
    if (!typingState.hasTypingUsers) {
      return const SizedBox.shrink();
    }

    final activeUsers = typingState.activeTypingUsers;
    if (activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypingDots(),
        const SizedBox(width: 4),
        Text(
          _buildCompactText(activeUsers),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
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
