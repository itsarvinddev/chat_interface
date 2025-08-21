import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class AudioMessageTile extends StatefulWidget {
  final Attachment audio;
  const AudioMessageTile({super.key, required this.audio});

  @override
  State<AudioMessageTile> createState() => _AudioMessageTileState();
}

class _AudioMessageTileState extends State<AudioMessageTile> {
  late final PlayerController _player;
  bool _isReady = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = PlayerController();
    _init();
  }

  Future<void> _init() async {
    try {
      final String path = Uri.parse(widget.audio.uri).toFilePath();
      if (await File(path).exists()) {
        await _player.preparePlayer(path: path);
        setState(() => _isReady = true);
      }
    } catch (_) {}
  }

  Future<void> _togglePlay() async {
    if (!_isReady) return;
    if (_isPlaying) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      await _player.startPlayer();
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlay,
        ),
        Expanded(
          child: _isReady
              ? AudioFileWaveforms(
                  playerController: _player,
                  size: const Size(200, 32),
                  playerWaveStyle: const PlayerWaveStyle(
                    fixedWaveColor: Colors.grey,
                    liveWaveColor: Colors.blue,
                  ),
                )
              : const SizedBox(width: 200, height: 32),
        ),
      ],
    );
  }
}
