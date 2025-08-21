import 'package:flutter/material.dart';

class ReactionPicker {
  static Future<String?> show(BuildContext context) async {
    final List<String> reactions = <String>['👍', '❤️', '😂', '🎉', '😮', '😢'];
    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                for (final String r in reactions)
                  ActionChip(
                    label: Text(r, style: const TextStyle(fontSize: 20)),
                    onPressed: () {
                      Navigator.of(context).pop(r);
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: const Text('Reply'),
                  onTap: () => Navigator.of(context).pop('reply'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
