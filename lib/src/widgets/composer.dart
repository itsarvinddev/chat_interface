import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../theme/chat_theme.dart';
import '../utils/image_utils.dart';
import '../utils/markdown_parser.dart';
import 'attachment_picker.dart';
import 'contact_picker.dart';
import 'location_picker.dart';
import 'poll_creator.dart';

class Composer extends StatefulWidget {
  final ChatController controller;
  final bool enableAnimations;

  const Composer({
    super.key,
    required this.controller,
    this.enableAnimations = true,
  });

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> with TickerProviderStateMixin {
  late TextEditingController _textController;
  MarkdownTextEditingController? _markdownController;
  bool _showMarkdown = false;
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _showRecorder = false;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isTyping = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _markdownController = MarkdownTextEditingController(
      styles: const MarkdownTextStyles(),
    );

    _initializeAnimations();
    _setupFocusListeners();
    _setupTextControllers();
  }

  void _initializeAnimations() {
    if (!widget.enableAnimations) return;

    _slideController = AnimationController(
      duration: ChatDesignTokens.normalAnimation,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: ChatDesignTokens.fastAnimation,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: ChatDesignTokens.fastAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: ChatDesignTokens.smoothCurve,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: ChatDesignTokens.defaultCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: ChatDesignTokens.defaultCurve,
      ),
    );

