import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../models/models.dart';

/// Service for picking files and images from device
class FilePickerService {
  static final FilePickerService _instance = FilePickerService._internal();
  factory FilePickerService() => _instance;
  FilePickerService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick a single image from camera or gallery
  Future<Attachment?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      final File file = File(pickedFile.path);
      final String? mimeType = lookupMimeType(pickedFile.path);

      return Attachment(
        uri: file.uri.toString(),
        mimeType: mimeType ?? 'image/jpeg',
        sizeBytes: await file.length(),
        thumbnailUri: file.uri
            .toString(), // For images, use the same URI as thumbnail
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<Attachment>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      final List<Attachment> attachments = [];
      for (final XFile pickedFile in pickedFiles) {
        final File file = File(pickedFile.path);
        final String? mimeType = lookupMimeType(pickedFile.path);

        attachments.add(
          Attachment(
            uri: file.uri.toString(),
            mimeType: mimeType ?? 'image/jpeg',
            sizeBytes: await file.length(),
            thumbnailUri: file.uri.toString(),
          ),
        );
      }

      return attachments;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Pick a video from camera or gallery
  Future<Attachment?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
    int? maxFileSize,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (pickedFile == null) return null;

      final File file = File(pickedFile.path);
      final String? mimeType = lookupMimeType(pickedFile.path);

      // Check file size if specified
      if (maxFileSize != null) {
        final int fileSize = await file.length();
        if (fileSize > maxFileSize) {
          throw Exception('Video file size exceeds limit');
        }
      }

      return Attachment(
        uri: file.uri.toString(),
        mimeType: mimeType ?? 'video/mp4',
        sizeBytes: await file.length(),
      );
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  /// Pick files using file picker
  Future<List<Attachment>> pickFiles({
    List<String>? allowedExtensions,
    bool allowMultiple = true,
    int? maxFileSize,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result == null) return [];

      final List<Attachment> attachments = [];
      for (final PlatformFile platformFile in result.files) {
        if (platformFile.path == null) continue;

        final File file = File(platformFile.path!);
        final String? mimeType = lookupMimeType(platformFile.path!);

        // Check file size if specified
        if (maxFileSize != null && platformFile.size > maxFileSize) {
          continue; // Skip files that are too large
        }

        attachments.add(
          Attachment(
            uri: file.uri.toString(),
            mimeType: mimeType ?? 'application/octet-stream',
            sizeBytes: platformFile.size,
          ),
        );
      }

      return attachments;
    } catch (e) {
      print('Error picking files: $e');
      return [];
    }
  }

  /// Pick documents (PDF, Word, Excel, etc.)
  Future<List<Attachment>> pickDocuments({
    List<String> allowedExtensions = const [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ],
    bool allowMultiple = true,
    int? maxFileSize,
  }) async {
    return pickFiles(
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      maxFileSize: maxFileSize,
    );
  }

  /// Pick audio files
  Future<List<Attachment>> pickAudio({
    List<String> allowedExtensions = const ['mp3', 'wav', 'aac', 'm4a', 'ogg'],
    bool allowMultiple = true,
    int? maxFileSize,
  }) async {
    return pickFiles(
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      maxFileSize: maxFileSize,
    );
  }

  /// Get file size in human-readable format
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file type is supported
  bool isSupportedFileType(String mimeType) {
    const List<String> supportedTypes = [
      'image/',
      'video/',
      'audio/',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/',
    ];

    return supportedTypes.any((type) => mimeType.startsWith(type));
  }
}
