import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class ImageUtils {
  /// Creates a thumbnail widget for different attachment types
  static Widget buildThumbnail(Attachment attachment, {double size = 60}) {
    if (attachment.thumbnailUri != null) {
      return _buildCachedThumbnail(attachment.thumbnailUri!, size);
    } else if (attachment.uri.startsWith('http')) {
      return _buildCachedThumbnail(attachment.uri, size);
    } else {
      return _buildPlaceholderThumbnail(attachment, size);
    }
  }

  /// Builds a cached network image thumbnail
  static Widget _buildCachedThumbnail(String imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.error, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Builds a placeholder thumbnail for local files
  static Widget _buildPlaceholderThumbnail(Attachment attachment, double size) {
    final bool isImage = attachment.mimeType.startsWith('image/');
    final bool isVideo = attachment.mimeType.startsWith('video/');

    IconData iconData;
    Color iconColor;

    if (isImage) {
      iconData = Icons.image;
      iconColor = Colors.blue;
    } else if (isVideo) {
      iconData = Icons.video_file;
      iconColor = Colors.red;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(iconData, size: size * 0.4, color: iconColor),
    );
  }

  /// Gets appropriate icon for file type
  static IconData getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document'))
      return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet'))
      return Icons.table_chart;
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation'))
      return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  /// Formats file size for display
  static String formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';

    const List<String> suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
