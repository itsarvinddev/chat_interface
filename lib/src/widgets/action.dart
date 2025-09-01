import 'package:chatui/chatui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

class ChatAction extends StatelessWidget {
  final ChatMessage message;
  const ChatAction({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Action message: ${message.message}',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
        ),
      ),
    );
  }
}
