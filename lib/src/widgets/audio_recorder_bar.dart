import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/audio_service.dart';

class AudioRecorderBar extends StatefulWidget {
  final ValueChanged<Attachment?> onFinished;
  final VoidCallback? onCancel;

  const AudioRecorderBar({super.key, required this.onFinished, this.onCancel});

  @override
  State<AudioRecorderBar> createState() => _AudioRecorderBarState();
}

class _AudioRecorderBarState extends State<AudioRecorderBar> {
  final AudioService _audio = AudioService();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggle() async {
    if (_isRecording) {
      final Attachment? a = await _audio.stopRecording();
      setState(() => _isRecording = false);
      widget.onFinished(a);
    } else {
      await _audio.startRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _cancel() async {
    await _audio.cancelRecording();
    setState(() => _isRecording = false);
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: _isRecording ? 'Stop' : 'Record',
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed: _toggle,
          ),
          Expanded(
            child: Text(
              _isRecording
                  ? 'Recording… tap stop to finish'
                  : 'Tap mic to record',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: 'Cancel',
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
        ],
      ),
    );
  }
}
