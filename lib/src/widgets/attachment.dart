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

class _ChatImageState extends State<ChatImage>
    with SingleTickerProviderStateMixin {
  // What is currently visible on screen (local bytes or last successful image).
  ImageProvider? _displayProvider;

  // Upcoming network image provider (preloaded before fade).
  ImageProvider? _networkProvider;
  bool _networkReady = false;
  bool _networkLoading = false;

  // Local bytes (optional).
  Uint8List? _localBytes;

  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  // Track changes to avoid stale updates.
  String? _lastUrl;
  String? _lastFilePath;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _initFromMessage(initial: true);
  }

  @override
  void didUpdateWidget(covariant ChatImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final url = widget.message.attachment?.url;
    final filePath = widget.message.attachment?.file?.path;

    // Only react if either url or file path changed.
    if (url != _lastUrl || filePath != _lastFilePath) {
      _initFromMessage(initial: false);
    }
  }

  Future<void> _initFromMessage({required bool initial}) async {
    final token = ++_loadToken;

    final file = widget.message.attachment?.file;
    final url = widget.message.attachment?.url.trim();
    final filePath = file?.path;

    _lastUrl = url;
    _lastFilePath = filePath;

    // 1) Load local bytes if available.
    if (filePath != null && filePath.isNotEmpty) {
      try {
        final bytes = await file!.readAsBytes();
        if (!mounted || token != _loadToken) return;

        _localBytes = bytes;
        // If nothing visible yet, show local immediately.
        if (_displayProvider == null) {
          setState(() {
            _displayProvider = MemoryImage(_localBytes!);
          });
        } else {
          // If something is already displayed (e.g., previous local),
          // update only if the provider changed meaningfully.
          final newLocal = MemoryImage(_localBytes!);
          if (_displayProvider is! MemoryImage) {
            setState(() {
              _displayProvider = newLocal;
            });
          }
        }
      } catch (_) {
        // Ignore local loading errors; we can still try the URL.
      }
    }

    // 2) Prepare and precache network image if URL present.
    if (url != null && url.isNotEmpty) {
      await _prepareNetwork(url, token);
    } else {
      // No URL; ensure we stop any pending fade-in.
      if (mounted) {
        setState(() {
          _networkProvider = null;
          _networkReady = false;
          _networkLoading = false;
          _fadeController.value = 0.0;
        });
      }
    }
  }

  Future<void> _prepareNetwork(String url, int token) async {
    // Build a cached network provider. Using the provider gives us full control.
    final provider = CachedNetworkImageProvider(url);

    if (!mounted || token != _loadToken) return;

    setState(() {
      _networkLoading = true;
      _networkReady = false;
      _networkProvider = provider;
      _fadeController.value = 0.0;
    });

    try {
      // Precache to ensure the image is decoded before we fade it in.
      await precacheImage(provider, context);
      if (!mounted || token != _loadToken) return;

      setState(() {
        _networkReady = true;
        _networkLoading = false;
      });

      // Start fade only after decode completes.
      _fadeController.forward(from: 0.0).whenComplete(() {
        if (!mounted || token != _loadToken) return;
        // Once fade completes, promote network to display and clear overlay.
        setState(() {
          _displayProvider = _networkProvider;
          _networkProvider = null;
          _networkReady = false;
          _fadeController.value = 0.0;
        });
      });
    } catch (_) {
      if (!mounted || token != _loadToken) return;
      // On error, keep showing whatever is already on screen (usually local).
      setState(() {
        _networkLoading = false;
        _networkReady = false;
        // Optionally, you could keep _networkProvider for retry logic.
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSomethingToShow = _displayProvider != null || _networkReady;

    // Compute cache target size to avoid decoding huge images unnecessarily.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (widget.width * dpr).round();
    final cacheHeight = (widget.height * dpr).round();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            if (_networkProvider != null && _networkReady && _lastUrl != null) {
              final params = ShareParams(uri: Uri.parse(_lastUrl!));
              SharePlus.instance.share(params);
            } else {
              final params = ShareParams(files: [XFile(_lastFilePath!)]);
              SharePlus.instance.share(params);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base layer: the currently displayed provider (local or last success).
              if (_displayProvider != null)
                Image(
                  image: _displayProvider!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  width: cacheWidth.toDouble(),
                  height: cacheHeight.toDouble(),
                ),

              // Overlay: the preloaded network image, faded in smoothly.
              if (_networkProvider != null && _networkReady)
                FadeTransition(
                  opacity: _fade,
                  child: Image(
                    image: _networkProvider!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    width: cacheWidth.toDouble(),
                    height: cacheHeight.toDouble(),
                  ),
                ),

              // If nothing to show yet (neither local nor ready network), show a centered loader.
              if (!hasSomethingToShow)
                const Center(child: CircularProgressIndicator()),

              // Optional subtle progress indicator in corner while downloading, but keep image visible.
              if (_networkLoading && _displayProvider != null)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colorScheme.onPrimary,
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
          final params = ShareParams(uri: Uri.parse(attachment.url));
          SharePlus.instance.share(params);
          return;
        } else {
          final params = ShareParams(files: [XFile(file.path)]);
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
                  Text(fileName, style: const TextStyle(fontSize: 14)),
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
