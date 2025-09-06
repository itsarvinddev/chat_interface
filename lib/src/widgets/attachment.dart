import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatui/chatui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:screwdriver/screwdriver.dart';
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
    final file = message.attachment?.file;
    final type = message.attachment?.type;
    final url = message.attachment?.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: switch (type) {
          ChatAttachmentType.image =>
            url != null && url.isNotNullOrEmpty
                ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  )
                : file != null && file.path.isNotNullOrEmpty
                ? FutureBuilder(
                    future: Future.value(file.readAsBytes()),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return Image.memory(
                          Uint8List.fromList(snapshot.data!),
                          fit: BoxFit.cover,
                          width: width,
                          height: height,
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : const Text('No attachment'),
          ChatAttachmentType.document => ChatDocument(message: message),
          _ => const Text('No attachment'),
        },
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
    final config = ChatUiConfigProvider.of(context);
    final self = controller.currentUser;
    final clientIsSender = message.senderId == self.id;
    final file = message.attachment!.file;
    final attachment = message.attachment!;
    final ext = attachment.fileExtension;

    Widget? trailing;

    final backgroundColor = clientIsSender
        ? config.theme?.sentMessageBackgroundColor
        : config.theme?.receivedMessageBackgroundColor;

    String fileName = attachment.fileName;
    final len = fileName.length;
    if (fileName.length > 20) {
      fileName =
          "${fileName.substring(0, 15)}....${fileName.substring(len - 6, len)}";
    }

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
            (context.colorScheme.scrim),
            (backgroundColor ?? Colors.white),
            12,
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
                    "${strFormattedSize(attachment.fileSize)} · $ext",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
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
