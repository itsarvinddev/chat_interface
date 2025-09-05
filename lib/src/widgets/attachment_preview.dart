import 'package:chatui/chatui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
        ),

        child: switch (message.attachment?.type) {
          ChatAttachmentType.image =>
            file != null
                ? FutureBuilder(
                    future: Future.value(file.readAsBytes()),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return Image.memory(Uint8List.fromList(snapshot.data!));
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : const Text('No image'),
          _ => const Text('No attachment'),
        },
      ),
    );
  }
}
