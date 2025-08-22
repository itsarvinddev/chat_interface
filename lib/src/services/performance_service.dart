// Performance optimization service for ChatUI
// Provides caching, memory management, and lazy loading capabilities

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/models.dart';

/// Performance optimization service for chat functionality
class PerformanceService {
  static const int _maxCacheSize = 1000;
  static const int _maxImageCacheSize = 100;
  static const Duration _cacheExpiry = Duration(hours: 1);

  // Message caching
  final LRUMap<String, Message> _messageCache = LRUMap<String, Message>(
    _maxCacheSize,
  );
  final Map<String, DateTime> _messageCacheTimestamps = {};

  // Image caching
  final LRUMap<String, Uint8List> _imageCache = LRUMap<String, Uint8List>(
    _maxImageCacheSize,
  );
  final Map<String, DateTime> _imageCacheTimestamps = {};

  // User data caching
  final LRUMap<String, ChatUser> _userCache = LRUMap<String, ChatUser>(500);
  final Map<String, DateTime> _userCacheTimestamps = {};

  // Memory usage tracking
  int _currentMemoryUsage = 0;
  static const int _maxMemoryUsage = 50 * 1024 * 1024; // 50MB

  // Lazy loading state
  final Map<String, bool> _lazyLoadingStates = {};
  final Map<String, Timer> _cleanupTimers = {};

  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  /// Cache a message with automatic cleanup
  void cacheMessage(Message message) {
    try {
      final key = message.id.value;
      _messageCache[key] = message;
      _messageCacheTimestamps[key] = DateTime.now();

      // Estimate memory usage
      final estimatedSize = _estimateMessageSize(message);
      _currentMemoryUsage += estimatedSize;

      // Cleanup if memory usage is too high
      if (_currentMemoryUsage > _maxMemoryUsage) {
        _cleanupMemory();
      }

      // Set cleanup timer
      _setCleanupTimer(key, _cacheExpiry);
    } catch (e) {
      debugPrint('Error caching message: $e');
    }
  }

