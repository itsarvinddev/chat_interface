import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../utils/vcard_utils.dart';

/// Service for managing contact operations including device integration and actions
class ContactService {
  static const _platform = MethodChannel('chatui/contacts');

  /// Load contacts from device (requires permission)
  static Future<List<Contact>> loadDeviceContacts() async {
    try {
      if (kDebugMode) {
        // Return demo contacts in debug mode
        return _getDemoContacts();
      }

      // In production, this would call native platform code
      final List<dynamic> contactsData = await _platform.invokeMethod(
        'getContacts',
      );

      return contactsData.map((data) {
        return Contact.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } on PlatformException catch (e) {
      print('Failed to load device contacts: ${e.message}');
      return [];
    } catch (e) {
      print('Error loading contacts: $e');
      return [];
    }
  }

  /// Request contacts permission
  static Future<bool> requestContactsPermission() async {
    try {
      if (kDebugMode) {
        // Always return true in debug mode
        return true;
      }

      final bool granted = await _platform.invokeMethod('requestPermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to request contacts permission: ${e.message}');
      return false;
    }
  }

  /// Check if contacts permission is granted
  static Future<bool> hasContactsPermission() async {
    try {
      if (kDebugMode) {
        // Always return true in debug mode
        return true;
      }

      final bool granted = await _platform.invokeMethod('hasPermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to check contacts permission: ${e.message}');
      return false;
    }
  }

  /// Save contact to device
  static Future<bool> saveContactToDevice(Contact contact) async {
    try {
      if (kDebugMode) {
        print('Demo: Saving contact ${contact.displayName} to device');
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      }

      final contactData = contact.toJson();
      final bool saved = await _platform.invokeMethod(
        'saveContact',
        contactData,
      );
      return saved;
    } on PlatformException catch (e) {
      print('Failed to save contact: ${e.message}');
      return false;
    }
  }

  /// Make a phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      if (kDebugMode) {
        print('Demo: Making call to $phoneNumber');
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }

      final bool success = await _platform.invokeMethod('makeCall', {
        'number': phoneNumber,
      });
      return success;
    } on PlatformException catch (e) {
      print('Failed to make phone call: ${e.message}');
      return false;
    }
  }

  /// Send SMS message
  static Future<bool> sendSMSMessage(
    String phoneNumber, {
    String? message,
  }) async {
    try {
      if (kDebugMode) {
        print(
          'Demo: Sending SMS to $phoneNumber with message: ${message ?? ""}',
        );
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }

      final bool success = await _platform.invokeMethod('sendSMS', {
        'number': phoneNumber,
        'message': message ?? '',
      });
      return success;
    } on PlatformException catch (e) {
      print('Failed to send SMS: ${e.message}');
      return false;
    }
  }

  /// Send email
  static Future<bool> sendEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      if (kDebugMode) {
        print('Demo: Sending email to $email with subject: ${subject ?? ""}');
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }

      final bool success = await _platform.invokeMethod('sendEmail', {
        'email': email,
        'subject': subject ?? '',
        'body': body ?? '',
      });
      return success;
    } on PlatformException catch (e) {
      print('Failed to send email: ${e.message}');
      return false;
    }
  }

  /// Share contact as vCard
  static Future<bool> shareContact(Contact contact) async {
    try {
      final vCard = VCardUtils.contactToVCard(contact);

      if (kDebugMode) {
        print('Demo: Sharing contact ${contact.displayName}');
        print('vCard data: $vCard');
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }

      final bool success = await _platform.invokeMethod('shareText', {
        'text': vCard,
        'subject': 'Contact: ${contact.displayName}',
      });
      return success;
    } on PlatformException catch (e) {
      print('Failed to share contact: ${e.message}');
      return false;
    }
  }

  /// Copy contact information to clipboard
  static Future<void> copyContactToClipboard(Contact contact) async {
    final buffer = StringBuffer();

    buffer.writeln(contact.displayName);

    if (contact.company?.isNotEmpty == true) {
      buffer.writeln(contact.company);
    }

    if (contact.jobTitle?.isNotEmpty == true) {
      buffer.writeln(contact.jobTitle);
    }

    for (final phone in contact.phoneNumbers) {
      buffer.writeln('${phone.type}: ${phone.number}');
    }

    for (final email in contact.emails) {
      buffer.writeln('${email.type}: ${email.email}');
    }

    for (final address in contact.addresses) {
      if (address.formattedAddress.isNotEmpty) {
        buffer.writeln('${address.type}: ${address.formattedAddress}');
      }
    }

    if (contact.website?.isNotEmpty == true) {
      buffer.writeln('Website: ${contact.website}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
  }

  /// Search contacts by query
  static List<Contact> searchContacts(List<Contact> contacts, String query) {
    if (query.isEmpty) return contacts;

    final lowercaseQuery = query.toLowerCase();

    return contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(lowercaseQuery) ||
          contact.firstName?.toLowerCase().contains(lowercaseQuery) == true ||
          contact.lastName?.toLowerCase().contains(lowercaseQuery) == true ||
          contact.company?.toLowerCase().contains(lowercaseQuery) == true ||
          contact.jobTitle?.toLowerCase().contains(lowercaseQuery) == true ||
          contact.phoneNumbers.any((p) => p.number.contains(query)) ||
          contact.emails.any(
            (e) => e.email.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  /// Validate contact data
  static bool isValidContact(Contact contact) {
    // Must have a display name
    if (contact.displayName.trim().isEmpty) return false;

    // Must have at least one phone number or email
    if (contact.phoneNumbers.isEmpty && contact.emails.isEmpty) return false;

    // Validate phone numbers
    for (final phone in contact.phoneNumbers) {
      if (phone.number.trim().isEmpty) return false;
    }

    // Validate emails
    for (final email in contact.emails) {
      if (!_isValidEmail(email.email)) return false;
    }

    return true;
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Get demo contacts for development
  static List<Contact> _getDemoContacts() {
    return [
      Contact(
        id: 'demo_1',
        displayName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumbers: [
          const ContactPhoneNumber(
            number: '+1 (555) 123-4567',
            type: 'mobile',
            isPrimary: true,
          ),
          const ContactPhoneNumber(number: '+1 (555) 765-4321', type: 'work'),
        ],
        emails: [
          const ContactEmail(
            email: 'john.doe@example.com',
            type: 'personal',
            isPrimary: true,
          ),
          const ContactEmail(email: 'j.doe@company.com', type: 'work'),
        ],
        addresses: [
          const ContactAddress(
            street: '123 Main St',
            city: 'Anytown',
            state: 'CA',
            postalCode: '12345',
            country: 'USA',
            type: 'home',
            isPrimary: true,
          ),
        ],
        company: 'Acme Corporation',
        jobTitle: 'Software Engineer',
        website: 'https://johndoe.dev',
        notes: 'Met at tech conference 2023',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isFromDevice: true,
        deviceContactId: 'device_1',
      ),
      Contact(
        id: 'demo_2',
        displayName: 'Jane Smith',
        firstName: 'Jane',
        lastName: 'Smith',
        phoneNumbers: [
          const ContactPhoneNumber(
            number: '+1 (555) 987-6543',
            type: 'mobile',
            isPrimary: true,
          ),
        ],
        emails: [
          const ContactEmail(
            email: 'jane.smith@techsolutions.com',
            type: 'work',
            isPrimary: true,
          ),
        ],
        company: 'Tech Solutions Inc',
        jobTitle: 'Product Manager',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isFromDevice: true,
        deviceContactId: 'device_2',
      ),
      Contact(
        id: 'demo_3',
        displayName: 'Bob Wilson',
        firstName: 'Bob',
        lastName: 'Wilson',
        phoneNumbers: [
          const ContactPhoneNumber(
            number: '+1 (555) 456-7890',
            type: 'home',
            isPrimary: true,
          ),
        ],
        emails: [
          const ContactEmail(
            email: 'bob.wilson@email.com',
            type: 'personal',
            isPrimary: true,
          ),
        ],
        notes: 'Neighbor, also Flutter developer',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isFromDevice: true,
        deviceContactId: 'device_3',
      ),
      Contact(
        id: 'demo_4',
        displayName: 'Alice Johnson',
        firstName: 'Alice',
        lastName: 'Johnson',
        phoneNumbers: [
          const ContactPhoneNumber(
            number: '+1 (555) 111-2222',
            type: 'mobile',
            isPrimary: true,
          ),
          const ContactPhoneNumber(number: '+1 (555) 333-4444', type: 'work'),
        ],
        emails: [
          const ContactEmail(
            email: 'alice@startup.io',
            type: 'work',
            isPrimary: true,
          ),
        ],
        company: 'Startup Inc',
        jobTitle: 'CEO',
        website: 'https://startup.io',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isFromDevice: true,
        deviceContactId: 'device_4',
      ),
    ];
  }
}
