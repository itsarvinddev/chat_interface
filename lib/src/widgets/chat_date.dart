import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

class ChatDate extends StatelessWidget {
  const ChatDate({
    super.key,
    required this.date,
    this.shouldBeTransparent = false,
  });

  final String date;
  final bool shouldBeTransparent;

  @override
  Widget build(BuildContext context) {
    double transparency = shouldBeTransparent ? 0.2 : 1;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.theme.colorScheme.tertiaryContainer.withValues(
          alpha: transparency,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 24),
      child: Text(
        date,
        style: TextStyle(
          color: context.theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
