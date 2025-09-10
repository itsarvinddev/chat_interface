import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_interface/chat_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';

class ChatLinkPreview extends StatelessWidget {
  final ChatMessage message;
  final bool isMessageBySelf;
  const ChatLinkPreview({
    super.key,
    required this.message,
    required this.isMessageBySelf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMessageBySelf ? 0.0 : 10.0,
        top: 6.0,
        right: isMessageBySelf ? 4.0 : 0.0,
        bottom: 6.0,
      ),
      child: lookupMimeType(message.message.toLowerCase()) == 'image/jpeg'
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () {
                  final params = ShareParams(uri: Uri.parse(message.message));
                  SharePlus.instance.share(params);
                },
                child: CachedNetworkImage(
                  imageUrl: message.message.toLowerCase(),
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                  fit: BoxFit.cover,
                  width: context.mediaQuery.size.width * 0.8,
                  height: context.mediaQuery.size.height * 0.3,
                ),
              ),
            )
          : AnyLinkPreview(
              key: ValueKey(message.message),
              link:
                  message.message.startsWith("http") ||
                      message.message.startsWith("https")
                  ? message.message
                  : "https://${message.message}",
              displayDirection: UIDirection.uiDirectionHorizontal,
              bodyMaxLines: 5,
              bodyTextOverflow: TextOverflow.ellipsis,
              backgroundColor: context.theme.colorScheme.surfaceContainerHigh,
              borderRadius: 8,
              titleStyle: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              bodyStyle: context.theme.textTheme.labelSmall?.copyWith(
                color: context.theme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 10,
                ),
              ],
              placeholderWidget: const SizedBox.shrink(),
              errorWidget: const SizedBox.shrink(),
              errorTitle: 'Error',
              errorBody: 'No preview available',
            ),
    );
  }
}