  /// Get cached message
  Message? getCachedMessage(String messageId) {
    try {
      final timestamp = _messageCacheTimestamps[messageId];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _messageCache[messageId];
      } else {
        // Remove expired entry
        removeCachedMessage(messageId);
        return null;
      }
    } catch (e) {
      debugPrint('Error getting cached message: $e');
      return null;
    }
  }

  /// Remove cached message
  void removeCachedMessage(String messageId) {
    try {
      final message = _messageCache.remove(messageId);
      _messageCacheTimestamps.remove(messageId);
      _cleanupTimers[messageId]?.cancel();
      _cleanupTimers.remove(messageId);

      if (message != null) {
        final estimatedSize = _estimateMessageSize(message);
        _currentMemoryUsage -= estimatedSize;
      }
    } catch (e) {
      debugPrint('Error removing cached message: $e');
    }
  }

  /// Cache image data
  void cacheImage(String url, Uint8List imageData) {
    try {
      _imageCache[url] = imageData;
      _imageCacheTimestamps[url] = DateTime.now();

      _currentMemoryUsage += imageData.length;

      if (_currentMemoryUsage > _maxMemoryUsage) {
        _cleanupMemory();
      }

      _setCleanupTimer(url, _cacheExpiry);
    } catch (e) {
      debugPrint('Error caching image: $e');
    }
  }

  /// Get cached image
  Uint8List? getCachedImage(String url) {
    try {
      final timestamp = _imageCacheTimestamps[url];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _imageCache[url];
      } else {
        removeCachedImage(url);
        return null;
      }
    } catch (e) {
      debugPrint('Error getting cached image: $e');
      return null;
    }
  }

  /// Remove cached image
  void removeCachedImage(String url) {
    try {
      final imageData = _imageCache.remove(url);
      _imageCacheTimestamps.remove(url);
      _cleanupTimers[url]?.cancel();
      _cleanupTimers.remove(url);

      if (imageData != null) {
        _currentMemoryUsage -= imageData.length;
      }
    } catch (e) {
      debugPrint('Error removing cached image: $e');
    }
  }

  /// Cache user data
  void cacheUser(ChatUser user) {
    try {
      final key = user.id.value;
      _userCache[key] = user;
      _userCacheTimestamps[key] = DateTime.now();
    } catch (e) {
      debugPrint('Error caching user: $e');
    }
  }

  /// Get cached user
  ChatUser? getCachedUser(String userId) {
    try {
      final timestamp = _userCacheTimestamps[userId];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _userCache[userId];
      } else {
        _userCache.remove(userId);
        _userCacheTimestamps.remove(userId);
        return null;
      }
    } catch (e) {
      debugPrint('Error getting cached user: $e');
      return null;
    }
  }

  /// Set lazy loading state
  void setLazyLoadingState(String key, bool isLoading) {
    _lazyLoadingStates[key] = isLoading;
  }

  /// Get lazy loading state
  bool getLazyLoadingState(String key) {
    return _lazyLoadingStates[key] ?? false;
  }

  /// Create optimized message list for rendering
  List<Message> getOptimizedMessageList(
    List<Message> allMessages, {
    int? visibleStart,
    int? visibleEnd,
    int bufferSize = 10,
  }) {
    try {
      if (visibleStart == null || visibleEnd == null) {
        return allMessages;
      }

      final start = (visibleStart - bufferSize).clamp(0, allMessages.length);
      final end = (visibleEnd + bufferSize).clamp(0, allMessages.length);

      return allMessages.sublist(start, end);
    } catch (e) {
      debugPrint('Error creating optimized message list: $e');
      return allMessages;
    }
  }

  /// Preload adjacent messages for smooth scrolling
  Future<void> preloadAdjacentMessages(
    List<String> messageIds,
    Future<Message> Function(String) messageLoader,
  ) async {
    try {
      final futures = messageIds.map((id) async {
        if (!_messageCache.containsKey(id)) {
          final message = await messageLoader(id);
          cacheMessage(message);
        }
      });

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Error preloading messages: $e');
    }
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    return {
      'currentUsage': _currentMemoryUsage,
      'maxUsage': _maxMemoryUsage,
      'usagePercentage': (_currentMemoryUsage / _maxMemoryUsage * 100).round(),
      'messagesCached': _messageCache.length,
      'imagesCached': _imageCache.length,
      'usersCached': _userCache.length,
    };
  }

  /// Force cleanup of all caches
  void clearAllCaches() {
    try {
      _messageCache.clear();
      _messageCacheTimestamps.clear();
      _imageCache.clear();
      _imageCacheTimestamps.clear();
      _userCache.clear();
      _userCacheTimestamps.clear();

      // Cancel all cleanup timers
      for (final timer in _cleanupTimers.values) {
        timer.cancel();
      }
      _cleanupTimers.clear();

      _currentMemoryUsage = 0;
      _lazyLoadingStates.clear();
    } catch (e) {
      debugPrint('Error clearing caches: $e');
    }
  }

  /// Cleanup expired entries and manage memory
  void _cleanupMemory() {
    try {
      final now = DateTime.now();

      // Clean up expired messages
      final expiredMessageKeys = _messageCacheTimestamps.entries
          .where((entry) => now.difference(entry.value) > _cacheExpiry)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredMessageKeys) {
        removeCachedMessage(key);
      }

      // Clean up expired images
      final expiredImageKeys = _imageCacheTimestamps.entries
          .where((entry) => now.difference(entry.value) > _cacheExpiry)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredImageKeys) {
        removeCachedImage(key);
      }

      // If still over limit, remove oldest entries
      if (_currentMemoryUsage > _maxMemoryUsage) {
        _removeOldestEntries();
      }
    } catch (e) {
      debugPrint('Error during memory cleanup: $e');
    }
  }

  /// Remove oldest cache entries
  void _removeOldestEntries() {
    try {
      // Sort by timestamp and remove oldest
      final sortedMessages = _messageCacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final sortedImages = _imageCacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      // Remove oldest messages first
      for (final entry in sortedMessages) {
        if (_currentMemoryUsage <= _maxMemoryUsage * 0.8) break;
        removeCachedMessage(entry.key);
      }

      // Remove oldest images if still needed
      for (final entry in sortedImages) {
        if (_currentMemoryUsage <= _maxMemoryUsage * 0.8) break;
        removeCachedImage(entry.key);
      }
    } catch (e) {
      debugPrint('Error removing oldest entries: $e');
    }
  }

  /// Set cleanup timer for cache entry
  void _setCleanupTimer(String key, Duration delay) {
    _cleanupTimers[key]?.cancel();
    _cleanupTimers[key] = Timer(delay, () {
      if (_messageCache.containsKey(key)) {
        removeCachedMessage(key);
      }
      if (_imageCache.containsKey(key)) {
        removeCachedImage(key);
      }
    });
  }

  /// Estimate memory usage of a message
  int _estimateMessageSize(Message message) {
    try {
      int size = 0;

      // Text content
      if (message.text != null) {
        size += message.text!.length * 2; // UTF-16 encoding
      }

      // Attachments
      for (final attachment in message.attachments) {
        size += attachment.sizeBytes ?? 1024; // Default 1KB if unknown
      }

      // Base object overhead
      size += 1024; // Estimated object overhead

      return size;
    } catch (e) {
      debugPrint('Error estimating message size: $e');
      return 1024; // Default size
    }
  }
}

/// Optimized LRU (Least Recently Used) cache implementation
class LRUMap<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  LRUMap(this._maxSize);

  V? operator [](K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  void operator []=(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= _maxSize) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  V? remove(K key) => _map.remove(key);

  bool containsKey(K key) => _map.containsKey(key);

  int get length => _map.length;

  void clear() => _map.clear();

  Iterable<K> get keys => _map.keys;
  Iterable<V> get values => _map.values;
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  Timer? _monitoringTimer;
  final PerformanceService _performanceService = PerformanceService();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final stats = _performanceService.getMemoryStats();
      debugPrint('ChatUI Performance Stats: $stats');

      // Auto-cleanup if memory usage is high
      if (stats['usagePercentage'] > 80) {
        _performanceService.clearAllCaches();
        debugPrint('ChatUI: Auto-cleanup triggered due to high memory usage');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
