import '../models/models.dart';

/// Utility class for parsing and generating vCard format
class VCardUtils {
  /// Convert a Contact to vCard format (version 3.0)
  static String contactToVCard(Contact contact) {
    final buffer = StringBuffer();
    
    // Start vCard
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    
    // Full name
    buffer.writeln('FN:${_escapeVCardValue(contact.displayName)}');
    
    // Structured name (Last;First;Middle;Prefix;Suffix)
    if (contact.firstName != null || contact.lastName != null) {
      final lastName = contact.lastName ?? '';
      final firstName = contact.firstName ?? '';
      final middleName = contact.middleName ?? '';
      buffer.writeln('N:${_escapeVCardValue(lastName)};${_escapeVCardValue(firstName)};${_escapeVCardValue(middleName)};;');
    }
    
    // Organization
    if (contact.company?.isNotEmpty == true) {
      buffer.writeln('ORG:${_escapeVCardValue(contact.company!)}');
    }
    
    // Title
    if (contact.jobTitle?.isNotEmpty == true) {
      buffer.writeln('TITLE:${_escapeVCardValue(contact.jobTitle!)}');
    }
    
    // Phone numbers
    for (final phone in contact.phoneNumbers) {
      final type = _getPhoneType(phone.type);
      buffer.writeln('TEL;TYPE=$type:${_escapeVCardValue(phone.number)}');
    }
    
    // Email addresses
    for (final email in contact.emails) {
      final type = _getEmailType(email.type);
      buffer.writeln('EMAIL;TYPE=$type:${_escapeVCardValue(email.email)}');
    }
    
    // Addresses
    for (final address in contact.addresses) {
      final type = _getAddressType(address.type);
      final street = address.street ?? '';
      final city = address.city ?? '';
      final state = address.state ?? '';
      final postal = address.postalCode ?? '';
      final country = address.country ?? '';
      buffer.writeln('ADR;TYPE=$type:;;${_escapeVCardValue(street)};${_escapeVCardValue(city)};${_escapeVCardValue(state)};${_escapeVCardValue(postal)};${_escapeVCardValue(country)}');
    }
    
    // Website
    if (contact.website?.isNotEmpty == true) {
      buffer.writeln('URL:${_escapeVCardValue(contact.website!)}');
    }
    
    // Birthday
    if (contact.birthday != null) {
      final birthday = contact.birthday!;
      final dateStr = '${birthday.year.toString().padLeft(4, '0')}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}';
      buffer.writeln('BDAY:$dateStr');
    }
    
    // Notes
    if (contact.notes?.isNotEmpty == true) {
      buffer.writeln('NOTE:${_escapeVCardValue(contact.notes!)}');
    }
    
    // Photo (if base64 encoded)
    if (contact.avatar?.isNotEmpty == true && _isBase64(contact.avatar!)) {
      buffer.writeln('PHOTO;ENCODING=b;TYPE=JPEG:${contact.avatar!}');
    }
    
    // End vCard
    buffer.writeln('END:VCARD');
    
    return buffer.toString();
  }
  
