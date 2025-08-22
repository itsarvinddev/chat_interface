import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../theme/chat_theme.dart';
import '../utils/image_utils.dart';
import '../utils/link_preview_utils.dart';
import '../utils/markdown_parser.dart';
import '../utils/time_utils.dart';
import 'audio_message_tile.dart';
import 'contact_message_tile.dart';
import 'enhanced_reaction_picker.dart';
import 'location_message_tile.dart';
import 'message_edit_dialog.dart';
import 'poll_message_tile.dart';
import 'thread_message_tile.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onLongPress;
  final ChatController controller;
  final bool enableAnimations;
  final int? animationIndex;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
    required this.controller,
    this.enableAnimations = true,
    this.animationIndex,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  AnimationController? _slideController;
  AnimationController? _scaleController;
  AnimationController? _reactionController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Don't initialize animations here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_slideController == null) {
      _initializeAnimations();
      if (widget.enableAnimations) {
        _startEntryAnimation();
      }
    }
  }

  void _initializeAnimations() {
    _slideController ??= AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController ??= AnimationController(
      duration: ChatDesignTokens.fastAnimation,
      vsync: this,
    );

    _reactionController ??= AnimationController(
      duration: ChatDesignTokens.normalAnimation,
      vsync: this,
    );

    _slideAnimation ??=
        Tween<Offset>(
          begin: widget.isMe ? const Offset(0.3, 0) : const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController!,
            curve: ChatDesignTokens.defaultCurve,
          ),
        );

    _scaleAnimation ??= Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController!,
        curve: ChatDesignTokens.defaultCurve,
      ),
    );
  }

  void _startEntryAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _slideController != null && _scaleController != null) {
        Future.delayed(
          Duration(milliseconds: (widget.animationIndex ?? 0) * 50),
          () {
            if (mounted && _slideController != null && _scaleController != null) {
              _slideController!.forward();
              _scaleController!.forward();
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _slideController?.dispose();
    _scaleController?.dispose();
    _reactionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatThemeData theme = ChatTheme.of(context);
    final Color bubbleColor = widget.isMe
        ? theme.outgoingBubbleColor
        : theme.incomingBubbleColor;
    final Color textColor = widget.isMe
        ? theme.outgoingTextColor
        : theme.incomingTextColor;
    final Alignment alignment = widget.isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;

    // Enhanced border radius with more professional appearance
    final BorderRadius radius = BorderRadius.only(
      topLeft: Radius.circular(theme.bubbleRadius),
      topRight: Radius.circular(theme.bubbleRadius),
      bottomLeft: Radius.circular(
        widget.isMe ? theme.bubbleRadius : theme.bubbleRadius * 0.3,
      ),
      bottomRight: Radius.circular(
        widget.isMe ? theme.bubbleRadius * 0.3 : theme.bubbleRadius,
      ),
    );

    // Enhanced shadows for depth
    final List<BoxShadow> shadows =
        theme.enableBubbleShadows && theme.bubbleShadow != null
        ? [theme.bubbleShadow!]
        : [];

    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideController ?? const AlwaysStoppedAnimation(0.0),
        _scaleController ?? const AlwaysStoppedAnimation(0.0),
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation ?? AlwaysStoppedAnimation(Offset.zero),
          child: ScaleTransition(
            scale: _scaleAnimation ?? AlwaysStoppedAnimation(1.0),
            child: Transform.scale(
              scale: _isPressed && theme.enableScaleAnimations ? 0.98 : 1.0,
              child: Align(
                alignment: alignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                    minWidth: 60,
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: ChatDesignTokens.spaceLg,
                      vertical: ChatDesignTokens.spaceXs,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: radius,
                        onTapDown: (_) => _handleTapDown(),
                        onTapUp: (_) => _handleTapUp(),
                        onTapCancel: _handleTapUp,
                        onLongPress: widget.onLongPress ?? _handleLongPress,
                        child: AnimatedContainer(
                          duration: ChatDesignTokens.fastAnimation,
                          curve: ChatDesignTokens.defaultCurve,
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.bubblePadding.horizontal,
                            vertical: theme.bubblePadding.vertical,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: radius,
                            boxShadow: shadows,
                            border: theme.bubbleShadow != null
                                ? Border.all(
                                    color: theme.borderColor.withOpacity(0.1),
                                    width: 0.5,
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Author name for group chats
                              if (!widget.isMe)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: ChatDesignTokens.spaceXs,
                                  ),
                                  child: Text(
                                    widget.message.author.displayName,
                                    style: theme.authorTextStyle,
                                  ),
                                ),
                              // Message content
                              DefaultTextStyle(
                                style: theme.messageTextStyle.copyWith(
                                  color: textColor,
                                ),
                                child: _buildInner(context),
                              ),
                              // Reactions and timestamp
                              SizedBox(height: ChatDesignTokens.spaceXs),
                              _ReactionsRow(
                                message: widget.message,
                                isMe: widget.isMe,
                                theme: theme,
                                reactionController: _reactionController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown() {
    if (mounted) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp() {
    if (mounted) {
      setState(() => _isPressed = false);
    }
  }

  Future<void> _handleLongPress() async {
    _handleTapUp();

    // Haptic feedback for better UX
    HapticFeedback.mediumImpact();

    await EnhancedReactionPicker.show(
      context,
      onEmojiSelected: (emoji) {
        if (mounted && _reactionController != null) {
          _reactionController!.forward().then((_) {
            if (mounted && _reactionController != null) {
              _reactionController!.reverse();
            }
          });
        }

        // TODO: Add reaction to message through controller
        widget.controller.toggleReaction(widget.message, emoji);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $emoji reaction'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildInner(BuildContext context) {
    final theme = ChatTheme.of(context);

    switch (widget.message.kind) {
      case MessageKind.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Reply indicator with enhanced styling
            if (widget.message.replyTo != null)
              Container(
                margin: EdgeInsets.only(bottom: ChatDesignTokens.spaceSm),
                padding: EdgeInsets.all(ChatDesignTokens.spaceXs),
                decoration: BoxDecoration(
                  color: theme.surfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(
                    ChatDesignTokens.radiusXs,
                  ),
                  border: Border.all(
                    color: theme.borderColor.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reply, size: 16, color: theme.accentColor),
                    SizedBox(width: ChatDesignTokens.spaceXs),
                    Text(
                      'Reply',
                      style: theme.timestampTextStyle.copyWith(
                        color: theme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // Attachments with enhanced preview
            if (widget.message.attachments.isNotEmpty)
              _AttachmentsPreview(attachments: widget.message.attachments),
            // Message text with enhanced markdown
            if (widget.message.text != null && widget.message.text!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: ChatDesignTokens.spaceXs),
                child: MarkdownText(
                  text: widget.message.text!,
                  styles: theme.markdownStyles,
                ),
              ),

            // Enhanced edit indicator with better UX
            if (widget.message.editedAt != null)
              Container(
                margin: EdgeInsets.only(bottom: ChatDesignTokens.spaceXs),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 12,
                      color: theme.timestampColor,
                    ),
                    SizedBox(width: ChatDesignTokens.space2xs),
                    Text(
                      'edited',
                      style: theme.timestampTextStyle.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (widget.controller.canEditMessage(widget.message)) ...[
                      SizedBox(width: ChatDesignTokens.spaceXs),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          ChatDesignTokens.radiusXs,
                        ),
                        onTap: () => _showEditDialog(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ChatDesignTokens.spaceXs,
                            vertical: ChatDesignTokens.space2xs,
                          ),
                          child: Text(
                            'edit',
                            style: theme.timestampTextStyle.copyWith(
                              color: theme.accentColor,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            // Enhanced link previews
            if (widget.message.text != null &&
                LinkPreviewUtils.hasUrls(widget.message.text!))
              _LinkPreviews(text: widget.message.text!, theme: theme),
          ],
        );
      case MessageKind.audio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.attachments.isNotEmpty)
              AudioMessageTile(audio: widget.message.attachments.first),
          ],
        );
      case MessageKind.location:
        return LocationMessageTile(location: widget.message.location!);
      case MessageKind.poll:
        // Handle both PollAttachment and legacy PollSummary
        if (widget.message.pollAttachment != null) {
          return PollMessageTile(
            poll: widget.message.pollAttachment!.poll,
            currentUserId: widget.controller.currentUser.id.value,
            isFromCurrentUser: widget.isMe,
            onVote: (pollId, optionIds) {
              widget.controller.voteOnPoll(pollId, optionIds);
            },
            onViewResults: (poll) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Poll results coming soon!')),
              );
            },
          );
        } else if (widget.message.poll != null) {
          // Legacy support for PollSummary
          return Text('Legacy poll: ${widget.message.poll!.question}');
        }
        return const Text('[Poll]');
      case MessageKind.contact:
        if (widget.message.contactAttachment != null) {
          return ContactMessageTile(
            contact: widget.message.contactAttachment!.contact,
            isFromCurrentUser: widget.isMe,
            onCall: (phoneNumber) {
              // TODO: Implement call functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $phoneNumber...')),
              );
            },
            onMessage: (phoneNumber) {
              // TODO: Implement message functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Messaging $phoneNumber...')),
              );
            },
            onEmail: (email) {
              // TODO: Implement email functionality
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Emailing $email...')));
            },
            onSaveContact: (contact) {
              // TODO: Implement save contact functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saving ${contact.displayName}...')),
              );
            },
            onViewDetails: (contact) {
              // TODO: Show contact details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing ${contact.displayName} details'),
                ),
              );
            },
          );
        }
        return const Text('[Contact]');
      case MessageKind.thread:
        if (widget.message.threadAttachment != null) {
          return ThreadMessageTile(
            threadAttachment: widget.message.threadAttachment!,
            currentUserId: widget.controller.currentUser.id.value,
            isFromCurrentUser: widget.isMe,
            onViewThread: (thread) {
              widget.controller.openThread(thread);
            },
            onJoinThread: (thread) {
              widget.controller.joinThread(thread.id);
            },
            onReplyToThread: (thread) {
              widget.controller.openThread(thread);
            },
          );
        }
        return const Text('[Thread]');
      default:
        return Text('[${widget.message.kind.name}]');
    }
  }

  void _showEditDialog(BuildContext context) {
    MessageEditDialog.show(
      context,
      message: widget.message,
      controller: widget.controller,
    );
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
  final ChatThemeData theme;
  final AnimationController? reactionController;

  const _ReactionsRow({
    required this.message,
    required this.isMe,
    required this.theme,
    required this.reactionController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Reactions with enhanced styling and animations
        if (message.reactions.isNotEmpty)
          Flexible(
            child: Wrap(
              spacing: ChatDesignTokens.spaceXs,
              runSpacing: ChatDesignTokens.space2xs,
              children: message.reactions.values.map((ReactionSummary r) {
                return reactionController != null
                    ? AnimatedBuilder(
                        animation: reactionController!,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (reactionController!.value * 0.1),
                            child: _buildReactionContainer(r),
                          );
                        },
                      )
                    : _buildReactionContainer(r);
              }).toList(),
            ),
          ),
        // Read receipt and timestamp
        if (isMe) _ReadReceipt(message: message, theme: theme),
      ],
    );
  }

  Widget _buildReactionContainer(ReactionSummary r) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ChatDesignTokens.spaceXs,
        vertical: ChatDesignTokens.space2xs,
      ),
      decoration: BoxDecoration(
        color: theme.reactionBackgroundColor,
        borderRadius: BorderRadius.circular(
          ChatDesignTokens.radiusLg,
        ),
        border: Border.all(
          color: theme.borderColor.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow:
            theme.enableBubbleShadows &&
                theme.bubbleShadow != null
            ? [
                theme.bubbleShadow!.copyWith(
                  color: theme.bubbleShadow!.color
                      .withOpacity(0.1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(r.key, style: const TextStyle(fontSize: 14)),
          if (r.by.length > 1) ...[
            SizedBox(width: ChatDesignTokens.space2xs),
            Text(
              '${r.by.length}',
              style: theme.reactionTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadReceipt extends StatelessWidget {
  final Message message;
  final ChatThemeData theme;

  const _ReadReceipt({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ChatDesignTokens.space2xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.done_all, size: 14, color: theme.accentColor),
          SizedBox(width: ChatDesignTokens.space2xs),
          Text(
            TimeUtils.formatMessageTime(message.createdAt),
            style: theme.timestampTextStyle,
          ),
        ],
      ),
    );
  }
}

class _LinkPreviews extends StatelessWidget {
  final String text;
  final ChatThemeData theme;

  const _LinkPreviews({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    final urls = LinkPreviewUtils.extractUrls(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: urls.map((url) {
        return Container(
          margin: EdgeInsets.only(top: ChatDesignTokens.spaceSm),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ChatDesignTokens.radiusSm),
            child: LinkPreviewUtils.buildLinkPreview(url),
          ),
        );
      }).toList(),
    );
  }
}
