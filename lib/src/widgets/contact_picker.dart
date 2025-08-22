import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/contact_service.dart';
import '../utils/vcard_utils.dart';

/// A comprehensive widget for selecting or creating contacts
class ContactPicker extends StatefulWidget {
  /// Called when a contact is selected or created
  final void Function(Contact contact) onContactSelected;

  /// Whether to show device contacts (requires permissions)
  final bool showDeviceContacts;

  /// Whether to allow manual contact creation
  final bool allowManualEntry;

  /// Whether to allow vCard import
  final bool allowVCardImport;

  /// Initial search query
  final String? initialQuery;

  const ContactPicker({
    super.key,
    required this.onContactSelected,
    this.showDeviceContacts = true,
    this.allowManualEntry = true,
    this.allowVCardImport = true,
    this.initialQuery,
  });

  /// Show contact picker as a modal bottom sheet
  static Future<Contact?> show({
    required BuildContext context,
    bool showDeviceContacts = true,
    bool allowManualEntry = true,
    bool allowVCardImport = true,
    String? initialQuery,
  }) async {
    Contact? selectedContact;

    final result = await showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ContactPicker(
          showDeviceContacts: showDeviceContacts,
          allowManualEntry: allowManualEntry,
          allowVCardImport: allowVCardImport,
          initialQuery: initialQuery,
          onContactSelected: (contact) {
            selectedContact = contact;
            Navigator.of(context).pop(contact);
          },
        ),
      ),
    );

    return result ?? selectedContact;
  }

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _vCardController = TextEditingController();

  List<Contact> _deviceContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoadingContacts = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Setup tab controller based on enabled features
    final tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);

    if (widget.initialQuery?.isNotEmpty == true) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }

    if (widget.showDeviceContacts) {
      _loadDeviceContacts();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _vCardController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    int count = 0;
    if (widget.showDeviceContacts) count++;
    if (widget.allowManualEntry) count++;
    if (widget.allowVCardImport) count++;
    return count.clamp(1, 3);
  }

  List<Widget> _buildTabs() {
    final tabs = <Widget>[];

    if (widget.showDeviceContacts) {
      tabs.add(const Tab(icon: Icon(Icons.contacts), text: 'Contacts'));
    }

    if (widget.allowManualEntry) {
      tabs.add(const Tab(icon: Icon(Icons.person_add), text: 'Create'));
    }

    if (widget.allowVCardImport) {
      tabs.add(const Tab(icon: Icon(Icons.qr_code_scanner), text: 'Import'));
    }

    return tabs;
  }

  List<Widget> _buildTabViews() {
    final views = <Widget>[];

    if (widget.showDeviceContacts) {
      views.add(_buildContactsTab());
    }

    if (widget.allowManualEntry) {
      views.add(_buildCreateTab());
    }

    if (widget.allowVCardImport) {
      views.add(_buildImportTab());
    }

    return views;
  }

  Future<void> _loadDeviceContacts() async {
    setState(() => _isLoadingContacts = true);

    try {
      // Check permission first
      final hasPermission = await ContactService.hasContactsPermission();
      if (!hasPermission) {
        final granted = await ContactService.requestContactsPermission();
        if (!granted) {
          setState(() => _isLoadingContacts = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contacts permission denied')),
            );
          }
          return;
        }
      }

      // Load contacts from device via service
      final contacts = await ContactService.loadDeviceContacts();

      setState(() {
        _deviceContacts = contacts;
        _filterContacts();
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() => _isLoadingContacts = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load contacts: $e')));
      }
    }
  }

  void _filterContacts() {
    _filteredContacts = ContactService.searchContacts(
      _deviceContacts,
      _searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        bottom: TabBar(controller: _tabController, tabs: _buildTabs()),
      ),
      body: TabBarView(controller: _tabController, children: _buildTabViews()),
    );
  }

  Widget _buildContactsTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterContacts();
              });
            },
          ),
        ),

        // Contacts list
        Expanded(
          child: _isLoadingContacts
              ? const Center(child: CircularProgressIndicator())
              : _filteredContacts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return _buildContactTile(contact);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildContactTile(Contact contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: contact.avatar?.isNotEmpty == true
            ? ClipOval(
                child: Image.network(
                  contact.avatar!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Text(contact.initials),
                ),
              )
            : Text(
                contact.initials,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      title: Text(contact.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.company?.isNotEmpty == true) Text(contact.company!),
          if (contact.hasPhoneNumbers) Text(contact.primaryPhoneNumber!.number),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => widget.onContactSelected(contact),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No contacts found'
                : 'No contacts available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Grant contacts permission to see your contacts',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Contact',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter contact name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter email address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _companyController,
            decoration: const InputDecoration(
              labelText: 'Company',
              hintText: 'Enter company name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createContact,
              icon: const Icon(Icons.person_add),
              label: const Text('Create Contact'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import from vCard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste vCard data or scan QR code containing contact information',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: TextField(
              controller: _vCardController,
              decoration: const InputDecoration(
                labelText: 'vCard Data',
                hintText:
                    'Paste vCard content here...\n\nBEGIN:VCARD\nVERSION:3.0\nFN:John Doe\n...\nEND:VCARD',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanQRCode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importVCard,
                  icon: const Icon(Icons.download),
                  label: const Text('Import'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _createContact() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a contact name')),
      );
      return;
    }

    final phoneNumbers = <ContactPhoneNumber>[];
    if (_phoneController.text.trim().isNotEmpty) {
      phoneNumbers.add(
        ContactPhoneNumber(
          number: _phoneController.text.trim(),
          type: 'mobile',
          isPrimary: true,
        ),
      );
    }

    final emails = <ContactEmail>[];
    if (_emailController.text.trim().isNotEmpty) {
      emails.add(
        ContactEmail(
          email: _emailController.text.trim(),
          type: 'personal',
          isPrimary: true,
        ),
      );
    }

    final contact = Contact(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      displayName: name,
      phoneNumbers: phoneNumbers,
      emails: emails,
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : null,
      createdAt: DateTime.now(),
      isFromDevice: false,
    );

    // Validate contact before proceeding
    if (!ContactService.isValidContact(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least a phone number or email'),
        ),
      );
      return;
    }

    widget.onContactSelected(contact);
  }

  void _importVCard() {
    final vCardData = _vCardController.text.trim();
    if (vCardData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please paste vCard data')));
      return;
    }

    if (!VCardUtils.isValidVCard(vCardData)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid vCard format')));
      return;
    }

    final contact = VCardUtils.vCardToContact(vCardData);
    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to parse vCard data')),
      );
      return;
    }

    widget.onContactSelected(contact);
  }

  void _scanQRCode() {
    // Placeholder for QR code scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code scanning coming soon!')),
    );
  }
}
