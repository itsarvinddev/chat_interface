import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatui/chatui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:share_plus/share_plus.dart';

class AttachmentPreview extends StatelessWidget {
  final ChatMessage message;
  final double width;
  final double height;
  const AttachmentPreview({
    super.key,
    required this.message,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final type = message.attachment?.type;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: switch (type) {
          ChatAttachmentType.image => ChatImage(
            message: message,
            width: width,
            height: height,
          ),
          ChatAttachmentType.document => ChatDocument(message: message),
          _ => const Text('No attachment'),
        },
      ),
    );
  }
}

class ChatImage extends StatefulWidget {
  final ChatMessage message;
  final double width;
  final double height;

  const ChatImage({
    super.key,
    required this.message,
    required this.width,
    required this.height,
  });

  @override
  State<ChatImage> createState() => _ChatImageState();
}

class _ChatImageState extends State<ChatImage> {
  Uint8List? _fileBytes;
  String? _currentUrl;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ChatImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.attachment?.url != oldWidget.message.attachment?.url ||
        widget.message.attachment?.file?.path !=
            oldWidget.message.attachment?.file?.path) {
      _load();
    }
  }

  Future<void> _load() async {
    final token = ++_token;
    final file = widget.message.attachment?.file;
    final url = widget.message.attachment?.url.trim();

    // Reset state before loading.
    _fileBytes = null;
    _currentUrl = null;

    if (file != null && file.path.isNotEmpty) {
      try {
        final bytes = await file.readAsBytes();
        if (!mounted || token != _token) return;
        setState(() {
          _fileBytes = bytes;
        });
      } catch (_) {
        // If file loading failed, we won't set fileBytes. Fallback below.
      }
    }

    if ((file == null || file.path.isEmpty) && url != null && url.isNotEmpty) {
      if (!mounted || token != _token) return;
      setState(() {
        _currentUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (widget.width * dpr).round();
    final cacheHeight = (widget.height * dpr).round();

    if (_fileBytes != null) {
      return GestureDetector(
        onTap: () {
          final params = ShareParams(
            files: [XFile.fromData(_fileBytes!)],
            subject: widget.message.attachment?.fileName,
          );
          SharePlus.instance.share(params);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            _fileBytes!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
          ),
        ),
      );
    }

    if (_currentUrl != null) {
      return GestureDetector(
        onTap: () {
          final params = ShareParams(
            uri: Uri.parse(_currentUrl!),
            subject: widget.message.attachment?.fileName,
          );
          SharePlus.instance.share(params);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: _currentUrl!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            memCacheWidth: cacheWidth,
            memCacheHeight: cacheHeight,
            placeholder: (ctx, url) =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (ctx, url, error) =>
                const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    }

    // Nothing available
    return const Text("No attachment");
  }
}

class ChatDocument extends StatelessWidget {
  final ChatMessage message;
  const ChatDocument({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final controller = ChatControllerProvider.of(context);
    final chatTheme = ChatThemeProvider.of(context);
    final self = controller.currentUser;
    final clientIsSender = message.senderId == self.id;
    final file = message.attachment!.file;
    final attachment = message.attachment!;
    final ext = attachment.fileExtension;

    Widget? trailing;

    final backgroundColor = clientIsSender
        ? chatTheme.sentMessageBackgroundColor
        : chatTheme.receivedMessageBackgroundColor;

    String fileName = attachment.fileName;
    final len = fileName.length;
    if (fileName.length > 20) {
      fileName =
          "${fileName.substring(0, 15)}....${fileName.substring(len - 6, len)}";
    }

    final textPadding = '\u00A0' * 16;
    return GestureDetector(
      onTap: () async {
        if (file == null) {
          final params = ShareParams(
            uri: Uri.parse(attachment.url),
            subject: attachment.fileName,
          );
          SharePlus.instance.share(params);
          return;
        } else {
          final params = ShareParams(
            files: [XFile(file.path)],
            subject: attachment.fileName,
            uri: Uri.tryParse(attachment.url),
          );
          SharePlus.instance.share(params);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: ElevationOverlay.applySurfaceTint(
            backgroundColor.withValues(alpha: 0.5),
            context.colorScheme.primary,
            20,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 40,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(blurRadius: 1, color: Color.fromARGB(80, 0, 0, 0)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Center(
                child: Text(
                  ext.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 14,
                      color: clientIsSender
                          ? chatTheme.sentMessageTextStyle.color ??
                                chatTheme.sentMessageTextColor
                          : chatTheme.receivedMessageTextStyle.color ??
                                chatTheme.receivedMessageTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${strFormattedSize(attachment.fileSize)} · $ext $textPadding",
                    style: TextStyle(
                      fontSize: 12,
                      color: chatTheme.timestampColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (message.message.length > 10) ...[const Spacer()],
            trailing ?? const Text(''),
          ],
        ),
      ),
    );
  }
}
