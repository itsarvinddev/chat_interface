import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/contact_service.dart';
import '../theme/chat_theme.dart';

/// A widget that displays a shared contact in a chat message
class ContactMessageTile extends StatelessWidget {
  /// The contact to display
  final Contact contact;

  /// Whether this contact is from the current user
  final bool isFromCurrentUser;

  /// Called when user wants to call the contact
  final void Function(String phoneNumber)? onCall;

  /// Called when user wants to message the contact
  final void Function(String phoneNumber)? onMessage;

  /// Called when user wants to email the contact
  final void Function(String email)? onEmail;

  /// Called when user wants to save the contact
  final void Function(Contact contact)? onSaveContact;

  /// Called when user wants to view contact details
  final void Function(Contact contact)? onViewDetails;

  /// Theme configuration
  final ChatThemeData? theme;

  const ContactMessageTile({
    super.key,
    required this.contact,
    this.isFromCurrentUser = false,
    this.onCall,
    this.onMessage,
    this.onEmail,
    this.onSaveContact,
    this.onViewDetails,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? ChatThemeData.fromTheme(Theme.of(context));

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFromCurrentUser
            ? themeData.outgoingBubbleColor
            : themeData.incomingBubbleColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContactHeader(),
          const SizedBox(height: 12),
          _buildContactInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildContactHeader() {
    return Row(
      children: [
        // Avatar
        _buildAvatar(),
        const SizedBox(width: 12),

        // Name and company
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                contact.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Company and title
              if (contact.company?.isNotEmpty == true ||
                  contact.jobTitle?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _getCompanyAndTitle(),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),

        // Contact type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 12, color: Colors.blue[700]),
              const SizedBox(width: 2),
              Text(
                'Contact',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: contact.avatar?.isNotEmpty == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                contact.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitialsAvatar(),
              ),
            )
          : _buildInitialsAvatar(),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        contact.initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getCompanyAndTitle() {
    final parts = <String>[];
    if (contact.jobTitle?.isNotEmpty == true) {
      parts.add(contact.jobTitle!);
    }
    if (contact.company?.isNotEmpty == true) {
      parts.add(contact.company!);
    }
    return parts.join(' at ');
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone numbers
        if (contact.hasPhoneNumbers) ...[
          for (final phone in contact.phoneNumbers.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildInfoRow(
                icon: _getPhoneIcon(phone.type),
                text: phone.number,
                subtitle: phone.type.toUpperCase(),
                onTap: () => _showPhoneActions(phone),
              ),
            ),
        ],

        // Email addresses
        if (contact.hasEmails) ...[
          for (final email in contact.emails.take(1))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildInfoRow(
                icon: Icons.email_outlined,
                text: email.email,
                subtitle: email.type.toUpperCase(),
                onTap: () => onEmail?.call(email.email),
              ),
            ),
        ],

        // Show more info indicator
        if (_hasMoreInfo()) ...[
          const SizedBox(height: 4),
          Text(
            _getMoreInfoText(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  IconData _getPhoneIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mobile':
      case 'cell':
        return Icons.smartphone;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.business;
      case 'fax':
        return Icons.fax;
      default:
        return Icons.phone;
    }
  }

  bool _hasMoreInfo() {
    return contact.phoneNumbers.length > 2 ||
        contact.emails.length > 1 ||
        contact.hasAddresses ||
        contact.website?.isNotEmpty == true;
  }

  String _getMoreInfoText() {
    final items = <String>[];

    if (contact.phoneNumbers.length > 2) {
      items.add(
        '${contact.phoneNumbers.length - 2} more phone${contact.phoneNumbers.length > 3 ? 's' : ''}',
      );
    }

    if (contact.emails.length > 1) {
      items.add(
        '${contact.emails.length - 1} more email${contact.emails.length > 2 ? 's' : ''}',
      );
    }

    if (contact.hasAddresses) {
      items.add(
        '${contact.addresses.length} address${contact.addresses.length > 1 ? 'es' : ''}',
      );
    }

    if (contact.website?.isNotEmpty == true) {
      items.add('website');
    }

    return items.join(', ');
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Call button (if has phone)
        if (contact.hasPhoneNumbers) ...[
          Expanded(
            child: _buildActionButton(
              icon: Icons.phone,
              label: 'Call',
              onPressed: () => _callPrimaryPhone(),
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Message button (if has phone)
        if (contact.hasPhoneNumbers) ...[
          Expanded(
            child: _buildActionButton(
              icon: Icons.message,
              label: 'Message',
              onPressed: () => _messagePrimaryPhone(),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // More actions button
        Expanded(
          child: _buildActionButton(
            icon: Icons.more_horiz,
            label: 'More',
            onPressed: () => _showMoreActions(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: isPrimary ? Colors.blue[700] : Colors.grey[600],
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isPrimary ? Colors.blue[700] : Colors.grey[600],
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        side: BorderSide(
          color: isPrimary
              ? Colors.blue.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _callPrimaryPhone() {
    final phone = contact.primaryPhoneNumber;
    if (phone != null) {
      onCall?.call(phone.number);
    }
  }

  void _messagePrimaryPhone() {
    final phone = contact.primaryPhoneNumber;
    if (phone != null) {
      onMessage?.call(phone.number);
    }
  }

  void _showPhoneActions(ContactPhoneNumber phone) {
    onCall?.call(phone.number);
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildMoreActionsSheet(context),
    );
  }

  Widget _buildMoreActionsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contact.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          if (onSaveContact != null)
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Save to Contacts'),
              onTap: () {
                Navigator.pop(context);
                onSaveContact!(contact);
              },
            ),

          if (onViewDetails != null)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                onViewDetails!(contact);
              },
            ),

          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share vCard'),
            onTap: () async {
              Navigator.pop(context);
              final success = await ContactService.shareContact(contact);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to share contact')),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Contact Info'),
            onTap: () async {
              Navigator.pop(context);
              await ContactService.copyContactToClipboard(contact);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact info copied to clipboard'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
