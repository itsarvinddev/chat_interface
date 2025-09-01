import 'package:any_link_preview/any_link_preview.dart';
import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

class ChatLinkPreview extends StatelessWidget {
  final ChatMessage message;
  final bool isMessageBySelf;
  const ChatLinkPreview({
    super.key,
    required this.message,
    required this.isMessageBySelf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMessageBySelf ? 0.0 : 10.0,
        top: 6.0,
        right: isMessageBySelf ? 4.0 : 0.0,
        bottom: 6.0,
      ),
      child: AnyLinkPreview(
        key: ValueKey(message.message),
        link: message.message,
        displayDirection: UIDirection.uiDirectionHorizontal,
        bodyMaxLines: 5,
        bodyTextOverflow: TextOverflow.ellipsis,
        backgroundColor: context.theme.colorScheme.surfaceContainerHigh,
        borderRadius: 8,
        titleStyle: context.theme.textTheme.titleMedium?.copyWith(
          color: context.theme.colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyStyle: context.theme.textTheme.labelSmall?.copyWith(
          color: context.theme.colorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
        placeholderWidget: const SizedBox.shrink(),
        errorWidget: const SizedBox.shrink(),
        errorTitle: 'Error',
        errorBody: 'No preview available',
      ),
    );
  }
}
