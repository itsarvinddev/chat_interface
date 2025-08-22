// Comprehensive error handling service for ChatUI
// Provides centralized error management, logging, and recovery

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/chat_theme.dart';

/// Error types in ChatUI
enum ChatErrorType {
  network,
  authentication,
  permission,
  validation,
  storage,
  attachment,
  unknown,
}

/// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// ChatUI error class with comprehensive information
class ChatError {
  final ChatErrorType type;
  final ErrorSeverity severity;
  final String message;
  final String? userMessage;
  final String? technicalDetails;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final String? recoveryAction;

  ChatError({
    required this.type,
    required this.severity,
    required this.message,
    this.userMessage,
    this.technicalDetails,
    this.stackTrace,
    this.context,
    DateTime? timestamp,
    this.recoveryAction,
  }) : timestamp = timestamp ?? DateTime.now();

  // Named constructors for common error types
  factory ChatError.network({
    required String message,
    String? userMessage,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return ChatError(
      type: ChatErrorType.network,
      severity: ErrorSeverity.medium,
      message: message,
      userMessage: userMessage ?? 'Network connection failed',
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
      recoveryAction: 'retry',
    );
  }

  factory ChatError.authentication({
    required String message,
    String? userMessage,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return ChatError(
      type: ChatErrorType.authentication,
      severity: ErrorSeverity.high,
      message: message,
      userMessage: userMessage ?? 'Authentication failed',
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
      recoveryAction: 'reauthenticate',
    );
  }

  factory ChatError.permission({
    required String message,
    String? userMessage,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return ChatError(
      type: ChatErrorType.permission,
      severity: ErrorSeverity.medium,
      message: message,
      userMessage: userMessage ?? 'Permission required',
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
      recoveryAction: 'request_permission',
    );
  }

  factory ChatError.validation({
    required String message,
    String? userMessage,
    String? technicalDetails,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return ChatError(
      type: ChatErrorType.validation,
      severity: ErrorSeverity.low,
      message: message,
      userMessage: userMessage ?? 'Invalid input',
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      context: context,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'userMessage': userMessage,
      'technicalDetails': technicalDetails,
      'timestamp': timestamp.toIso8601String(),
      'recoveryAction': recoveryAction,
      'context': context,
    };
  }

  @override
  String toString() {
    return 'ChatError(${type.name}/${severity.name}): $message';
  }
}

/// Centralized error handling service
class ErrorHandlingService {
  static final List<ChatError> _errorHistory = [];
  static final List<Function(ChatError)> _errorListeners = [];
  static const int _maxErrorHistorySize = 100;

  /// Handle any error and convert it to ChatError
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ChatErrorType? type,
    ErrorSeverity? severity,
    String? userMessage,
  }) {
    final chatError = convertToChatError(
      error,
      stackTrace: stackTrace,
      context: context,
      type: type,
      severity: severity,
      userMessage: userMessage,
    );

    _addToHistory(chatError);
    _logError(chatError);
    _notifyListeners(chatError);
  }

  /// Add error listener
  static void addErrorListener(Function(ChatError) listener) {
    _errorListeners.add(listener);
  }

  /// Remove error listener
  static void removeErrorListener(Function(ChatError) listener) {
    _errorListeners.remove(listener);
  }

  /// Notify all listeners of new error
  static void _notifyListeners(ChatError error) {
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        debugPrint('Error in error listener: $e');
      }
    }
  }

  /// Convert any error to ChatError
  static ChatError convertToChatError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ChatErrorType? type,
    ErrorSeverity? severity,
    String? userMessage,
  }) {
    if (error is ChatError) {
      return error;
    }

    // Handle specific error types
    if (error is FormatException) {
      return ChatError(
        type: ChatErrorType.validation,
        severity: ErrorSeverity.low,
        message: 'Format error: ${error.message}',
        userMessage: userMessage ?? 'Invalid data format',
        technicalDetails: error.toString(),
        stackTrace: stackTrace,
        context: context,
      );
    }

    if (error is ArgumentError) {
      return ChatError(
        type: ChatErrorType.validation,
        severity: ErrorSeverity.medium,
        message: 'Argument error: ${error.message}',
        userMessage: userMessage ?? 'Invalid input provided',
        technicalDetails: error.toString(),
        stackTrace: stackTrace,
        context: context,
      );
    }

    // Generic error
    return ChatError(
      type: type ?? ChatErrorType.unknown,
      severity: severity ?? ErrorSeverity.medium,
      message: error.toString(),
      userMessage:
          userMessage ?? 'An unexpected error occurred. Please try again.',
      technicalDetails: error.toString(),
      stackTrace: stackTrace,
      context: context,
      recoveryAction: 'retry',
    );
  }

  /// Add error to history
  static void _addToHistory(ChatError error) {
    _errorHistory.add(error);
    if (_errorHistory.length > _maxErrorHistorySize) {
      _errorHistory.removeAt(0);
    }
  }

  /// Log error appropriately
  static void _logError(ChatError error) {
    final logMessage =
        'ChatUI Error [${error.type.name}/${error.severity.name}]: ${error.message}';

    if (kDebugMode) {
      debugPrint(logMessage);
      if (error.technicalDetails != null) {
        debugPrint('Technical Details: ${error.technicalDetails}');
      }
      if (error.stackTrace != null) {
        debugPrint('Stack Trace: ${error.stackTrace}');
      }
    }

    // In production, you might want to send to a logging service
    if (kReleaseMode && error.severity == ErrorSeverity.critical) {
      // Send to crash reporting service
      _sendToCrashReporting(error);
    }
  }

  /// Send error to crash reporting service
  static void _sendToCrashReporting(ChatError error) {
    // Implement your crash reporting logic here
    // e.g., Firebase Crashlytics, Sentry, etc.
  }

  /// Get error history
  static List<ChatError> getErrorHistory() {
    return List.unmodifiable(_errorHistory);
  }

  /// Clear error history
  static void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get error statistics
  static Map<String, dynamic> getErrorStatistics() {
    final typeCount = <String, int>{};
    final severityCount = <String, int>{};

    for (final error in _errorHistory) {
      typeCount[error.type.name] = (typeCount[error.type.name] ?? 0) + 1;
      severityCount[error.severity.name] =
          (severityCount[error.severity.name] ?? 0) + 1;
    }

    return {
      'totalErrors': _errorHistory.length,
      'byType': typeCount,
      'bySeverity': severityCount,
      'recentErrors': _errorHistory.take(10).map((e) => e.toJson()).toList(),
    };
  }
}

