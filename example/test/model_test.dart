import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  initializeChatUI();

  test('ChatMessage maps with duration and enums', () {
    final msg = ChatMessage(
      id: '1',
      message: 'John Doe',
      type: ChatMessageType.chat,
      duration: const Duration(seconds: 5),
      createdAt: DateTime.now(),
    );

    final json = msg.toJson();
    debugPrint(json);
    expect(json.contains('"duration":5'), true);

    final decoded = ChatMessageMapper.fromJson(json);
    expect(decoded.duration, const Duration(seconds: 5));
    expect(decoded.type, ChatMessageType.chat);

    final attachment = ChatAttachment(
      fileName: 'test.png',
      type: ChatAttachmentType.image,
      file: XFile('test.png'),
    );

    final attachmentJson = attachment.toJson();
    debugPrint(attachmentJson);
    expect(attachmentJson.contains('"fileName":"test.png"'), true);
    expect(attachmentJson.contains('"type":"image"'), true);
    expect(attachmentJson.contains('"file":"test.png"'), true);

    final decodedAttachment = ChatAttachmentMapper.fromJson(attachmentJson);
    expect(decodedAttachment.fileName, 'test.png');
    expect(decodedAttachment.type, ChatAttachmentType.image);
    expect(decodedAttachment.file?.path, 'test.png');

    urlRegexTest();
  });
}

void urlRegexTest() {
  final RegExp urlRegex = RegExp(
    r'((https?:\/\/)?(www\.)?([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})(:[0-9]{1,5})?(\/[^\s]*)?)',
    caseSensitive: false,
  );

  final testStrings = [
    "Check this out: https://allreserve.in",
    "Visit www.google.com for search",
    "My site is arvind.dev",
    "This is not a link: hello.worldly",
    "http://localhost:3000/test",
    "random text without link",
  ];

  for (var text in testStrings) {
    final matches = urlRegex.allMatches(text);
    if (matches.isNotEmpty) {
      print("✅ Found URLs in: \"$text\"");
      for (var match in matches) {
        print("   → ${match.group(0)}");
      }
    } else {
      print("❌ No URL in: \"$text\"");
    }
  }
}
