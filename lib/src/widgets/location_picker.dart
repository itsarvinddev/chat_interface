import 'package:flutter/material.dart';

import '../models/models.dart';

class LocationPicker extends StatelessWidget {
  final ValueChanged<LocationAttachment> onLocationSelected;
  final VoidCallback? onCancel;

  const LocationPicker({
    super.key,
    required this.onLocationSelected,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Location Picker'),
          ElevatedButton(
            onPressed: () {
              final location = LocationAttachment(
                latitude: 37.7749,
                longitude: -122.4194,
                timestamp: DateTime.now(),
              );
              onLocationSelected(location);
            },
            child: Text('Select Location'),
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<LocationAttachment> onLocationSelected,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => LocationPicker(
        onLocationSelected: onLocationSelected,
        onCancel: onCancel,
      ),
    );
  }
}
