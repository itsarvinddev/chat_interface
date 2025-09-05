import 'package:flutter/material.dart';

import '../theme/chat_theme_provider.dart';

class ChatField extends StatelessWidget {
  const ChatField({
    super.key,
    required this.leading,
    this.actions,
    required this.textController,
    this.onTextChanged,
    this.focusNode,
    this.onSubmitted,
  });

  final Widget leading;
  final List<Widget>? actions;
  final TextEditingController textController;
  final Function(String)? onTextChanged;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  @override
  Widget build(BuildContext context) {
    final chatTheme = ChatThemeProvider.of(context);
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: chatTheme.inputBorderRadius,
        color: chatTheme.inputBackgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading,
          Expanded(
            child: TextField(
              onChanged: onTextChanged,
              controller: textController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 6,
              minLines: 1,
              cursorColor: chatTheme.primaryColor,
              cursorHeight: 20,
              style: chatTheme.inputTextStyle,
              decoration: chatTheme.inputDecoration,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onSubmitted: onSubmitted,
            ),
          ),
          if (actions != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: actions ?? [],
            ),
          ],
        ],
      ),
    );
  }
}
