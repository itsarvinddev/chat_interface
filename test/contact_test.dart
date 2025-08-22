import 'package:chatui/src/models/models.dart';
import 'package:chatui/src/services/contact_service.dart';
import 'package:chatui/src/utils/vcard_utils.dart';
import 'package:chatui/src/widgets/contact_message_tile.dart';
import 'package:chatui/src/widgets/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Contact Models Tests', () {
    test('ContactPhoneNumber creation and properties', () {
      const phone = ContactPhoneNumber(
        number: '+1234567890',
        type: 'mobile',
        isPrimary: true,
      );

      expect(phone.number, '+1234567890');
      expect(phone.type, 'mobile');
      expect(phone.isPrimary, true);
    });

    test('ContactPhoneNumber copyWith method', () {
      const original = ContactPhoneNumber(
        number: '+1234567890',
        type: 'mobile',
        isPrimary: false,
      );

      final updated = original.copyWith(type: 'work', isPrimary: true);

      expect(updated.number, '+1234567890');
      expect(updated.type, 'work');
      expect(updated.isPrimary, true);
    });

    test('ContactPhoneNumber JSON serialization', () {
      const phone = ContactPhoneNumber(
        number: '+1234567890',
        type: 'mobile',
        isPrimary: true,
      );

      final json = phone.toJson();
      expect(json['number'], '+1234567890');
      expect(json['type'], 'mobile');
      expect(json['isPrimary'], true);

      final restored = ContactPhoneNumber.fromJson(json);
      expect(restored, phone);
    });

    test('ContactEmail creation and properties', () {
      const email = ContactEmail(
        email: 'test@example.com',
        type: 'work',
        isPrimary: true,
      );

      expect(email.email, 'test@example.com');
      expect(email.type, 'work');
      expect(email.isPrimary, true);
    });

    test('ContactAddress creation and formatted address', () {
      const address = ContactAddress(
        street: '123 Main St',
        city: 'Anytown',
        state: 'CA',
        postalCode: '12345',
        country: 'USA',
        type: 'home',
      );

      expect(address.street, '123 Main St');
      expect(address.city, 'Anytown');
      expect(address.formattedAddress, '123 Main St, Anytown, CA, 12345, USA');
    });

    test('Contact creation and properties', () {
      final now = DateTime.now();
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        emails: [
          const ContactEmail(email: 'john@example.com', type: 'personal'),
        ],
        company: 'Acme Corp',
        createdAt: now,
      );

      expect(contact.id, 'test_1');
      expect(contact.displayName, 'John Doe');
      expect(contact.firstName, 'John');
      expect(contact.lastName, 'Doe');
      expect(contact.company, 'Acme Corp');
      expect(contact.hasPhoneNumbers, true);
      expect(contact.hasEmails, true);
      expect(contact.initials, 'JD');
    });

    test('Contact primary contact methods', () {
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1111111111', type: 'home'),
          const ContactPhoneNumber(
            number: '+2222222222',
            type: 'mobile',
            isPrimary: true,
          ),
        ],
        emails: [
          const ContactEmail(email: 'personal@example.com', type: 'personal'),
          const ContactEmail(
            email: 'work@example.com',
            type: 'work',
            isPrimary: true,
          ),
        ],
        createdAt: DateTime.now(),
      );

      expect(contact.primaryPhoneNumber?.number, '+2222222222');
      expect(contact.primaryEmail?.email, 'work@example.com');
    });

    test('Contact JSON serialization', () {
      final now = DateTime.now();
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        emails: [
          const ContactEmail(email: 'john@example.com', type: 'personal'),
        ],
        createdAt: now,
      );

      final json = contact.toJson();
      expect(json['id'], 'test_1');
      expect(json['displayName'], 'John Doe');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');

      final restored = Contact.fromJson(json);
      expect(restored.id, contact.id);
      expect(restored.displayName, contact.displayName);
      expect(restored.phoneNumbers.length, contact.phoneNumbers.length);
      expect(restored.emails.length, contact.emails.length);
    });
  });

  group('ContactAttachment Tests', () {
    test('ContactAttachment creation and conversion', () {
      final now = DateTime.now();
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        createdAt: now,
      );

      final contactAttachment = ContactAttachment(
        contact: contact,
        timestamp: now,
      );

      expect(contactAttachment.contact, contact);
      expect(contactAttachment.timestamp, now);

      final attachment = contactAttachment.toAttachment();
      expect(attachment.uri, 'contact:test_1');
      expect(attachment.mimeType, 'text/vcard');
    });
  });

  group('VCard Utils Tests', () {
    test('Contact to vCard conversion', () {
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        emails: [
          const ContactEmail(email: 'john@example.com', type: 'personal'),
        ],
        company: 'Acme Corp',
        createdAt: DateTime.now(),
      );

      final vCard = VCardUtils.contactToVCard(contact);

      expect(vCard.contains('BEGIN:VCARD'), true);
      expect(vCard.contains('FN:John Doe'), true);
      expect(vCard.contains('N:Doe;John'), true);
      expect(vCard.contains('ORG:Acme Corp'), true);
      expect(vCard.contains('TEL;TYPE=CELL:+1234567890'), true);
      expect(vCard.contains('EMAIL;TYPE=HOME:john@example.com'), true);
      expect(vCard.contains('END:VCARD'), true);
    });

    test('vCard to Contact conversion', () {
      const vCardData = '''BEGIN:VCARD
VERSION:3.0
FN:Jane Smith
N:Smith;Jane;;;
ORG:Tech Corp
TEL;TYPE=CELL:+0987654321
EMAIL;TYPE=WORK:jane@techcorp.com
END:VCARD''';

      final contact = VCardUtils.vCardToContact(vCardData);

      expect(contact, isNotNull);
      expect(contact!.displayName, 'Jane Smith');
      expect(contact.firstName, 'Jane');
      expect(contact.lastName, 'Smith');
      expect(contact.company, 'Tech Corp');
      expect(contact.phoneNumbers.length, 1);
      expect(contact.phoneNumbers.first.number, '+0987654321');
      expect(contact.emails.length, 1);
      expect(contact.emails.first.email, 'jane@techcorp.com');
    });

    test('vCard validation', () {
      const validVCard = '''BEGIN:VCARD
VERSION:3.0
FN:John Doe
END:VCARD''';

      const invalidVCard = 'This is not a vCard';

      expect(VCardUtils.isValidVCard(validVCard), true);
      expect(VCardUtils.isValidVCard(invalidVCard), false);
      expect(VCardUtils.isValidVCard(''), false);
    });

    test('Simple vCard generation', () {
      final vCard = VCardUtils.generateSimpleVCard(
        name: 'Test User',
        phone: '+1234567890',
        email: 'test@example.com',
        company: 'Test Corp',
      );

      expect(vCard.contains('FN:Test User'), true);
      expect(vCard.contains('TEL;TYPE=CELL:+1234567890'), true);
      expect(vCard.contains('EMAIL;TYPE=INTERNET:test@example.com'), true);
      expect(vCard.contains('ORG:Test Corp'), true);
    });
  });

  group('Contact Service Tests', () {
    test('Contact validation', () {
      // Valid contact with phone
      final validContact1 = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        createdAt: DateTime.now(),
      );

      // Valid contact with email
      final validContact2 = Contact(
        id: 'test_2',
        displayName: 'Jane Smith',
        emails: [
          const ContactEmail(email: 'jane@example.com', type: 'personal'),
        ],
        createdAt: DateTime.now(),
      );

      // Invalid contact - no name
      final invalidContact1 = Contact(
        id: 'test_3',
        displayName: '',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        createdAt: DateTime.now(),
      );

      // Invalid contact - no phone or email
      final invalidContact2 = Contact(
        id: 'test_4',
        displayName: 'Bob Wilson',
        createdAt: DateTime.now(),
      );

      expect(ContactService.isValidContact(validContact1), true);
      expect(ContactService.isValidContact(validContact2), true);
      expect(ContactService.isValidContact(invalidContact1), false);
      expect(ContactService.isValidContact(invalidContact2), false);
    });

    test('Contact search functionality', () {
      final contacts = [
        Contact(
          id: 'test_1',
          displayName: 'John Doe',
          company: 'Acme Corp',
          phoneNumbers: [
            const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
          ],
          createdAt: DateTime.now(),
        ),
        Contact(
          id: 'test_2',
          displayName: 'Jane Smith',
          company: 'Tech Solutions',
          emails: [const ContactEmail(email: 'jane@tech.com', type: 'work')],
          createdAt: DateTime.now(),
        ),
        Contact(
          id: 'test_3',
          displayName: 'Bob Wilson',
          phoneNumbers: [
            const ContactPhoneNumber(number: '+5555555555', type: 'home'),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      // Search by name
      final nameResults = ContactService.searchContacts(contacts, 'John');
      expect(nameResults.length, 1);
      expect(nameResults.first.displayName, 'John Doe');

      // Search by company
      final companyResults = ContactService.searchContacts(contacts, 'Tech');
      expect(companyResults.length, 1);
      expect(companyResults.first.displayName, 'Jane Smith');

      // Search by phone
      final phoneResults = ContactService.searchContacts(contacts, '5555');
      expect(phoneResults.length, 1);
      expect(phoneResults.first.displayName, 'Bob Wilson');

      // Search by email
      final emailResults = ContactService.searchContacts(contacts, 'jane@tech');
      expect(emailResults.length, 1);
      expect(emailResults.first.displayName, 'Jane Smith');

      // Empty search returns all
      final allResults = ContactService.searchContacts(contacts, '');
      expect(allResults.length, 3);
    });
  });

  group('Contact Widget Tests', () {
    testWidgets('ContactMessageTile displays contact correctly', (
      tester,
    ) async {
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        company: 'Acme Corp',
        jobTitle: 'Developer',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        emails: [const ContactEmail(email: 'john@acme.com', type: 'work')],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactMessageTile(
              contact: contact,
              isFromCurrentUser: false,
            ),
          ),
        ),
      );

      // Verify contact content is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Developer at Acme Corp'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('john@acme.com'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('ContactMessageTile handles actions', (tester) async {
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        createdAt: DateTime.now(),
      );

      String? calledNumber;
      String? messagedNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactMessageTile(
              contact: contact,
              isFromCurrentUser: false,
              onCall: (number) => calledNumber = number,
              onMessage: (number) => messagedNumber = number,
            ),
          ),
        ),
      );

      // Test call button
      await tester.tap(find.text('Call'));
      await tester.pump();
      expect(calledNumber, '+1234567890');

      // Test message button
      await tester.tap(find.text('Message'));
      await tester.pump();
      expect(messagedNumber, '+1234567890');
    });

    testWidgets('ContactPicker shows correctly', (tester) async {
      Contact? selectedContact;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactPicker(
              showDeviceContacts: true,
              allowManualEntry: true,
              allowVCardImport: true,
              onContactSelected: (contact) {
                selectedContact = contact;
              },
            ),
          ),
        ),
      );

      // Verify the main elements are present
      expect(find.text('Select Contact'), findsOneWidget);
      expect(find.byIcon(Icons.contacts), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('ContactPicker manual entry works', (tester) async {
      Contact? createdContact;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactPicker(
              showDeviceContacts: false,
              allowManualEntry: true,
              allowVCardImport: false,
              onContactSelected: (contact) {
                createdContact = contact;
              },
            ),
          ),
        ),
      );

      // Should show only the create tab
      expect(find.text('Create'), findsOneWidget);

      // Navigate to create tab and fill form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), '+1234567890');
      await tester.enterText(find.byType(TextField).at(2), 'test@example.com');

      // Tap create button
      await tester.tap(find.text('Create Contact'));
      await tester.pump();

      // Verify contact was created
      expect(createdContact, isNotNull);
      expect(createdContact!.displayName, 'Test User');
      expect(createdContact!.phoneNumbers.length, 1);
      expect(createdContact!.phoneNumbers.first.number, '+1234567890');
      expect(createdContact!.emails.length, 1);
      expect(createdContact!.emails.first.email, 'test@example.com');
    });
  });

  group('Contact Integration Tests', () {
    test('Message with contact attachment', () {
      final now = DateTime.now();
      final contact = Contact(
        id: 'test_1',
        displayName: 'John Doe',
        phoneNumbers: [
          const ContactPhoneNumber(number: '+1234567890', type: 'mobile'),
        ],
        createdAt: now,
      );

      final contactAttachment = ContactAttachment(
        contact: contact,
        timestamp: now,
      );

      final message = Message(
        id: MessageId('msg1'),
        author: ChatUser(id: ChatUserId('user1'), displayName: 'Sender'),
        kind: MessageKind.contact,
        contactAttachment: contactAttachment,
        createdAt: now,
      );

      expect(message.kind, MessageKind.contact);
      expect(message.contactAttachment, contactAttachment);
      expect(message.contactAttachment!.contact.displayName, 'John Doe');
    });
  });
}
