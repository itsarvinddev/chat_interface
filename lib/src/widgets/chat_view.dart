import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../theme/chat_theme.dart';
import 'channel_header.dart';
import 'composer.dart';
import 'message_list_view.dart';
import 'scroll_to_bottom_button.dart';

/// High-level chat screen widget combining list and composer.
class ChatView extends StatefulWidget {
  final ChatController controller;
  final ChatThemeData? theme;

  const ChatView({super.key, required this.controller, this.theme});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final bool atBottom = _scrollController.position.extentAfter < 50;
    if (_showScrollToBottom == atBottom) {
      setState(() => _showScrollToBottom = !atBottom);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Scaffold(
      appBar: ChannelHeader(controller: widget.controller),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: MessageListView(
                  controller: widget.controller,
                  scrollController: _scrollController,
                ),
              ),
              const Divider(height: 1),
              Composer(controller: widget.controller),
            ],
          ),
          ScrollToBottomButton(
            visible: _showScrollToBottom,
            onPressed: () {
              if (!_scrollController.hasClients) return;
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
    );

    if (widget.theme != null) {
      return ChatTheme(data: widget.theme!, child: content);
    }
    return content;
  }
}
