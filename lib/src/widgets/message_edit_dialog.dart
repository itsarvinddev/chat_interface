import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../utils/markdown_parser.dart';

class MessageEditDialog extends StatefulWidget {
  final Message message;
  final ChatController controller;
  final VoidCallback onClose;

  const MessageEditDialog({
    super.key,
    required this.message,
    required this.controller,
    required this.onClose,
  });

  /// Show the message edit dialog
  static Future<void> show(
    BuildContext context, {
    required Message message,
    required ChatController controller,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MessageEditDialog(
        message: message,
        controller: controller,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<MessageEditDialog> createState() => _MessageEditDialogState();
}

class _MessageEditDialogState extends State<MessageEditDialog> {
  late TextEditingController _textController;
  late MarkdownTextEditingController _markdownController;
  bool _showMarkdown = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.message.text ?? '');
    _markdownController = MarkdownTextEditingController(
      text: widget.message.text ?? '',
      styles: MarkdownTextStyles(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _markdownController.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    if (_isLoading) return;

    final String newText = _showMarkdown
        ? _markdownController.text.trim()
        : _textController.text.trim();

    if (newText.isEmpty) {
      setState(() {
        _errorMessage = 'Message text cannot be empty';
      });
      return;
    }

    if (newText == widget.message.text) {
      widget.onClose();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.controller.editMessageText(widget.message, newText);
      widget.onClose();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit, size: 20),
          const SizedBox(width: 8),
          const Text('Edit Message'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            iconSize: 20,
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original message preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Original:',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message.text ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Edit options
            Row(
              children: [
                Text(
                  'Edit as:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Plain Text'),
                        selected: !_showMarkdown,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _showMarkdown = false;
                              _textController.text = _markdownController.text;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Markdown'),
                        selected: _showMarkdown,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _showMarkdown = true;
                              _markdownController.text = _textController.text;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Text input
            if (_showMarkdown) ...[
              TextField(
                controller: _markdownController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Edit your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      _showMarkdownHelp(context);
                    },
                    tooltip: 'Markdown Help',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Markdown preview
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: MarkdownText(
                  text: _markdownController.text.isEmpty
                      ? 'Preview will appear here'
                      : _markdownController.text,
                  styles: MarkdownTextStyles(),
                ),
              ),
            ] else ...[
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Edit your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Cancel')),
        FilledButton(
          onPressed: _isLoading ? null : _saveEdit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  void _showMarkdownHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Markdown Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('**bold** - Bold text'),
            Text('*italic* - Italic text'),
            Text('~strikethrough~ - Strikethrough text'),
            Text('`code` - Inline code'),
            Text('```\ncode block\n``` - Code block'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
