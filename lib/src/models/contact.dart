import 'package:flutter/foundation.dart';

/// Represents a phone number with type and value
@immutable
class ContactPhoneNumber {
  /// Phone number value
  final String number;
  
  /// Phone number type (mobile, home, work, etc.)
  final String type;
  
  /// Whether this is the primary phone number
  final bool isPrimary;

  const ContactPhoneNumber({
    required this.number,
    this.type = 'mobile',
    this.isPrimary = false,
  });

  /// Create a copy with updated properties
  ContactPhoneNumber copyWith({
    String? number,
    String? type,
    bool? isPrimary,
  }) {
    return ContactPhoneNumber(
      number: number ?? this.number,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'type': type,
      'isPrimary': isPrimary,
    };
  }

  /// Create from JSON
  factory ContactPhoneNumber.fromJson(Map<String, dynamic> json) {
    return ContactPhoneNumber(
      number: json['number'] as String,
      type: json['type'] as String? ?? 'mobile',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactPhoneNumber &&
        other.number == number &&
        other.type == type &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(number, type, isPrimary);

  @override
  String toString() => 'ContactPhoneNumber(number: $number, type: $type, isPrimary: $isPrimary)';
}

/// Represents an email address with type and value
@immutable
class ContactEmail {
  /// Email address value
  final String email;
  
  /// Email type (personal, work, etc.)
  final String type;
  
  /// Whether this is the primary email
  final bool isPrimary;

  const ContactEmail({
    required this.email,
    this.type = 'personal',
    this.isPrimary = false,
  });

  /// Create a copy with updated properties
  ContactEmail copyWith({
    String? email,
    String? type,
    bool? isPrimary,
  }) {
    return ContactEmail(
      email: email ?? this.email,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'type': type,
      'isPrimary': isPrimary,
    };
  }

  /// Create from JSON
  factory ContactEmail.fromJson(Map<String, dynamic> json) {
    return ContactEmail(
      email: json['email'] as String,
      type: json['type'] as String? ?? 'personal',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactEmail &&
        other.email == email &&
        other.type == type &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(email, type, isPrimary);

  @override
  String toString() => 'ContactEmail(email: $email, type: $type, isPrimary: $isPrimary)';
}

/// Represents a contact address
@immutable
class ContactAddress {
  /// Street address
  final String? street;
  
  /// City
  final String? city;
  
  /// State or province
  final String? state;
  
  /// Postal code
  final String? postalCode;
  
  /// Country
  final String? country;
  
  /// Address type (home, work, etc.)
  final String type;
  
  /// Whether this is the primary address
  final bool isPrimary;

  const ContactAddress({
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.type = 'home',
    this.isPrimary = false,
  });

  /// Get formatted address string
  String get formattedAddress {
    final parts = <String>[];
    if (street?.isNotEmpty == true) parts.add(street!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    if (postalCode?.isNotEmpty == true) parts.add(postalCode!);
    if (country?.isNotEmpty == true) parts.add(country!);
    return parts.join(', ');
  }

  /// Create a copy with updated properties
  ContactAddress copyWith({
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? type,
    bool? isPrimary,
  }) {
    return ContactAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'type': type,
      'isPrimary': isPrimary,
    };
  }

  /// Create from JSON
  factory ContactAddress.fromJson(Map<String, dynamic> json) {
    return ContactAddress(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      type: json['type'] as String? ?? 'home',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactAddress &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.postalCode == postalCode &&
        other.country == country &&
        other.type == type &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(street, city, state, postalCode, country, type, isPrimary);

  @override
  String toString() => 'ContactAddress(formattedAddress: $formattedAddress, type: $type)';
}

/// Represents a complete contact with all information
@immutable
class Contact {
  /// Unique identifier for this contact
  final String id;
  
  /// Display name (full name)
  final String displayName;
  
  /// First name
  final String? firstName;
  
  /// Last name
  final String? lastName;
  
  /// Middle name
  final String? middleName;
  
  /// Company/organization
  final String? company;
  
  /// Job title
  final String? jobTitle;
  
  /// List of phone numbers
  final List<ContactPhoneNumber> phoneNumbers;
  
  /// List of email addresses
  final List<ContactEmail> emails;
  
  /// List of addresses
  final List<ContactAddress> addresses;
  
  /// Avatar/photo URL or base64 data
  final String? avatar;
  
  /// Birthday
  final DateTime? birthday;
  
  /// Notes about the contact
  final String? notes;
  
  /// Website URL
  final String? website;
  
  /// Social media handles
  final Map<String, String> socialMedia;
  
  /// When this contact was created
  final DateTime createdAt;
  
  /// When this contact was last updated
  final DateTime? updatedAt;
  
  /// Whether this contact is from device contacts
  final bool isFromDevice;
  
  /// Device contact ID if applicable
  final String? deviceContactId;

  const Contact({
    required this.id,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.middleName,
    this.company,
    this.jobTitle,
    this.phoneNumbers = const [],
    this.emails = const [],
    this.addresses = const [],
    this.avatar,
    this.birthday,
    this.notes,
    this.website,
    this.socialMedia = const {},
    required this.createdAt,
    this.updatedAt,
    this.isFromDevice = false,
    this.deviceContactId,
  });

  /// Get the primary phone number
  ContactPhoneNumber? get primaryPhoneNumber {
    if (phoneNumbers.isEmpty) return null;
    final primary = phoneNumbers.where((p) => p.isPrimary).firstOrNull;
    return primary ?? phoneNumbers.first;
  }

  /// Get the primary email
  ContactEmail? get primaryEmail {
    if (emails.isEmpty) return null;
    final primary = emails.where((e) => e.isPrimary).firstOrNull;
    return primary ?? emails.first;
  }

  /// Get the primary address
  ContactAddress? get primaryAddress {
    if (addresses.isEmpty) return null;
    final primary = addresses.where((a) => a.isPrimary).firstOrNull;
    return primary ?? addresses.first;
  }

  /// Get initials for avatar placeholder
  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '$first$last'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  /// Check if contact has any phone numbers
  bool get hasPhoneNumbers => phoneNumbers.isNotEmpty;

  /// Check if contact has any email addresses
  bool get hasEmails => emails.isNotEmpty;

  /// Check if contact has any addresses
  bool get hasAddresses => addresses.isNotEmpty;

  /// Create a copy with updated properties
  Contact copyWith({
    String? id,
    String? displayName,
    String? firstName,
    String? lastName,
    String? middleName,
    String? company,
    String? jobTitle,
    List<ContactPhoneNumber>? phoneNumbers,
    List<ContactEmail>? emails,
    List<ContactAddress>? addresses,
    String? avatar,
    DateTime? birthday,
    String? notes,
    String? website,
    Map<String, String>? socialMedia,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFromDevice,
    String? deviceContactId,
  }) {
    return Contact(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      emails: emails ?? this.emails,
      addresses: addresses ?? this.addresses,
      avatar: avatar ?? this.avatar,
      birthday: birthday ?? this.birthday,
      notes: notes ?? this.notes,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFromDevice: isFromDevice ?? this.isFromDevice,
      deviceContactId: deviceContactId ?? this.deviceContactId,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'company': company,
      'jobTitle': jobTitle,
      'phoneNumbers': phoneNumbers.map((p) => p.toJson()).toList(),
      'emails': emails.map((e) => e.toJson()).toList(),
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'avatar': avatar,
      'birthday': birthday?.toIso8601String(),
      'notes': notes,
      'website': website,
      'socialMedia': socialMedia,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFromDevice': isFromDevice,
      'deviceContactId': deviceContactId,
    };
  }

  /// Create from JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      middleName: json['middleName'] as String?,
      company: json['company'] as String?,
      jobTitle: json['jobTitle'] as String?,
      phoneNumbers: (json['phoneNumbers'] as List<dynamic>? ?? [])
          .map((p) => ContactPhoneNumber.fromJson(p as Map<String, dynamic>))
          .toList(),
      emails: (json['emails'] as List<dynamic>? ?? [])
          .map((e) => ContactEmail.fromJson(e as Map<String, dynamic>))
          .toList(),
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((a) => ContactAddress.fromJson(a as Map<String, dynamic>))
          .toList(),
      avatar: json['avatar'] as String?,
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday'] as String) : null,
      notes: json['notes'] as String?,
      website: json['website'] as String?,
      socialMedia: Map<String, String>.from(json['socialMedia'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      isFromDevice: json['isFromDevice'] as bool? ?? false,
      deviceContactId: json['deviceContactId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact &&
        other.id == id &&
        other.displayName == displayName &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.middleName == middleName &&
        other.company == company &&
        other.jobTitle == jobTitle &&
        listEquals(other.phoneNumbers, phoneNumbers) &&
        listEquals(other.emails, emails) &&
        listEquals(other.addresses, addresses) &&
        other.avatar == avatar &&
        other.birthday == birthday &&
        other.notes == notes &&
        other.website == website &&
        mapEquals(other.socialMedia, socialMedia) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isFromDevice == isFromDevice &&
        other.deviceContactId == deviceContactId;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      displayName,
      firstName,
      lastName,
      middleName,
      company,
      jobTitle,
      Object.hashAll(phoneNumbers),
      Object.hashAll(emails),
      Object.hashAll(addresses),
      avatar,
      birthday,
      notes,
      website,
      Object.hashAll(socialMedia.entries),
      createdAt,
      updatedAt,
      isFromDevice,
      deviceContactId,
    ]);
  }

  @override
  String toString() {
    return 'Contact(id: $id, displayName: $displayName, company: $company, phoneNumbers: ${phoneNumbers.length}, emails: ${emails.length})';
  }
}