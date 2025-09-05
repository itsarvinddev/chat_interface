import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

class ChatAction extends StatelessWidget {
  final ChatMessage message;
  const ChatAction({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message.message,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: context.theme.textTheme.labelSmall?.copyWith(
        color: context.theme.colorScheme.onPrimaryContainer,
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: context.mediaQuery.size.width * 0.2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.message,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.labelSmall?.copyWith(
            color: context.theme.colorScheme.onPrimaryContainer,
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
      ),
    );
  }
}
