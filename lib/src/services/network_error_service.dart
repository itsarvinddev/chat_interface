// Network error handling service for ChatUI
// Provides retry logic, connection monitoring, and smart recovery

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'error_handling_service.dart';

/// Network connection states
enum NetworkConnectionState { connected, disconnected, connecting, unstable }

/// Network error categories
enum NetworkErrorCategory {
  noConnection,
  timeout,
  serverError,
  clientError,
  rateLimited,
  serviceUnavailable,
}

/// Network operation result
class NetworkOperationResult<T> {
  final T? data;
  final ChatError? error;
  final bool isSuccess;
  final int attemptCount;
  final Duration totalDuration;

  const NetworkOperationResult({
    this.data,
    this.error,
    required this.isSuccess,
    required this.attemptCount,
    required this.totalDuration,
  });

  factory NetworkOperationResult.success(
    T data, {
    required int attemptCount,
    required Duration totalDuration,
  }) {
    return NetworkOperationResult(
      data: data,
      isSuccess: true,
      attemptCount: attemptCount,
      totalDuration: totalDuration,
    );
  }

  factory NetworkOperationResult.failure(
    ChatError error, {
    required int attemptCount,
    required Duration totalDuration,
  }) {
    return NetworkOperationResult(
      error: error,
      isSuccess: false,
      attemptCount: attemptCount,
      totalDuration: totalDuration,
    );
  }
}

/// Retry configuration for network operations
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool exponentialBackoff;
  final bool jitterEnabled;
  final List<NetworkErrorCategory> retryableErrors;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.exponentialBackoff = true,
    this.jitterEnabled = true,
    this.retryableErrors = const [
      NetworkErrorCategory.noConnection,
      NetworkErrorCategory.timeout,
      NetworkErrorCategory.serverError,
      NetworkErrorCategory.serviceUnavailable,
    ],
  });

  /// Default retry config for chat operations
  static const RetryConfig chat = RetryConfig(
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 1.5,
  );

  /// Aggressive retry config for critical operations
  static const RetryConfig critical = RetryConfig(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 15),
    backoffMultiplier: 2.0,
  );

  /// Conservative retry config for non-critical operations
  static const RetryConfig conservative = RetryConfig(
    maxRetries: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 20),
    backoffMultiplier: 3.0,
  );
}

/// Network error handling service
class NetworkErrorService {
  static final NetworkErrorService _instance = NetworkErrorService._internal();
  factory NetworkErrorService() => _instance;
  NetworkErrorService._internal();

  final ValueNotifier<NetworkConnectionState> connectionState = ValueNotifier(
    NetworkConnectionState.connected,
  );

  Timer? _connectionMonitorTimer;
  Timer? _retryScheduleTimer;
  final Map<String, int> _operationRetryCount = {};
  final Map<String, DateTime> _lastAttemptTime = {};
  final List<_PendingOperation> _pendingOperations = [];

  // Connection monitoring
  bool _isMonitoring = false;
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 3;
  static const Duration _connectionCheckInterval = Duration(seconds: 10);

