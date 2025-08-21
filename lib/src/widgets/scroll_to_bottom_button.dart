import 'package:flutter/material.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool visible;

  const ScrollToBottomButton({
    super.key,
    required this.onPressed,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FloatingActionButton.small(
          heroTag: 'scrollToBottom',
          onPressed: onPressed,
          child: const Icon(Icons.arrow_downward),
        ),
      ),
    );
  }
}
