import 'dart:io';
import 'package:dio/dio.dart';

typedef UploadingProgress = void Function(int sent, int total);
typedef DebugLogger = void Function(String message);

enum UploadState { idle, running, success, error, canceled }

class UploadProgress {
  final int sent;
  final int? total;
  final UploadState state;

  double? get fraction =>
      (total != null && total! > 0) ? sent / total! : null;

  const UploadProgress({
    required this.sent,
    required this.total,
    required this.state,
  });

  factory UploadProgress.running(int sent, int? total) =>
      UploadProgress(sent: sent, total: total, state: UploadState.running);

  factory UploadProgress.success(int total) =>
      UploadProgress(sent: total, total: total, state: UploadState.success);

  factory UploadProgress.error() =>
      const UploadProgress(sent: 0, total: null, state: UploadState.error);

  factory UploadProgress.canceled() =>
      const UploadProgress(sent: 0, total: null, state: UploadState.canceled);
}

class GenericFileUploader {
  final Dio dio;
  final String url;
  final File file;
  final Map<String, String> headers;
  final UploadingProgress? onProgress;
  final DebugLogger? onDebug;

  CancelToken? _cancelToken;
  bool _isRunning = false;

  GenericFileUploader._({
    required this.dio,
    required this.url,
    required this.file,
    required this.headers,
    required this.onProgress,
    required this.onDebug,
  });

  static Future<GenericFileUploader> create({
    required String url,
    required File file,
    Map<String, String> headers = const {},
    UploadingProgress? onProgress,
    DebugLogger? onDebug,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 180),
        sendTimeout: const Duration(seconds: 180),
        headers: {
          'User-Agent': 'GenericFileUploader/1.0',
          ...headers,
        },
      ),
    );

    return GenericFileUploader._(
      dio: dio,
      url: url,
      file: file,
      headers: headers,
      onProgress: onProgress,
      onDebug: onDebug,
    );
  }

  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;
    _cancelToken = CancelToken();

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.uri.pathSegments.last),
      });

      final res = await dio.post(
        url,
        data: formData,
        cancelToken: _cancelToken,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
        },
      );

      onDebug?.call('Upload finished: ${res.statusCode}');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        onDebug?.call('Upload canceled');
      } else {
        onDebug?.call('Upload error: $e');
        rethrow;
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> cancel() async {
    if (_isRunning) {
      _cancelToken?.cancel('canceled');
    }
    _isRunning = false;
  }
}