import 'package:flutter/material.dart';

import '../models/models.dart';

/// A comprehensive widget for creating polls with options, settings, and validation
class PollCreator extends StatefulWidget {
  /// Called when a poll is created and should be sent
  final void Function(Poll poll) onPollCreated;

  /// Optional initial poll data for editing
  final Poll? initialPoll;

  /// Whether to show advanced settings by default
  final bool showAdvancedSettings;

  const PollCreator({
    super.key,
    required this.onPollCreated,
    this.initialPoll,
    this.showAdvancedSettings = false,
  });

  /// Show poll creator as a modal bottom sheet
  static Future<Poll?> show({
    required BuildContext context,
    Poll? initialPoll,
    bool showAdvancedSettings = false,
  }) async {
    Poll? createdPoll;

    final result = await showModalBottomSheet<Poll>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: PollCreator(
          initialPoll: initialPoll,
          showAdvancedSettings: showAdvancedSettings,
          onPollCreated: (poll) {
            createdPoll = poll;
            Navigator.of(context).pop(poll);
          },
        ),
      ),
    );

    return result ?? createdPoll;
  }

  @override
  State<PollCreator> createState() => _PollCreatorState();
}

class _PollCreatorState extends State<PollCreator> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  PollType _pollType = PollType.singleChoice;
  bool _isAnonymous = false;
  bool _hasDeadline = false;
  DateTime? _deadline;
  int? _maxSelections;
  bool _showAdvancedSettings = false;

  @override
  void initState() {
    super.initState();
    _showAdvancedSettings = widget.showAdvancedSettings;

    if (widget.initialPoll != null) {
      _initializeFromExistingPoll();
    } else {
      _addInitialOptions();
    }
  }

  void _initializeFromExistingPoll() {
    final poll = widget.initialPoll!;
    _questionController.text = poll.question;
    _pollType = poll.type;
    _isAnonymous = poll.isAnonymous;
    _maxSelections = poll.maxSelections;
    _deadline = poll.deadline;
    _hasDeadline = poll.deadline != null;

    for (final option in poll.options) {
      final controller = TextEditingController(text: option.text);
      _optionControllers.add(controller);
    }

    // Ensure at least 2 options
    while (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
    }
  }

  void _addInitialOptions() {
    // Start with 2 empty options
    _optionControllers.add(TextEditingController());
    _optionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      // Limit to 10 options
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      // Keep at least 2 options
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _createPoll() {
    if (!_formKey.currentState!.validate()) return;

    final question = _questionController.text.trim();
    final options = _optionControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .map(
          (controller) => PollOption(
            id: 'option_${DateTime.now().millisecondsSinceEpoch}_${_optionControllers.indexOf(controller)}',
            text: controller.text.trim(),
          ),
        )
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 options')),
      );
      return;
    }

    final poll = Poll(
      id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
      question: question,
      options: options,
      type: _pollType,
      isAnonymous: _isAnonymous,
      maxSelections: _maxSelections,
      deadline: _deadline,
      createdAt: DateTime.now(),
      createdBy: 'current_user', // This should come from the chat system
      creatorName: 'You', // This should come from the chat system
    );

    widget.onPollCreated(poll);
  }

  Widget _buildQuestionField() {
    return TextFormField(
      controller: _questionController,
      decoration: const InputDecoration(
        labelText: 'Poll Question',
        hintText: 'What would you like to ask?',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.help_outline),
      ),
      maxLines: 2,
      maxLength: 200,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a question';
        }
        if (value.trim().length < 3) {
          return 'Question must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildOptionField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                labelText: 'Option ${index + 1}',
                hintText: 'Enter an option',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  _pollType == PollType.singleChoice
                      ? Icons.radio_button_unchecked
                      : Icons.check_box_outline_blank,
                ),
              ),
              maxLength: 100,
              validator: (value) {
                // Only validate non-empty fields
                if (value != null &&
                    value.trim().isNotEmpty &&
                    value.trim().isEmpty) {
                  return 'Option must not be empty';
                }
                return null;
              },
            ),
          ),
          if (_optionControllers.length > 2)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _removeOption(index),
            ),
        ],
      ),
    );
  }

  Widget _buildPollTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Poll Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            RadioListTile<PollType>(
              title: const Text('Single Choice'),
              subtitle: const Text('Users can select only one option'),
              value: PollType.singleChoice,
              groupValue: _pollType,
              onChanged: (value) => setState(() => _pollType = value!),
            ),
            RadioListTile<PollType>(
              title: const Text('Multiple Choice'),
              subtitle: const Text('Users can select multiple options'),
              value: PollType.multipleChoice,
              groupValue: _pollType,
              onChanged: (value) => setState(() => _pollType = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Advanced Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _showAdvancedSettings
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  onPressed: () => setState(
                    () => _showAdvancedSettings = !_showAdvancedSettings,
                  ),
                ),
              ],
            ),
            if (_showAdvancedSettings) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Anonymous Voting'),
                subtitle: const Text('Hide who voted for what'),
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Set Deadline'),
                subtitle: const Text('Automatically close poll after deadline'),
                value: _hasDeadline,
                onChanged: (value) => setState(() {
                  _hasDeadline = value;
                  if (!value) _deadline = null;
                }),
              ),
              if (_hasDeadline) ...[
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Deadline'),
                  subtitle: Text(
                    _deadline?.toString().split('.')[0] ?? 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDeadline,
                ),
              ],
              if (_pollType == PollType.multipleChoice) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Max Selections (optional)',
                    hintText: 'Leave empty for unlimited',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final intValue = int.tryParse(value);
                    setState(() => _maxSelections = intValue);
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final intValue = int.tryParse(value);
                      if (intValue == null || intValue < 1) {
                        return 'Must be a positive number';
                      }
                      if (intValue > _optionControllers.length) {
                        return 'Cannot exceed number of options';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _deadline ?? now.add(const Duration(hours: 1)),
        ),
      );

      if (time != null) {
        setState(() {
          _deadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialPoll != null ? 'Edit Poll' : 'Create Poll'),
        actions: [
          TextButton(
            onPressed: _createPoll,
            child: Text(
              widget.initialPoll != null ? 'Update' : 'Create',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildQuestionField(),
            const SizedBox(height: 24),

            // Options section
            Row(
              children: [
                const Text(
                  'Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (_optionControllers.length < 10)
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Option'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Option fields
            ...List.generate(
              _optionControllers.length,
              (index) => _buildOptionField(index),
            ),

            const SizedBox(height: 24),
            _buildPollTypeSelector(),
            const SizedBox(height: 16),
            _buildAdvancedSettings(),
            const SizedBox(height: 80), // Space for floating action button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPoll,
        icon: const Icon(Icons.poll),
        label: Text(widget.initialPoll != null ? 'Update Poll' : 'Create Poll'),
      ),
    );
  }
}
