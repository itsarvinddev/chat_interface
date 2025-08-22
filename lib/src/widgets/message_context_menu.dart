import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import 'enhanced_reaction_picker.dart';
import 'message_delete_dialog.dart';
import 'message_edit_dialog.dart';

class MessageContextMenu extends StatelessWidget {
  final Message message;
  final ChatController controller;
  final VoidCallback onClose;

  const MessageContextMenu({
    super.key,
    required this.message,
    required this.controller,
    required this.onClose,
  });

  /// Show the message context menu as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Message message,
    required ChatController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageContextMenu(
        message: message,
        controller: controller,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Message Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Action options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Reply option
                  _ContextMenuItem(
                    icon: Icons.reply,
                    title: 'Reply',
                    subtitle: 'Reply to this message',
                    onTap: () {
                      controller.setReplyTo(message);
                      onClose();
                    },
                  ),

                  // React option
                  _ContextMenuItem(
                    icon: Icons.emoji_emotions,
                    title: 'Add Reaction',
                    subtitle: 'React with an emoji',
                    onTap: () async {
                      onClose();
                      await EnhancedReactionPicker.show(
                        context,
                        onEmojiSelected: (emoji) {
                          controller.toggleReaction(message, emoji);
                        },
                      );
                    },
                  ),

                  // Create Thread option
                  _ContextMenuItem(
                    icon: Icons.forum,
                    title: 'Start Thread',
                    subtitle: 'Create a thread from this message',
                    onTap: () {
                      onClose();
                      _showThreadCreationDialog(context);
                    },
                  ),

                  // Create Thread option
                  _ContextMenuItem(
                    icon: Icons.forum,
                    title: 'Start Thread',
                    subtitle: 'Create a thread from this message',
                    onTap: () {
                      onClose();
                      _showThreadCreationDialog(context);
                    },
                  ),

                  // Edit option (if applicable)
                  if (controller.canEditMessage(message))
                    _ContextMenuItem(
                      icon: Icons.edit,
                      title: 'Edit Message',
                      subtitle: 'Modify this message',
                      onTap: () {
                        onClose();
                        MessageEditDialog.show(
                          context,
                          message: message,
                          controller: controller,
                        );
                      },
                    ),

                  // Delete option (if applicable)
                  if (controller.canDeleteMessage(message))
                    _ContextMenuItem(
                      icon: Icons.delete_outline,
                      title: 'Delete Message',
                      subtitle: 'Remove this message',
                      onTap: () async {
                        onClose();
                        await MessageDeleteDialog.show(
                          context,
                          message: message,
                          controller: controller,
                        );
                      },
                      isDestructive: true,
                    ),

                  // Copy option
                  _ContextMenuItem(
                    icon: Icons.copy,
                    title: 'Copy Text',
                    subtitle: 'Copy message content',
                    onTap: () {
                      // TODO: Implement copy to clipboard
                      onClose();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text copied to clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show thread creation dialog
  void _showThreadCreationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Thread'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Thread Title',
                hintText: 'Enter a title for the thread',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add a description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                try {
                  await controller.createThread(
                    originalMessage: message,
                    title: title,
                    description: descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : null,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thread "$title" created!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create thread: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ContextMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: iconColor, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