  /// Initialize network monitoring
  void initialize() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _startConnectionMonitoring();
  }

  /// Execute network operation with retry logic
  Future<NetworkOperationResult<T>> executeWithRetry<T>({
    required String operationId,
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.chat,
    Map<String, dynamic>? context,
  }) async {
    final startTime = DateTime.now();
    int attemptCount = 0;
    ChatError? lastError;

    // Check if we should even attempt the operation
    if (!_shouldAttemptOperation(operationId, config)) {
      return NetworkOperationResult.failure(
        ChatError.network(
          message: 'Operation rate limited',
          userMessage:
              'Too many recent attempts. Please wait before trying again.',
          context: context,
        ),
        attemptCount: 0,
        totalDuration: Duration.zero,
      );
    }

    while (attemptCount <= config.maxRetries) {
      attemptCount++;
      _lastAttemptTime[operationId] = DateTime.now();

      try {
        // Check connection state before attempting
        if (connectionState.value == NetworkConnectionState.disconnected) {
          await _waitForConnection();
        }

        final result = await operation();

        // Success - clear retry count and return
        _operationRetryCount.remove(operationId);
        _consecutiveFailures = 0;

        return NetworkOperationResult.success(
          result,
          attemptCount: attemptCount,
          totalDuration: DateTime.now().difference(startTime),
        );
      } catch (error, stackTrace) {
        lastError = _convertToNetworkError(error, stackTrace, context);

        // Handle different error types
        await _handleNetworkError(lastError, operationId);

        // Check if we should retry
        if (!_shouldRetry(lastError, attemptCount, config)) {
          break;
        }

        // Calculate delay before next attempt
        if (attemptCount <= config.maxRetries) {
          final delay = _calculateRetryDelay(attemptCount, config);
          await Future.delayed(delay);
        }
      }
    }

    // All retries exhausted
    _operationRetryCount[operationId] = attemptCount;

    return NetworkOperationResult.failure(
      lastError ??
          ChatError.network(
            message: 'Operation failed after $attemptCount attempts',
            context: context,
          ),
      attemptCount: attemptCount,
      totalDuration: DateTime.now().difference(startTime),
    );
  }

  /// Queue operation for retry when connection is restored
  void queueForRetry({
    required String operationId,
    required Future<void> Function() operation,
    RetryConfig config = RetryConfig.chat,
    Map<String, dynamic>? context,
  }) {
    _pendingOperations.add(
      _PendingOperation(
        id: operationId,
        operation: operation,
        config: config,
        context: context,
        queuedAt: DateTime.now(),
      ),
    );

    debugPrint('Queued operation $operationId for retry');
  }

  /// Check current connection status
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (isConnected) {
        _setConnectionState(NetworkConnectionState.connected);
        _consecutiveFailures = 0;
      } else {
        _handleConnectionFailure();
      }

      return isConnected;
    } catch (e) {
      _handleConnectionFailure();
      return false;
    }
  }

  /// Get network statistics
  Map<String, dynamic> getNetworkStats() {
    return {
      'connectionState': connectionState.value.name,
      'consecutiveFailures': _consecutiveFailures,
      'pendingOperations': _pendingOperations.length,
      'retryingOperations': _operationRetryCount.length,
      'isMonitoring': _isMonitoring,
    };
  }

  /// Clear all pending operations
  void clearPendingOperations() {
    _pendingOperations.clear();
    debugPrint('Cleared all pending operations');
  }

  /// Start connection monitoring
  void _startConnectionMonitoring() {
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = Timer.periodic(_connectionCheckInterval, (_) {
      checkConnection();
    });
  }

  /// Convert error to network error
  ChatError _convertToNetworkError(
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic>? context,
  ) {
    if (error is SocketException) {
      return ChatError.network(
        message: 'Network connection error: ${error.message}',
        userMessage:
            'Connection failed. Please check your internet connection.',
        technicalDetails: error.toString(),
        stackTrace: stackTrace,
        context: context,
      );
    }

    if (error is TimeoutException) {
      return ChatError.network(
        message: 'Network timeout: ${error.message}',
        userMessage: 'Request timed out. Please try again.',
        technicalDetails: error.toString(),
        stackTrace: stackTrace,
        context: context,
      );
    }

    if (error is HttpException) {
      final statusCode = _extractStatusCode(error.message);
      return _createHttpError(statusCode, error, stackTrace, context);
    }

    return ChatError.network(
      message: 'Network error: ${error.toString()}',
      userMessage: 'Network operation failed. Please try again.',
      technicalDetails: error.toString(),
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Create HTTP-specific error
  ChatError _createHttpError(
    int? statusCode,
    HttpException error,
    StackTrace stackTrace,
    Map<String, dynamic>? context,
  ) {
    switch (statusCode) {
      case 400:
        return ChatError.validation(
          message: 'Bad request: ${error.message}',
          userMessage: 'Invalid request. Please check your input.',
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
          context: context,
        );
      case 401:
        return ChatError.authentication(
          message: 'Unauthorized: ${error.message}',
          userMessage: 'Authentication required. Please sign in again.',
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
          context: context,
        );
      case 403:
        return ChatError.permission(
          message: 'Forbidden: ${error.message}',
          userMessage:
              'Access denied. You don\'t have permission for this action.',
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
          context: context,
        );
      case 429:
        return ChatError.network(
          message: 'Rate limited: ${error.message}',
          userMessage:
              'Too many requests. Please wait a moment before trying again.',
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
          context: context,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ChatError.network(
          message: 'Server error: ${error.message}',
          userMessage:
              'Server is temporarily unavailable. Please try again later.',
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
          context: context,
        );
      default:
        return ChatError.network(
          message: 'HTTP error: ${error.message}',
          userMessage: 'Network request failed. Please try again.',
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
          context: context,
        );
    }
  }

  /// Extract status code from error message
  int? _extractStatusCode(String message) {
    final regex = RegExp(r'(\d{3})');
    final match = regex.firstMatch(message);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Handle network error
  Future<void> _handleNetworkError(ChatError error, String operationId) async {
    _consecutiveFailures++;

    // Update connection state based on error
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      _setConnectionState(NetworkConnectionState.disconnected);
    } else {
      _setConnectionState(NetworkConnectionState.unstable);
    }

    // Report error to error handling service
    ErrorHandlingService.handleError(error);
  }

  /// Check if we should attempt the operation
  bool _shouldAttemptOperation(String operationId, RetryConfig config) {
    final lastAttempt = _lastAttemptTime[operationId];
    if (lastAttempt == null) return true;

    final retryCount = _operationRetryCount[operationId] ?? 0;
    if (retryCount >= config.maxRetries) {
      final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
      // Allow retry after a longer cooldown period
      return timeSinceLastAttempt > config.maxDelay * 2;
    }

    return true;
  }

  /// Check if should retry after error
  bool _shouldRetry(ChatError error, int attemptCount, RetryConfig config) {
    if (attemptCount > config.maxRetries) return false;

    final category = _categorizeNetworkError(error);
    return config.retryableErrors.contains(category);
  }

  /// Categorize network error
  NetworkErrorCategory _categorizeNetworkError(ChatError error) {
    final message = error.message.toLowerCase();

    if (message.contains('no route to host') ||
        message.contains('network is unreachable')) {
      return NetworkErrorCategory.noConnection;
    }

    if (message.contains('timeout')) {
      return NetworkErrorCategory.timeout;
    }

    if (message.contains('rate limit')) {
      return NetworkErrorCategory.rateLimited;
    }

    if (message.contains('server') || message.contains('5')) {
      return NetworkErrorCategory.serverError;
    }

    if (message.contains('service unavailable')) {
      return NetworkErrorCategory.serviceUnavailable;
    }

    return NetworkErrorCategory.clientError;
  }

  /// Calculate retry delay with backoff
  Duration _calculateRetryDelay(int attemptCount, RetryConfig config) {
    Duration delay = config.initialDelay;

    if (config.exponentialBackoff) {
      delay = Duration(
        milliseconds:
            (config.initialDelay.inMilliseconds *
                    pow(config.backoffMultiplier, attemptCount - 1))
                .round(),
      );
    } else {
      delay = Duration(
        milliseconds: config.initialDelay.inMilliseconds * attemptCount,
      );
    }

    // Cap at max delay
    if (delay > config.maxDelay) {
      delay = config.maxDelay;
    }

    // Add jitter to prevent thundering herd
    if (config.jitterEnabled) {
      final jitter = Random().nextDouble() * 0.3; // ±30% jitter
      delay = Duration(
        milliseconds: (delay.inMilliseconds * (1 + jitter)).round(),
      );
    }

    return delay;
  }

  /// Set connection state and notify listeners
  void _setConnectionState(NetworkConnectionState state) {
    if (connectionState.value != state) {
      connectionState.value = state;
      debugPrint('Network connection state changed to: ${state.name}');

      // Process pending operations if connected
      if (state == NetworkConnectionState.connected) {
        _processPendingOperations();
      }
    }
  }

  /// Handle connection failure
  void _handleConnectionFailure() {
    _consecutiveFailures++;

    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      _setConnectionState(NetworkConnectionState.disconnected);
    } else {
      _setConnectionState(NetworkConnectionState.unstable);
    }
  }

  /// Wait for connection to be restored
  Future<void> _waitForConnection() async {
    final completer = Completer<void>();

    void onConnectionChanged() {
      if (connectionState.value == NetworkConnectionState.connected) {
        connectionState.removeListener(onConnectionChanged);
        completer.complete();
      }
    }

    connectionState.addListener(onConnectionChanged);

    // Also set a timeout to prevent infinite waiting
    Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        connectionState.removeListener(onConnectionChanged);
        completer.complete();
      }
    });

    return completer.future;
  }

  /// Process pending operations when connection is restored
  void _processPendingOperations() {
    if (_pendingOperations.isEmpty) return;

    debugPrint('Processing ${_pendingOperations.length} pending operations');

    final operationsToProcess = List<_PendingOperation>.from(
      _pendingOperations,
    );
    _pendingOperations.clear();

    for (final pendingOp in operationsToProcess) {
      // Check if operation hasn't expired
      final age = DateTime.now().difference(pendingOp.queuedAt);
      if (age < const Duration(minutes: 5)) {
        // Execute with a small delay to avoid overwhelming the network
        Timer(Duration(milliseconds: Random().nextInt(1000)), () {
          pendingOp.operation().catchError((error) {
            debugPrint(
              'Error executing pending operation ${pendingOp.id}: $error',
            );
          });
        });
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _connectionMonitorTimer?.cancel();
    _retryScheduleTimer?.cancel();
    connectionState.dispose();
    _operationRetryCount.clear();
    _lastAttemptTime.clear();
    _pendingOperations.clear();
    _isMonitoring = false;
  }
}

/// Pending operation data class
class _PendingOperation {
  final String id;
  final Future<void> Function() operation;
  final RetryConfig config;
  final Map<String, dynamic>? context;
  final DateTime queuedAt;

  _PendingOperation({
    required this.id,
    required this.operation,
    required this.config,
    required this.context,
    required this.queuedAt,
  });
}

/// Network-aware widget that reacts to connection changes
class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(NetworkConnectionState state)?
  connectionIndicatorBuilder;
  final bool showConnectionIndicator;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.connectionIndicatorBuilder,
    this.showConnectionIndicator = true,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final NetworkErrorService _networkService = NetworkErrorService();

  @override
  void initState() {
    super.initState();
    _networkService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NetworkConnectionState>(
      valueListenable: _networkService.connectionState,
      builder: (context, connectionState, child) {
        return Stack(
          children: [
            widget.child,
            if (widget.showConnectionIndicator &&
                connectionState != NetworkConnectionState.connected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child:
                    widget.connectionIndicatorBuilder?.call(connectionState) ??
                    _DefaultConnectionIndicator(state: connectionState),
              ),
          ],
        );
      },
    );
  }
}

/// Default connection indicator
class _DefaultConnectionIndicator extends StatelessWidget {
  final NetworkConnectionState state;

  const _DefaultConnectionIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String message;
    IconData icon;

    switch (state) {
      case NetworkConnectionState.disconnected:
        backgroundColor = Colors.red;
        message = 'No internet connection';
        icon = Icons.wifi_off;
        break;
      case NetworkConnectionState.connecting:
        backgroundColor = Colors.orange;
        message = 'Connecting...';
        icon = Icons.wifi;
        break;
      case NetworkConnectionState.unstable:
        backgroundColor = Colors.yellow[700]!;
        message = 'Unstable connection';
        icon = Icons.wifi_1_bar;
        break;
      case NetworkConnectionState.connected:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
