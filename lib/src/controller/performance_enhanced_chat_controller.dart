// Performance-enhanced ChatController with optimizations
// Provides batching, throttling, lazy loading, and memory management

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/performance_service.dart';
import 'chat_controller.dart';

/// Performance-enhanced ChatController with optimizations
class PerformanceEnhancedChatController extends ChatController {
  final PerformanceService _performanceService = PerformanceService();

  // Performance optimization settings
  static const int _messagePageSize = 50;
  static const int _maxVisibleMessages = 200;
  static const Duration _batchDelay = Duration(milliseconds: 100);
  static const Duration _throttleDelay = Duration(milliseconds: 300);

  // Optimization state
  bool _isInitialized = false;
  int _currentMessagePage = 0;
  bool _isLoadingMoreMessages = false;
  bool _hasMoreMessages = true;

  // Batching and throttling
  Timer? _batchTimer;
  Timer? _throttleTimer;
  final List<VoidCallback> _batchedOperations = [];
  VoidCallback? _throttledOperation;

  // Memory management
  Timer? _memoryCleanupTimer;
  static const Duration _memoryCleanupInterval = Duration(minutes: 5);

  // Message loading optimization
  final ValueNotifier<bool> isLoadingMessages = ValueNotifier<bool>(false);
  final ValueNotifier<List<Message>> visibleMessages =
      ValueNotifier<List<Message>>([]);

  PerformanceEnhancedChatController({
    required super.adapter,
    required super.channelId,
    required super.currentUser,
  }) {
    _initializePerformanceOptimizations();
  }

  void _initializePerformanceOptimizations() {
    // Start memory cleanup timer
    _memoryCleanupTimer = Timer.periodic(_memoryCleanupInterval, (_) {
      _performMemoryCleanup();
    });

    // Listen to message changes and optimize visible messages
    messages.addListener(_updateVisibleMessages);
  }

  /// Initialize with optimized loading
  @override
  void attach() {
    if (_isInitialized) return;

    super.attach();
    _loadInitialMessages();
    _isInitialized = true;
  }

