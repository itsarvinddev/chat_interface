import 'package:flutter/material.dart';

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
    final colorTheme = Theme.of(context).colorScheme;
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: Theme.of(context).brightness == Brightness.dark
            ? colorTheme.surfaceContainer
            : colorTheme.surfaceContainerHighest,
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
              cursorColor: colorTheme.primary,
              cursorHeight: 20,
              decoration: const InputDecoration(
                hintText: 'Message',
                border: InputBorder.none,
                isDense: true,
              ),
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