/// Error boundary widget for catching and handling errors
class ChatErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(ChatError error)? errorBuilder;
  final void Function(ChatError error)? onError;
  final bool showErrorDetails;

  const ChatErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showErrorDetails = kDebugMode,
  });

  @override
  State<ChatErrorBoundary> createState() => _ChatErrorBoundaryState();
}

class _ChatErrorBoundaryState extends State<ChatErrorBoundary> {
  ChatError? _error;

  @override
  void initState() {
    super.initState();

    // Listen for errors
    ErrorHandlingService.addErrorListener(_handleError);
  }

  @override
  void dispose() {
    ErrorHandlingService.removeErrorListener(_handleError);
    super.dispose();
  }

  void _handleError(ChatError error) {
    if (mounted) {
      setState(() {
        _error = error;
      });

      // Call custom error handler
      widget.onError?.call(error);
    }
  }

  void _clearError() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          ChatErrorWidget(
            error: _error!,
            onRetry: _clearError,
            showDetails: widget.showErrorDetails,
          );
    }

    return widget.child;
  }
}

/// Default error display widget
class ChatErrorWidget extends StatelessWidget {
  final ChatError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;

  const ChatErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    return Container(
      padding: EdgeInsets.all(ChatDesignTokens.spaceLg),
      margin: EdgeInsets.all(ChatDesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: theme.errorColor.withOpacity(0.1),
        border: Border.all(color: theme.errorColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(ChatDesignTokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error header
          Row(
            children: [
              Icon(_getErrorIcon(), color: theme.errorColor, size: 24),
              SizedBox(width: ChatDesignTokens.spaceXs),
              Expanded(
                child: Text(
                  _getErrorTitle(),
                  style: theme.headerTextStyle.copyWith(
                    color: theme.errorColor,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, color: theme.errorColor),
                  onPressed: onDismiss,
                  iconSize: 20,
                ),
            ],
          ),

          SizedBox(height: ChatDesignTokens.spaceXs),

          // Error message
          Text(
            error.userMessage ?? error.message,
            style: theme.messageTextStyle,
          ),

          if (showDetails && error.technicalDetails != null) ...[
            SizedBox(height: ChatDesignTokens.spaceXs),
            ExpansionTile(
              title: Text('Technical Details', style: theme.timestampTextStyle),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ChatDesignTokens.spaceXs),
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius: BorderRadius.circular(
                      ChatDesignTokens.radiusXs,
                    ),
                  ),
                  child: Text(
                    error.technicalDetails!,
                    style: theme.timestampTextStyle.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (error.recoveryAction != null) ...[
            SizedBox(height: ChatDesignTokens.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: theme.surfaceColor,
                    ),
                    child: Text(_getRetryButtonText()),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case ChatErrorType.network:
        return Icons.wifi_off;
      case ChatErrorType.authentication:
        return Icons.lock;
      case ChatErrorType.permission:
        return Icons.security;
      case ChatErrorType.validation:
        return Icons.warning;
      case ChatErrorType.storage:
        return Icons.storage;
      case ChatErrorType.attachment:
        return Icons.attach_file;
      case ChatErrorType.unknown:
        return Icons.error;
    }
  }

  String _getErrorTitle() {
    switch (error.type) {
      case ChatErrorType.network:
        return 'Connection Error';
      case ChatErrorType.authentication:
        return 'Authentication Error';
      case ChatErrorType.permission:
        return 'Permission Required';
      case ChatErrorType.validation:
        return 'Validation Error';
      case ChatErrorType.storage:
        return 'Storage Error';
      case ChatErrorType.attachment:
        return 'Attachment Error';
      case ChatErrorType.unknown:
        return 'Error';
    }
  }

  String _getRetryButtonText() {
    switch (error.recoveryAction) {
      case 'retry':
        return 'Retry';
      case 'reauthenticate':
        return 'Sign In';
      case 'request_permission':
        return 'Grant Permission';
      default:
        return 'Try Again';
    }
  }
}