  /// Parse vCard format to Contact
  static Contact? vCardToContact(String vCardData) {
    try {
      final lines = vCardData.trim().split('\n');
      if (lines.isEmpty || !lines.first.trim().startsWith('BEGIN:VCARD')) {
        return null;
      }
      
      String? displayName;
      String? firstName;
      String? lastName;
      String? middleName;
      String? company;
      String? jobTitle;
      List<ContactPhoneNumber> phoneNumbers = [];
      List<ContactEmail> emails = [];
      List<ContactAddress> addresses = [];
      String? avatar;
      DateTime? birthday;
      String? notes;
      String? website;
      
      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;
        
        final colonIndex = line.indexOf(':');
        if (colonIndex == -1) continue;
        
        final property = line.substring(0, colonIndex);
        final value = _unescapeVCardValue(line.substring(colonIndex + 1));
        
        if (property.startsWith('FN')) {
          displayName = value;
        } else if (property.startsWith('N')) {
          final parts = value.split(';');
          if (parts.isNotEmpty) lastName = parts[0].isNotEmpty ? parts[0] : null;
          if (parts.length > 1) firstName = parts[1].isNotEmpty ? parts[1] : null;
          if (parts.length > 2) middleName = parts[2].isNotEmpty ? parts[2] : null;
        } else if (property.startsWith('ORG')) {
          company = value;
        } else if (property.startsWith('TITLE')) {
          jobTitle = value;
        } else if (property.startsWith('TEL')) {
          final type = _extractPhoneType(property);
          phoneNumbers.add(ContactPhoneNumber(number: value, type: type));
        } else if (property.startsWith('EMAIL')) {
          final type = _extractEmailType(property);
          emails.add(ContactEmail(email: value, type: type));
        } else if (property.startsWith('ADR')) {
          final type = _extractAddressType(property);
          final parts = value.split(';');
          addresses.add(ContactAddress(
            street: parts.length > 2 ? parts[2] : null,
            city: parts.length > 3 ? parts[3] : null,
            state: parts.length > 4 ? parts[4] : null,
            postalCode: parts.length > 5 ? parts[5] : null,
            country: parts.length > 6 ? parts[6] : null,
            type: type,
          ));
        } else if (property.startsWith('URL')) {
          website = value;
        } else if (property.startsWith('BDAY')) {
          birthday = _parseVCardDate(value);
        } else if (property.startsWith('NOTE')) {
          notes = value;
        } else if (property.startsWith('PHOTO')) {
          if (property.contains('ENCODING=b') || property.contains('ENCODING=BASE64')) {
            avatar = value;
          }
        }
      }
      
      if (displayName?.isEmpty != false) {
        // Try to construct display name from first/last name
        if (firstName?.isNotEmpty == true || lastName?.isNotEmpty == true) {
          displayName = [firstName, lastName].where((n) => n?.isNotEmpty == true).join(' ');
        } else {
          return null; // Invalid contact without name
        }
      }
      
      return Contact(
        id: 'vcard_${DateTime.now().millisecondsSinceEpoch}',
        displayName: displayName!,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        company: company,
        jobTitle: jobTitle,
        phoneNumbers: phoneNumbers,
        emails: emails,
        addresses: addresses,
        avatar: avatar,
        birthday: birthday,
        notes: notes,
        website: website,
        createdAt: DateTime.now(),
        isFromDevice: false,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Escape special characters for vCard format
  static String _escapeVCardValue(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;');
  }
  
  /// Unescape special characters from vCard format
  static String _unescapeVCardValue(String value) {
    return value
        .replaceAll('\\\\', '\\')
        .replaceAll('\\n', '\n')
        .replaceAll('\\r', '\r')
        .replaceAll('\\,', ',')
        .replaceAll('\\;', ';');
  }
  
  /// Convert phone type to vCard format
  static String _getPhoneType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return 'HOME,VOICE';
      case 'work':
        return 'WORK,VOICE';
      case 'mobile':
      case 'cell':
        return 'CELL';
      case 'fax':
        return 'FAX';
      default:
        return 'VOICE';
    }
  }
  
  /// Convert email type to vCard format
  static String _getEmailType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
      case 'personal':
        return 'HOME';
      case 'work':
        return 'WORK';
      default:
        return 'INTERNET';
    }
  }
  
  /// Convert address type to vCard format
  static String _getAddressType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return 'HOME';
      case 'work':
        return 'WORK';
      default:
        return 'HOME';
    }
  }
  
  /// Extract phone type from vCard property
  static String _extractPhoneType(String property) {
    if (property.contains('CELL')) return 'mobile';
    if (property.contains('HOME')) return 'home';
    if (property.contains('WORK')) return 'work';
    if (property.contains('FAX')) return 'fax';
    return 'mobile';
  }
  
  /// Extract email type from vCard property
  static String _extractEmailType(String property) {
    if (property.contains('HOME')) return 'personal';
    if (property.contains('WORK')) return 'work';
    return 'personal';
  }
  
  /// Extract address type from vCard property
  static String _extractAddressType(String property) {
    if (property.contains('HOME')) return 'home';
    if (property.contains('WORK')) return 'work';
    return 'home';
  }
  
  /// Parse vCard date format
  static DateTime? _parseVCardDate(String dateStr) {
    try {
      // Handle various date formats
      if (dateStr.contains('-')) {
        return DateTime.parse(dateStr);
      } else if (dateStr.length == 8) {
        // YYYYMMDD format
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = int.parse(dateStr.substring(6, 8));
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if string is base64 encoded
  static bool _isBase64(String str) {
    try {
      return RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(str) && str.length % 4 == 0;
    } catch (e) {
      return false;
    }
  }
  
  /// Generate a simple vCard for quick sharing
  static String generateSimpleVCard({
    required String name,
    String? phone,
    String? email,
    String? company,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:${_escapeVCardValue(name)}');
    
    if (phone?.isNotEmpty == true) {
      buffer.writeln('TEL;TYPE=CELL:${_escapeVCardValue(phone!)}');
    }
    
    if (email?.isNotEmpty == true) {
      buffer.writeln('EMAIL;TYPE=INTERNET:${_escapeVCardValue(email!)}');
    }
    
    if (company?.isNotEmpty == true) {
      buffer.writeln('ORG:${_escapeVCardValue(company!)}');
    }
    
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }
  
  /// Validate vCard format
  static bool isValidVCard(String vCardData) {
    if (vCardData.trim().isEmpty) return false;
    
    final lines = vCardData.trim().split('\n');
    return lines.isNotEmpty && 
           lines.first.trim().startsWith('BEGIN:VCARD') &&
           lines.any((line) => line.trim().startsWith('END:VCARD'));
  }
}