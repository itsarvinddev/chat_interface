import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../theme/chat_theme.dart';
import '../utils/image_utils.dart';
import '../utils/markdown_parser.dart';
import 'attachment_picker.dart';
import 'audio_recorder_bar.dart';
import 'enhanced_quick_reply_picker.dart';
import 'location_picker.dart';

class Composer extends StatefulWidget {
  final ChatController controller;
  const Composer({super.key, required this.controller});

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  late TextEditingController _textController;
  MarkdownTextEditingController? _markdownController;
  bool _showMarkdown = false;
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _showRecorder = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _markdownController = MarkdownTextEditingController(
      styles: MarkdownTextStyles(),
    );

    // Sync text between controllers
    _textController.addListener(() {
      if (_markdownController != null && !_showMarkdown) {
        _markdownController!.text = _textController.text;
      }
    });

    _markdownController!.addListener(() {
      if (_showMarkdown) {
        _textController.text = _markdownController!.text;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _markdownController?.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _toggleMarkdown() {
    setState(() {
      _showMarkdown = !_showMarkdown;
      if (_showMarkdown) {
        _markdownController = MarkdownTextEditingController(
          text: _textController.text,
          styles: ChatTheme.of(context).markdownStyles,
        );
        _markdownController!.addListener(() {
          _textController.text = _markdownController!.text;
        });
      } else {
        _markdownController?.dispose();
        _markdownController = null;
      }
    });
  }

  void _handleTyping(String text) {
    // Cancel existing timer
    _typingTimer?.cancel();

    // Set typing status
    widget.controller.setTyping(text.isNotEmpty);

    // Set timer to stop typing after 3 seconds of inactivity
    if (text.isNotEmpty) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        widget.controller.setTyping(false);
      });
    }
  }

  void _toggleRecorder() {
    setState(() => _showRecorder = !_showRecorder);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: widget.controller.replyTo,
            builder: (BuildContext context, dynamic reply, Widget? child) {
              if (reply == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.reply, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reply.text ?? '[${reply.kind.name}]',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cancel reply',
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.controller.replyTo.value = null,
                    ),
                  ],
                ),
              );
            },
          ),
          if (_showRecorder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AudioRecorderBar(
                onFinished: (attachment) {
                  setState(() => _showRecorder = false);
                  if (attachment != null) {
                    widget.controller.addAttachment(attachment);
                  }
                },
                onCancel: () => setState(() => _showRecorder = false),
              ),
            ),
          Row(
            children: <Widget>[
              // Attachment button
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {
                  AttachmentPicker.show(
                    context,
                    onAttachmentsSelected: (attachments) {
                      for (final attachment in attachments) {
                        widget.controller.addAttachment(attachment);
                      }
                    },
                    maxAttachments: 10,
                    maxFileSize: 50 * 1024 * 1024, // 50MB
                  );
                },
                tooltip: 'Add Attachment',
              ),
              // Audio recorder toggle
              IconButton(
                icon: Icon(
                  _showRecorder ? Icons.mic_off : Icons.mic,
                  color: _showRecorder
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                tooltip: _showRecorder ? 'Hide recorder' : 'Record audio',
                onPressed: _toggleRecorder,
              ),
              // Location button
              IconButton(
                icon: const Icon(Icons.location_on),
                tooltip: 'Share Location',
                onPressed: () {
                  LocationPicker.show(
                    context,
                    onLocationSelected: (location) {
                      // Convert LocationAttachment to regular Attachment for compatibility
                      final attachment = location.toAttachment();
                      widget.controller.addAttachment(attachment);
                    },
                  );
                },
              ),
              IconButton(
                tooltip: 'Toggle markdown',
                icon: Icon(
                  _showMarkdown ? Icons.code : Icons.code_off,
                  color: _showMarkdown
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: _toggleMarkdown,
              ),
              if (_showMarkdown)
                IconButton(
                  tooltip:
                      'Markdown help: *bold* _italic_ `code` ~strike~ ```block```',
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Markdown: *bold* _italic_ `code` ~strike~ ```block```',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              Expanded(
                child: TextField(
                  controller: _showMarkdown
                      ? _markdownController
                      : _textController,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                  onChanged: _handleTyping,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final String text = _textController.text.trim();
                  if (text.isEmpty &&
                      widget.controller.draftAttachments.value.isEmpty)
                    return;
                  if (text.isNotEmpty) {
                    await widget.controller.sendText(text);
                  }
                  _textController.clear();
                  if (_markdownController != null) {
                    _markdownController!.clear();
                  }
                },
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget.controller.draftAttachments,
            builder:
                (BuildContext context, dynamic attachments, Widget? child) {
                  final List<Attachment> list = attachments as List<Attachment>;
                  if (list.isEmpty) return const SizedBox.shrink();
                  return Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final Attachment a = list[index];
                        return _DraftAttachmentCard(
                          attachment: a,
                          onRemove: () =>
                              widget.controller.removeAttachmentAt(index),
                        );
                      },
                      separatorBuilder: (BuildContext context, int i) =>
                          const SizedBox(width: 8),
                      itemCount: list.length,
                    ),
                  );
                },
          ),
          // Quick replies button
          IconButton(
            icon: const Icon(Icons.reply_all),
            onPressed: () {
              EnhancedQuickReplyPicker.show(
                context,
                onQuickReplySelected: (text) {
                  // Insert the quick reply text into the composer
                  if (_showMarkdown) {
                    _markdownController!.text = text;
                  } else {
                    _textController.text = text;
                  }
                  // Focus the text field
                  FocusScope.of(context).requestFocus(_focusNode);
                },
              );
            },
            tooltip: 'Quick Replies',
          ),
        ],
      ),
    );
  }
}

class _DraftAttachmentCard extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onRemove;

  const _DraftAttachmentCard({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Thumbnail
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageUtils.buildThumbnail(attachment, size: 70),
            ),
          ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
