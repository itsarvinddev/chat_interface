import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../models/enums.dart';
import '../models/message.dart';

/// Utility class for handling file and image picking operations
class FilePickerUtils {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Picks an image from the camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
      return null;
    }
  }

  /// Picks an image from the gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
      return null;
    }
  }

  /// Picks multiple images from the gallery
  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return images;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking multiple images: $e');
      }
      return [];
    }
  }

  /// Picks a file using file picker
  static Future<FilePickerResult?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: kIsWeb, // Only read data on web for security
        withReadStream: !kIsWeb,
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
      return null;
    }
  }

  /// Picks multiple files using file picker
  static Future<FilePickerResult?> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking multiple files: $e');
      }
      return null;
    }
  }

  /// Determines the ChatAttachmentType based on file extension or MIME type
  static ChatAttachmentType getAttachmentType(
    String fileName, [
    String? mimeType,
  ]) {
    final extension = path.extension(fileName).toLowerCase();
    final detectedMimeType = mimeType ?? lookupMimeType(fileName);

    // Image types
    if ([
          '.jpg',
          '.jpeg',
          '.png',
          '.gif',
          '.bmp',
          '.webp',
        ].contains(extension) ||
        (detectedMimeType?.startsWith('image/') ?? false)) {
      return ChatAttachmentType.image;
    }

    // Document types (default to document for anything else)
    return ChatAttachmentType.document;
  }

  /// Creates a ChatAttachment from an XFile (image from image_picker)
  static Future<ChatAttachment> createAttachmentFromXFile(XFile file) async {
    final fileName = path.basename(file.path);
    final extension = path.extension(fileName);
    final fileSize = await file.length();
    final attachmentType = getAttachmentType(fileName, file.mimeType);

    return ChatAttachment(
      fileName: fileName,
      type: attachmentType,
      fileExtension: extension,
      fileSize: fileSize,
      file: file,
      url: '', // Will be set after upload
    );
  }

  /// Creates a ChatAttachment from a PlatformFile (from file_picker)
  static ChatAttachment createAttachmentFromPlatformFile(
    PlatformFile platformFile,
  ) {
    final attachmentType = getAttachmentType(
      platformFile.name,
      platformFile.extension,
    );

    // Create XFile from PlatformFile
    XFile? xFile;
    if (platformFile.path != null) {
      xFile = XFile(platformFile.path!);
    } else if (platformFile.bytes != null && kIsWeb) {
      // For web, create XFile from bytes
      xFile = XFile.fromData(
        platformFile.bytes!,
        name: platformFile.name,
        mimeType: lookupMimeType(platformFile.name),
      );
    }

    return ChatAttachment(
      fileName: platformFile.name,
      type: attachmentType,
      fileExtension:
          platformFile.extension ?? path.extension(platformFile.name),
      fileSize: platformFile.size,
      file: xFile,
      url: '', // Will be set after upload
    );
  }

  /// Gets file size in a human readable format
  static String getReadableFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Validates if file size is within acceptable limits
  static bool isFileSizeValid(int sizeInBytes, {int maxSizeInMB = 100}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return sizeInBytes <= maxSizeInBytes;
  }
}
