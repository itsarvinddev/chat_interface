import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

class LinkPreviewUtils {
  /// Detects URLs in text and returns them
  static List<String> extractUrls(String text) {
    final RegExp urlRegex = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// Checks if text contains URLs
  static bool hasUrls(String text) {
    return extractUrls(text).isNotEmpty;
  }

  /// Creates a link preview widget
  static Widget buildLinkPreview(String url) {
    return AnyLinkPreview(
      link: url,
      displayDirection: UIDirection.uiDirectionHorizontal,
      showMultimedia: true,
      bodyMaxLines: 3,
      bodyTextOverflow: TextOverflow.ellipsis,
      cache: const Duration(days: 1),
      backgroundColor: const Color(0xFFF5F5F5),
      borderRadius: 8,
      removeElevation: true,
      onTap: () {
        // Handle tap - could open in browser or show full preview
      },
    );
  }
}