  /// Load initial messages with pagination
  Future<void> _loadInitialMessages() async {
    if (_isLoadingMoreMessages) return;

    _isLoadingMoreMessages = true;
    isLoadingMessages.value = true;

    try {
      // Load first page of messages
      _currentMessagePage = 0;
      await _loadMessagePage(_currentMessagePage);
    } finally {
      _isLoadingMoreMessages = false;
      isLoadingMessages.value = false;
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (_isLoadingMoreMessages || !_hasMoreMessages) return;

    _isLoadingMoreMessages = true;
    isLoadingMessages.value = true;

    try {
      _currentMessagePage++;
      await _loadMessagePage(_currentMessagePage);
    } finally {
      _isLoadingMoreMessages = false;
      isLoadingMessages.value = false;
    }
  }

  /// Load a specific page of messages
  Future<void> _loadMessagePage(int page) async {
    try {
      // In a real implementation, this would call the adapter with pagination
      // For now, we'll simulate the behavior

      final allMessages = messages.value;
      final startIndex = page * _messagePageSize;
      final endIndex = (startIndex + _messagePageSize).clamp(
        0,
        allMessages.length,
      );

      if (startIndex >= allMessages.length) {
        _hasMoreMessages = false;
        return;
      }

      final pageMessages = allMessages.sublist(startIndex, endIndex);

      // Cache messages for performance
      for (final message in pageMessages) {
        _performanceService.cacheMessage(message);
      }

      // Update has more messages flag
      _hasMoreMessages = endIndex < allMessages.length;
    } catch (e) {
      debugPrint('Error loading message page: $e');
    }
  }

  /// Optimized message sending with batching
  @override
  Future<void> sendText(String text) async {
    // Use performance-optimized sending
    await _batchOperation(() => super.sendText(text));
  }

  /// Optimized typing indicator with throttling
  @override
  Future<void> setTyping(bool isTyping) async {
    _throttleOperation(() => super.setTyping(isTyping));
  }

  /// Optimized reaction toggling with batching
  @override
  Future<void> toggleReaction(Message message, String key) async {
    await _batchOperation(() => super.toggleReaction(message, key));
  }

  /// Get optimized message list for UI rendering
  List<Message> getOptimizedMessageList({int? visibleStart, int? visibleEnd}) {
    return _performanceService.getOptimizedMessageList(
      messages.value,
      visibleStart: visibleStart,
      visibleEnd: visibleEnd,
    );
  }

  /// Preload messages around current viewport
  Future<void> preloadAdjacentMessages(List<String> messageIds) async {
    await _performanceService.preloadAdjacentMessages(messageIds, (
      messageId,
    ) async {
      // In a real implementation, this would load from the adapter
      return messages.value.firstWhere(
        (msg) => msg.id.value == messageId,
        orElse: () => throw Exception('Message not found'),
      );
    });
  }

  /// Update visible messages for optimal rendering
  void _updateVisibleMessages() {
    final allMessages = messages.value;

    // Limit visible messages for performance
    if (allMessages.length > _maxVisibleMessages) {
      visibleMessages.value = allMessages.take(_maxVisibleMessages).toList();
    } else {
      visibleMessages.value = allMessages;
    }
  }

  /// Batch multiple operations to reduce UI updates
  Future<void> _batchOperation(VoidCallback operation) async {
    _batchedOperations.add(operation);

    if (_batchTimer != null) {
      _batchTimer!.cancel();
    }

    _batchTimer = Timer(_batchDelay, () {
      _executeBatchedOperations();
    });
  }

  /// Execute all batched operations at once
  void _executeBatchedOperations() {
    if (_batchedOperations.isEmpty) return;

    try {
      for (final operation in _batchedOperations) {
        operation();
      }
    } catch (e) {
      debugPrint('Error executing batched operations: $e');
    } finally {
      _batchedOperations.clear();
      _batchTimer = null;
    }
  }

  /// Throttle operations to prevent excessive calls
  void _throttleOperation(VoidCallback operation) {
    _throttledOperation = operation;

    if (_throttleTimer != null) {
      return; // Already throttling
    }

    _throttleTimer = Timer(_throttleDelay, () {
      if (_throttledOperation != null) {
        try {
          _throttledOperation!();
        } catch (e) {
          debugPrint('Error executing throttled operation: $e');
        } finally {
          _throttledOperation = null;
          _throttleTimer = null;
        }
      }
    });
  }

  /// Perform memory cleanup
  void _performMemoryCleanup() {
    try {
      // Clean up performance service caches
      final stats = _performanceService.getMemoryStats();

      if (stats['usagePercentage'] > 80) {
        // Clear oldest messages from cache
        _performanceService.clearAllCaches();
        debugPrint('ChatController: Performed memory cleanup');
      }

      // Limit visible messages
      if (messages.value.length > _maxVisibleMessages * 2) {
        final limitedMessages = messages.value
            .take(_maxVisibleMessages)
            .toList();
        messages.value = limitedMessages;
        debugPrint(
          'ChatController: Trimmed message list for memory optimization',
        );
      }
    } catch (e) {
      debugPrint('Error during memory cleanup: $e');
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final memoryStats = _performanceService.getMemoryStats();

    return {
      'messageCount': messages.value.length,
      'visibleMessageCount': visibleMessages.value.length,
      'currentPage': _currentMessagePage,
      'hasMoreMessages': _hasMoreMessages,
      'isLoadingMessages': _isLoadingMoreMessages,
      'batchedOperations': _batchedOperations.length,
      'memoryStats': memoryStats,
    };
  }

  /// Force memory optimization
  void optimizeMemory() {
    _performMemoryCleanup();
  }

  /// Preload thread data for better performance
  Future<void> preloadThreadData(List<String> threadIds) async {
    try {
      // Preload thread data in background
      for (final threadId in threadIds) {
        if (!_performanceService.getLazyLoadingState('thread_$threadId')) {
          _performanceService.setLazyLoadingState('thread_$threadId', true);

          // Load thread data asynchronously
          Future.microtask(() async {
            try {
              // In a real implementation, this would load thread data
              await Future.delayed(const Duration(milliseconds: 100));
            } finally {
              _performanceService.setLazyLoadingState(
                'thread_$threadId',
                false,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error preloading thread data: $e');
    }
  }

  /// Optimized thread creation with caching
  @override
  Future<Thread> createThread({
    required Message originalMessage,
    required String title,
    String? description,
    ThreadPriority priority = ThreadPriority.normal,
    ThreadSettings? settings,
    List<String>? additionalParticipantIds,
  }) async {
    // Cache the original message
    _performanceService.cacheMessage(originalMessage);

    return super.createThread(
      originalMessage: originalMessage,
      title: title,
      description: description,
      priority: priority,
      settings: settings,
      additionalParticipantIds: additionalParticipantIds,
    );
  }

  /// Optimized thread message sending with batching
  @override
  Future<ThreadMessage> sendThreadMessage({
    required String threadId,
    required String content,
    String? replyToMessageId,
    ThreadMessageType type = ThreadMessageType.text,
    Map<String, dynamic>? attachmentData,
  }) async {
    late ThreadMessage result;

    await _batchOperation(() async {
      result = await super.sendThreadMessage(
        threadId: threadId,
        content: content,
        replyToMessageId: replyToMessageId,
        type: type,
        attachmentData: attachmentData,
      );
    });

    return result;
  }

  /// Check if should load more messages based on scroll position
  bool shouldLoadMoreMessages(double scrollOffset, double maxScrollExtent) {
    if (!_hasMoreMessages || _isLoadingMoreMessages) return false;

    // Load more when within 20% of the top
    final threshold = maxScrollExtent * 0.8;
    return scrollOffset >= threshold;
  }

  @override
  void dispose() {
    // Cancel timers
    _batchTimer?.cancel();
    _throttleTimer?.cancel();
    _memoryCleanupTimer?.cancel();

    // Clear caches
    _performanceService.clearAllCaches();

    // Dispose additional notifiers
    isLoadingMessages.dispose();
    visibleMessages.dispose();

    super.dispose();
  }
}

/// Performance metrics for monitoring
class ChatPerformanceMetrics {
  final int messageCount;
  final int visibleMessageCount;
  final int cachedMessageCount;
  final int memoryUsageBytes;
  final double memoryUsagePercentage;
  final bool isLoadingMessages;
  final int batchedOperationsCount;

  const ChatPerformanceMetrics({
    required this.messageCount,
    required this.visibleMessageCount,
    required this.cachedMessageCount,
    required this.memoryUsageBytes,
    required this.memoryUsagePercentage,
    required this.isLoadingMessages,
    required this.batchedOperationsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageCount': messageCount,
      'visibleMessageCount': visibleMessageCount,
      'cachedMessageCount': cachedMessageCount,
      'memoryUsageBytes': memoryUsageBytes,
      'memoryUsagePercentage': memoryUsagePercentage,
      'isLoadingMessages': isLoadingMessages,
      'batchedOperationsCount': batchedOperationsCount,
    };
  }
}
