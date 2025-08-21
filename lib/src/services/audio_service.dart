import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Lightweight wrapper around audio_waveforms to record audio clips
/// and return them as chat Attachments.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final RecorderController _recorder = RecorderController();
  bool _isRecording = false;
  String? _currentPath;

  bool get isRecording => _isRecording;

  Future<void> init() async {
    // No-op for now. Keep for future configuration.
  }

  /// Start recording to a temporary file. Returns the file path.
  Future<String?> startRecording() async {
    if (_isRecording) return _currentPath;
    try {
      final Directory tmp = await _getTempDir();
      final String path =
          '${tmp.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.record(path: path);
      _isRecording = true;
      _currentPath = path;
      return path;
    } catch (e) {
      debugPrint('AudioService.startRecording error: $e');
      return null;
    }
  }

  /// Stop recording and return an Attachment for the clip.
  Future<Attachment?> stopRecording() async {
    if (!_isRecording) return null;
    try {
      final String? path = _currentPath;
      await _recorder.stop();
      _isRecording = false;
      _currentPath = null;
      if (path == null) return null;
      final File f = File(path);
      if (!await f.exists()) return null;
      return Attachment(
        uri: f.uri.toString(),
        mimeType: 'audio/m4a',
        sizeBytes: await f.length(),
        thumbnailUri: null,
      );
    } catch (e) {
      debugPrint('AudioService.stopRecording error: $e');
      _isRecording = false;
      _currentPath = null;
      return null;
    }
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    try {
      final String? path = _currentPath;
      await _recorder.stop();
      _isRecording = false;
      _currentPath = null;
      if (path != null) {
        final File f = File(path);
        if (await f.exists()) {
          await f.delete();
        }
      }
    } catch (e) {
      debugPrint('AudioService.cancelRecording error: $e');
    }
  }

  Future<Directory> _getTempDir() async {
    // Use system temp; on Flutter test/env this exists
    return Directory.systemTemp.createTemp('chatui_audio');
  }
}
