import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../theme/chat_theme.dart';
import '../utils/image_utils.dart';
import '../utils/link_preview_utils.dart';
import '../utils/markdown_parser.dart';
import '../utils/time_utils.dart';
import 'audio_message_tile.dart';
import 'enhanced_reaction_picker.dart';
import 'location_message_tile.dart';
import 'message_delete_dialog.dart';
import 'message_edit_dialog.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onLongPress;
  final ChatController controller;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ChatThemeData theme = ChatTheme.of(context);
    final Color bubbleColor = isMe
        ? theme.outgoingBubbleColor
        : theme.incomingBubbleColor;
    final Alignment alignment = isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final BorderRadius radius = BorderRadius.only(
      topLeft: Radius.circular(theme.bubbleRadius),
      topRight: Radius.circular(theme.bubbleRadius),
      bottomLeft: Radius.circular(isMe ? theme.bubbleRadius : 2),
      bottomRight: Radius.circular(isMe ? 2 : theme.bubbleRadius),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
          child: InkWell(
            onLongPress:
                onLongPress ??
                () async {
                  await EnhancedReactionPicker.show(
                    context,
                    onEmojiSelected: (emoji) {
                      // TODO: Add reaction to message
                      // This would typically call controller.toggleReaction(messageId, emoji)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added $emoji reaction')),
                      );
                    },
                  );
                },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                  style: theme.messageTextStyle,
                  child: _buildInner(context),
                ),
                const SizedBox(height: 4),
                _ReactionsRow(message: message, isMe: isMe),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInner(BuildContext context) {
    switch (message.kind) {
      case MessageKind.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (message.replyTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '↩︎ Reply',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            if (message.attachments.isNotEmpty)
              _AttachmentsPreview(attachments: message.attachments),
            // Message text
            if (message.text != null && message.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MarkdownText(
                  text: message.text!,
                  styles: MarkdownTextStyles(),
                ),
              ),

            // Edit indicator
            if (message.editedAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'edited',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (controller.canEditMessage(message)) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showEditDialog(context),
                        child: Text(
                          'edit',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            // Add link previews below the text
            if (message.text != null && LinkPreviewUtils.hasUrls(message.text!))
              _LinkPreviews(text: message.text!),
          ],
        );
      case MessageKind.audio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachments.isNotEmpty)
              AudioMessageTile(audio: message.attachments.first),
          ],
        );
      case MessageKind.location:
        return LocationMessageTile(location: message.location!);
      default:
        return Text('[${message.kind.name}]');
    }
  }

  void _showEditDialog(BuildContext context) {
    MessageEditDialog.show(context, message: message, controller: controller);
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final bool? confirmed = await MessageDeleteDialog.show(
      context,
      message: message,
      controller: controller,
    );

    if (confirmed == true) {
      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message deleted')));
    }
  }
}

class _AttachmentsPreview extends StatelessWidget {
  final List<Attachment> attachments;
  const _AttachmentsPreview({required this.attachments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachments.map((attachment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _AttachmentCard(attachment: attachment),
        );
      }).toList(),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final Attachment attachment;

  const _AttachmentCard({required this.attachment});

  bool get _isAudio => attachment.mimeType.startsWith('audio/');
  bool get _isLocation => attachment.mimeType == 'application/geo';

  @override
  Widget build(BuildContext context) {
    if (_isAudio) {
      return AudioMessageTile(audio: attachment);
    }
    if (_isLocation) {
      // Parse location from geo URI
      try {
        final uri = Uri.parse(attachment.uri);
        if (uri.scheme == 'geo') {
          final coords = uri.path.split(',');
          if (coords.length == 2) {
            final lat = double.parse(coords[0]);
            final lon = double.parse(coords[1]);
            final location = LocationAttachment(
              latitude: lat,
              longitude: lon,
              timestamp: DateTime.now(),
            );
            return LocationMessageTile(location: location);
          }
        }
      } catch (e) {
        // Fall back to default attachment display
      }
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thumbnail
          ImageUtils.buildThumbnail(attachment, size: 50),
          const SizedBox(width: 12),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFileName(attachment.uri),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      ImageUtils.getFileIcon(attachment.mimeType),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attachment.mimeType.split('/').last.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (attachment.sizeBytes != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        ImageUtils.formatFileSize(attachment.sizeBytes),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Action button
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () {
              // TODO: Implement download/open functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${_getFileName(attachment.uri)}'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getFileName(String uri) {
    if (uri.startsWith('http')) {
      final uriObj = Uri.parse(uri);
      return uriObj.pathSegments.lastOrNull ?? 'File';
    } else if (uri.startsWith('file://')) {
      return uri.split('/').last;
    }
    return 'File';
  }
}

class _ReactionsRow extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _ReactionsRow({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (message.reactions.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: message.reactions.values.map((ReactionSummary r) {
              return Chip(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                label: Text('${r.key} ${r.by.length}'),
              );
            }).toList(),
          ),
        if (isMe) _ReadReceipt(message: message),
      ],
    );
  }
}

class _ReadReceipt extends StatelessWidget {
  final Message message;
  const _ReadReceipt({required this.message});

  @override
  Widget build(BuildContext context) {
    // Placeholder: in real implementation, this would check read status
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.done_all,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          TimeUtils.formatMessageTime(message.createdAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _LinkPreviews extends StatelessWidget {
  final String text;

  const _LinkPreviews({required this.text});

  @override
  Widget build(BuildContext context) {
    final urls = LinkPreviewUtils.extractUrls(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: urls.map((url) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: LinkPreviewUtils.buildLinkPreview(url),
        );
      }).toList(),
    );
  }
}
