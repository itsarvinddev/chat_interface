import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

class PollCreator extends StatefulWidget {
  final ValueChanged<PollSummary> onPollCreated;
  final VoidCallback? onCancel;

  const PollCreator({
    super.key,
    required this.onPollCreated,
    this.onCancel,
  });

  @override
  State<PollCreator> createState() => _PollCreatorState();
}

class _PollCreatorState extends State<PollCreator> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<FocusNode> _optionFocusNodes = [
    FocusNode(),
    FocusNode(),
  ];
  
  bool _isMultipleChoice = false;
  bool _isAnonymous = false;
  DateTime? _expiresAt;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    for (final focusNode in _optionFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
        _optionFocusNodes.add(FocusNode());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionFocusNodes[index].dispose();
        _optionControllers.removeAt(index);
        _optionFocusNodes.removeAt(index);
      });
    }
  }

  bool _canCreatePoll() {
    final question = _questionController.text.trim();
    if (question.isEmpty) return false;
    
    final validOptions = _optionControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .length;
    return validOptions >= 2;
  }

  void _createPoll() {
    if (!_canCreatePoll()) return;

    final question = _questionController.text.trim();
    final options = <PollOption>[];
    
    for (int i = 0; i < _optionControllers.length; i++) {
      final text = _optionControllers[i].text.trim();
      if (text.isNotEmpty) {
        options.add(PollOption(
          id: 'option_$i',
          text: text,
        ));
      }
    }

    final poll = PollSummary(
      question: question,
      options: options,
      createdAt: DateTime.now(),
      expiresAt: _expiresAt,
      isMultipleChoice: _isMultipleChoice,
      isAnonymous: _isAnonymous,
    );

    widget.onPollCreated(poll);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.poll,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Create Poll',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question input
          TextField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'What would you like to ask?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Options
          Text(
            'Options',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          ...List.generate(_optionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _optionControllers[index],
                      focusNode: _optionFocusNodes[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        border: const OutlineInputBorder(),
                        suffixIcon: _optionControllers.length > 2
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeOption(index),
                                tooltip: 'Remove option',
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add option button
          if (_optionControllers.length < 10)
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),

          const SizedBox(height: 16),

          // Poll settings
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Multiple choice toggle
          SwitchListTile(
            title: const Text('Multiple choice'),
            subtitle: const Text('Allow users to select multiple options'),
            value: _isMultipleChoice,
            onChanged: (value) => setState(() => _isMultipleChoice = value),
            contentPadding: EdgeInsets.zero,
          ),

          // Anonymous toggle
          SwitchListTile(
            title: const Text('Anonymous poll'),
            subtitle: const Text('Hide who voted for what'),
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            contentPadding: EdgeInsets.zero,
          ),

          // Expiration date picker
          ListTile(
            title: const Text('Expiration'),
            subtitle: Text(_expiresAt == null 
                ? 'No expiration' 
                : 'Expires on ${_formatDate(_expiresAt!)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_expiresAt != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _expiresAt = null),
                    tooltip: 'Remove expiration',
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectExpirationDate(context),
                  tooltip: 'Set expiration date',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canCreatePoll() ? _createPoll : null,
                  child: const Text('Create Poll'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(hours: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _expiresAt = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<PollSummary> onPollCreated,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PollCreator(
        onPollCreated: onPollCreated,
        onCancel: onCancel,
      ),
    );
  }
}
