import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/file_picker_service.dart';

class AttachmentPicker extends StatelessWidget {
  final Function(List<Attachment>) onAttachmentsSelected;
  final VoidCallback onClose;
  final int maxAttachments;
  final int maxFileSize; // in bytes

  const AttachmentPicker({
    super.key,
    required this.onAttachmentsSelected,
    required this.onClose,
    this.maxAttachments = 10,
    this.maxFileSize = 50 * 1024 * 1024, // 50MB default
  });

  /// Show the attachment picker as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(List<Attachment>) onAttachmentsSelected,
    int maxAttachments = 10,
    int maxFileSize = 50 * 1024 * 1024,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentPicker(
        onAttachmentsSelected: onAttachmentsSelected,
        onClose: () => Navigator.of(context).pop(),
        maxAttachments: maxAttachments,
        maxFileSize: maxFileSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  'Add Attachment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Attachment options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Camera option
                  _AttachmentOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: () => _handleCamera(context),
                  ),
                  
                  // Gallery option
                  _AttachmentOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: 'Choose from photos',
                    onTap: () => _handleGallery(context),
                  ),
                  
                  // Video option
                  _AttachmentOption(
                    icon: Icons.videocam,
                    title: 'Video',
                    subtitle: 'Record or choose video',
                    onTap: () => _handleVideo(context),
                  ),
                  
                  // Document option
                  _AttachmentOption(
                    icon: Icons.description,
                    title: 'Document',
                    subtitle: 'PDF, Word, Excel, etc.',
                    onTap: () => _handleDocuments(context),
                  ),
                  
                  // Audio option
                  _AttachmentOption(
                    icon: Icons.audiotrack,
                    title: 'Audio',
                    subtitle: 'Voice message or audio file',
                    onTap: () => _handleAudio(context),
                  ),
                  
                  // File option
                  _AttachmentOption(
                    icon: Icons.attach_file,
                    title: 'File',
                    subtitle: 'Any file type',
                    onTap: () => _handleFiles(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCamera(BuildContext context) async {
    final attachment = await FilePickerService().pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (attachment != null) {
      onAttachmentsSelected([attachment]);
      onClose();
    }
  }

  Future<void> _handleGallery(BuildContext context) async {
    final attachments = await FilePickerService().pickMultipleImages(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (attachments.isNotEmpty) {
      final limitedAttachments = attachments.take(maxAttachments).toList();
      onAttachmentsSelected(limitedAttachments);
      onClose();
    }
  }

  Future<void> _handleVideo(BuildContext context) async {
    final attachment = await FilePickerService().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
      maxFileSize: maxFileSize,
    );
    
    if (attachment != null) {
      onAttachmentsSelected([attachment]);
      onClose();
    }
  }

  Future<void> _handleDocuments(BuildContext context) async {
    final attachments = await FilePickerService().pickDocuments(
      maxFileSize: maxFileSize,
    );
    
    if (attachments.isNotEmpty) {
      final limitedAttachments = attachments.take(maxAttachments).toList();
      onAttachmentsSelected(limitedAttachments);
      onClose();
    }
  }

  Future<void> _handleAudio(BuildContext context) async {
    final attachments = await FilePickerService().pickAudio(
      maxFileSize: maxFileSize,
    );
    
    if (attachments.isNotEmpty) {
      final limitedAttachments = attachments.take(maxAttachments).toList();
      onAttachmentsSelected(limitedAttachments);
      onClose();
    }
  }

  Future<void> _handleFiles(BuildContext context) async {
    final attachments = await FilePickerService().pickFiles(
      maxFileSize: maxFileSize,
    );
    
    if (attachments.isNotEmpty) {
      final limitedAttachments = attachments.take(maxAttachments).toList();
      onAttachmentsSelected(limitedAttachments);
      onClose();
    }
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