    // Start entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enableAnimations) {
        _slideController.forward();
        _scaleController.forward();
        _fadeController.forward();
      }
    });
  }

  void _setupFocusListeners() {
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });

        if (widget.enableAnimations) {
          if (_hasFocus) {
            _scaleController.forward();
          } else {
            _scaleController.reverse();
          }
        }
      }
    });
  }

  void _setupTextControllers() {
    // Sync text between controllers
    _textController.addListener(() {
      if (_markdownController != null && !_showMarkdown) {
        _markdownController!.text = _textController.text;
      }

      // Handle typing animation
      final hasText = _textController.text.trim().isNotEmpty;
      if (_isTyping != hasText) {
        setState(() => _isTyping = hasText);
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

    if (widget.enableAnimations) {
      _slideController.dispose();
      _scaleController.dispose();
      _fadeController.dispose();
    }

    super.dispose();
  }

  void _toggleMarkdown() {
    HapticFeedback.selectionClick();

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
    HapticFeedback.lightImpact();
    setState(() => _showRecorder = !_showRecorder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    Widget content = Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        border: Border(
          top: BorderSide(color: theme.borderColor.withOpacity(0.2), width: 1),
        ),
        boxShadow: theme.enableBubbleShadows && theme.bubbleShadow != null
            ? [
                theme.bubbleShadow!.copyWith(
                  color: theme.bubbleShadow!.color.withOpacity(0.1),
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Reply indicator with enhanced styling
            _buildReplyIndicator(theme),

            // Audio recorder with animations
            _buildAudioRecorder(theme),

            // Main composer row
            _buildComposerRow(theme),

            // Draft attachments with animations
            _buildDraftAttachments(theme),

            // Quick replies button
            _buildQuickRepliesButton(theme),
          ],
        ),
      ),
    );

    if (!widget.enableAnimations) {
      return content;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideController,
        _scaleController,
        _fadeController,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(opacity: _fadeAnimation, child: content),
          ),
        );
      },
    );
  }

  Widget _buildComposerRow(ChatThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ChatDesignTokens.spaceXs,
        vertical: ChatDesignTokens.spaceXs,
      ),
      child: Row(
        children: <Widget>[
          // Action buttons row
          _buildActionButtons(theme),

          // Text input field
          Expanded(child: _buildTextField(theme)),

          // Send button
          _buildSendButton(theme),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ChatThemeData theme) {
    final List<Widget> buttons = [
      _buildActionButton(
        icon: Icons.attach_file,
        tooltip: 'Add Attachment',
        onPressed: () {
          HapticFeedback.lightImpact();
          AttachmentPicker.show(
            context,
            onAttachmentsSelected: (attachments) {
              for (final attachment in attachments) {
                widget.controller.addAttachment(attachment);
              }
            },
            maxAttachments: 10,
            maxFileSize: 50 * 1024 * 1024,
          );
        },
        theme: theme,
      ),
      _buildActionButton(
        icon: _showRecorder ? Icons.mic_off : Icons.mic,
        tooltip: _showRecorder ? 'Hide recorder' : 'Record audio',
        onPressed: _toggleRecorder,
        isActive: _showRecorder,
        theme: theme,
      ),
      _buildActionButton(
        icon: Icons.location_on,
        tooltip: 'Share Location',
        onPressed: () {
          HapticFeedback.lightImpact();
          LocationPicker.show(
            context,
            onLocationSelected: (location) {
              final attachment = location.toAttachment();
              widget.controller.addAttachment(attachment);
            },
          );
        },
        theme: theme,
      ),
      _buildActionButton(
        icon: Icons.poll,
        tooltip: 'Create Poll',
        onPressed: () async {
          HapticFeedback.lightImpact();
          final poll = await PollCreator.show(context: context);
          if (poll != null) {
            final pollAttachment = PollAttachment(
              poll: poll,
              timestamp: DateTime.now(),
            );
            final attachment = pollAttachment.toAttachment();
            widget.controller.addAttachment(attachment);
          }
        },
        theme: theme,
      ),
      _buildActionButton(
        icon: Icons.contacts,
        tooltip: 'Share Contact',
        onPressed: () async {
          HapticFeedback.lightImpact();
          final contact = await ContactPicker.show(context: context);
          if (contact != null) {
            final contactAttachment = ContactAttachment(
              contact: contact,
              timestamp: DateTime.now(),
            );
            final attachment = contactAttachment.toAttachment();
            widget.controller.addAttachment(attachment);
          }
        },
        theme: theme,
      ),
      _buildActionButton(
        icon: _showMarkdown ? Icons.code : Icons.code_off,
        tooltip: 'Toggle markdown',
        onPressed: _toggleMarkdown,
        isActive: _showMarkdown,
        theme: theme,
      ),
      if (_showMarkdown)
        _buildActionButton(
          icon: Icons.help_outline,
          tooltip: 'Markdown help: *bold* _italic_ `code` ~strike~ ```block```',
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Markdown: *bold* _italic_ `code` ~strike~ ```block```',
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          theme: theme,
        ),
    ];

    return Wrap(spacing: ChatDesignTokens.space2xs, children: buttons);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required ChatThemeData theme,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ChatDesignTokens.radiusSm),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: ChatDesignTokens.fastAnimation,
          curve: ChatDesignTokens.defaultCurve,
          padding: EdgeInsets.all(ChatDesignTokens.spaceXs),
          decoration: BoxDecoration(
            color: isActive
                ? theme.accentColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ChatDesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? theme.accentColor : theme.timestampColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ChatThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ChatDesignTokens.spaceXs),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
        border: Border.all(
          color: _hasFocus
              ? theme.accentColor.withOpacity(0.3)
              : theme.borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _showMarkdown ? _markdownController : _textController,
        focusNode: _focusNode,
        style: theme.messageTextStyle,
        maxLines: 4,
        minLines: 1,
        decoration: InputDecoration(
          hintText: 'Message...',
          hintStyle: theme.timestampTextStyle,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ChatDesignTokens.spaceMd,
            vertical: ChatDesignTokens.spaceSm,
          ),
          border: InputBorder.none,
          suffixIcon: _isTyping
              ? AnimatedOpacity(
                  opacity: 1.0,
                  duration: ChatDesignTokens.fastAnimation,
                  child: Icon(Icons.edit, size: 16, color: theme.accentColor),
                )
              : null,
        ),
        onChanged: _handleTyping,
        onTap: () {
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  Widget _buildSendButton(ChatThemeData theme) {
    final hasContent =
        _isTyping || widget.controller.draftAttachments.value.isNotEmpty;

    return AnimatedScale(
      scale: hasContent ? 1.0 : 0.8,
      duration: ChatDesignTokens.fastAnimation,
      curve: ChatDesignTokens.bounceCurve,
      child: Material(
        color: hasContent ? theme.accentColor : theme.timestampColor,
        borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(ChatDesignTokens.radiusLg),
          onTap: hasContent ? _sendMessage : null,
          child: Container(
            padding: EdgeInsets.all(ChatDesignTokens.spaceSm),
            child: Icon(
              Icons.send,
              size: 20,
              color: hasContent
                  ? theme.surfaceColor
                  : theme.surfaceColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage() async {
    HapticFeedback.lightImpact();

    final String text = _textController.text.trim();
    if (text.isEmpty && widget.controller.draftAttachments.value.isEmpty) {
      return;
    }

    if (text.isNotEmpty) {
      await widget.controller.sendText(text);
    }

    _textController.clear();
    if (_markdownController != null) {
      _markdownController!.clear();
    }
  }

  Widget _buildReplyIndicator(ChatThemeData theme) {
    // TODO: Implement reply indicator
    return const SizedBox.shrink();
  }

  Widget _buildAudioRecorder(ChatThemeData theme) {
    // TODO: Implement audio recorder
    return const SizedBox.shrink();
  }

  Widget _buildDraftAttachments(ChatThemeData theme) {
    // TODO: Implement draft attachments display
    return const SizedBox.shrink();
  }

  Widget _buildQuickRepliesButton(ChatThemeData theme) {
    // TODO: Implement quick replies
    return const SizedBox.shrink();
  }
}

class _DraftAttachmentCard extends StatefulWidget {
  final Attachment attachment;
  final VoidCallback onRemove;
  final ChatThemeData theme;
  final bool enableAnimations;

  const _DraftAttachmentCard({
    required this.attachment,
    required this.onRemove,
    required this.theme,
    required this.enableAnimations,
  });

  @override
  State<_DraftAttachmentCard> createState() => _DraftAttachmentCardState();
}

class _DraftAttachmentCardState extends State<_DraftAttachmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimations) {
      _controller = AnimationController(
        duration: ChatDesignTokens.fastAnimation,
        vsync: this,
      );
      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: ChatDesignTokens.bounceCurve,
        ),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ChatDesignTokens.radiusMd),
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: ChatDesignTokens.fastAnimation,
          curve: ChatDesignTokens.defaultCurve,
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: widget.theme.surfaceColor,
            borderRadius: BorderRadius.circular(ChatDesignTokens.radiusMd),
            border: Border.all(
              color: widget.theme.borderColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow:
                widget.theme.enableBubbleShadows &&
                    widget.theme.bubbleShadow != null
                ? [
                    widget.theme.bubbleShadow!.copyWith(
                      color: widget.theme.bubbleShadow!.color.withOpacity(0.1),
                    ),
                  ]
                : null,
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.95))
              : Matrix4.identity(),
          child: Stack(
            children: [
              // Thumbnail
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    ChatDesignTokens.radiusMd,
                  ),
                  child: ImageUtils.buildThumbnail(widget.attachment, size: 80),
                ),
              ),
              // Remove button
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      ChatDesignTokens.radiusSm,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onRemove();
                    },
                    child: Container(
                      padding: EdgeInsets.all(ChatDesignTokens.space2xs),
                      decoration: BoxDecoration(
                        color: widget.theme.errorColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: widget.theme.surfaceColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!widget.enableAnimations) {
      return content;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: content);
      },
    );
  }
}
