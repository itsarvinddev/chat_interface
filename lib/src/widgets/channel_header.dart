import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import 'typing_indicator.dart';

class ChannelHeader extends StatelessWidget implements PreferredSizeWidget {
  final ChatController controller;
  const ChannelHeader({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased height to prevent overflow

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            const _PresenceDot(),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller.channel,
                builder:
                    (BuildContext context, dynamic channel, Widget? child) {
                      final String title = channel?.name ?? 'Chat';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          ValueListenableBuilder(
                            valueListenable: controller.typing,
                            builder:
                                (
                                  BuildContext context,
                                  TypingState typing,
                                  Widget? child,
                                ) {
                                  return CompactTypingIndicator(
                                    typingState: typing,
                                  );
                                },
                          ),
                        ],
                      );
                    },
              ),
            ),
            IconButton(
              tooltip: 'Info',
              icon: const Icon(Icons.info_outline),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _PresenceDot extends StatelessWidget {
  const _PresenceDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );
  }
}
