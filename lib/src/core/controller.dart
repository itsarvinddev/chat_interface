import 'dart:async';

import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:screwdriver/screwdriver.dart';

/// Controller for managing chat state, messages, and scrolling.
class ChatController {
  ChatController({
    required this.scrollController,
    required List<ChatUser> otherUsers,
    required this.currentUser,
    required this.pagingController,
    MarkdownTextEditingController? textController,
    this.focusNode,
  }) : _otherUsers = {for (final user in otherUsers) user.id: user},
       messageController =
           textController ??
           MarkdownTextEditingController(styles: MarkdownTextStyles());

  /// Focus node for the message input field
  final FocusNode? focusNode;

  /// Scroll controller for chat list view.
  final ScrollController scrollController;

  /// Current logged-in user.
  final ChatUser currentUser;

  /// Paging controller for infinite scroll messages.
  final PagingController<int, ChatMessage> pagingController;

  /// Internal map of other users for quick lookup.
  final Map<String, ChatUser> _otherUsers;

  /// Text controller for composing messages.
  late final MarkdownTextEditingController messageController;

  /// Callback when a message is marked as seen.
  Future<void> Function(ChatMessage message)? onMarkAsSeen;

  /// Callback when a new message is added.
  Future<void> Function(ChatMessage message)? onMessageAdded;

  /// Callback when a message is updated.
  Future<void> Function(ChatMessage message)? onMessageUpdated;

  /// Callback when tap on camera button.
  Future<void> Function()? onTapCamera;

  /// Callback when tap on attach file button.
  Future<void> Function()? onTapAttachFile;

  /// Exposes other users as an unmodifiable list.
  UnmodifiableListView<ChatUser> get otherUsers =>
      UnmodifiableListView(_otherUsers.values);

  /// Returns the current list of messages.
  List<ChatMessage> get messages {
    if (pagingController.items != null) {
      return pagingController.items ?? [];
    }
    if (pagingController.pages != null) {
      return pagingController.pages!.expand((page) => page).toList();
    }
    return [];
  }

  /// Adds a new message to the top of the first page.
  Future<void> addMessage(ChatMessage message) async {
    try {
      messageController.clear();
      final pages = List<List<ChatMessage>>.from(pagingController.pages!);
      pages.first = [message, ...pages.first];
      pagingController.value = pagingController.value.copyWith(pages: pages);
      await onMessageAdded?.call(message);
    } catch (e, stack) {
      debugPrint('Error adding message: $e\n$stack');
    }
  }

  /// Updates an existing message by ID.
  Future<void> updateMessage(ChatMessage message) async {
    try {
      pagingController.mapItems(
        (item) => item.id == message.id
            ? item.copyWith(chatStatus: message.chatStatus)
            : item,
      );
      await onMessageUpdated?.call(message);
    } catch (e, stack) {
      debugPrint('Error updating message: $e\n$stack');
    }
  }

  /// Scrolls to the last (oldest) message in the chat.
  Future<void> scrollToLastMessage({
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    Timer(delay, () async {
      if (!scrollController.hasClients) return;
      await scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 320),
      );
    });
  }

  /// Checks if a message was sent by the current user.
  bool isMessageBySelf(ChatMessage message) =>
      message.senderId == currentUser.id;

  /// Determines if a message should display a tail (last in a sequence).
  bool tailForIndex(int index) {
    final items = messages;
    if (index < 0 || index >= items.length) return true;

    final msg = items[index];
    final next = index + 1 < items.length ? items[index + 1] : null;
    return next == null ||
        next.senderId != msg.senderId ||
        next.type == ChatMessageType.action;
  }

  /// Room object for the chat.
  late Object? _room;

  /// Sets the room object for the chat.
  void setRoom(Object? room) {
    _room = room;
  }

  /// Gets the room object for the chat.
  Object? getRoom() {
    return _room;
  }

  /// Typed room getter for convenience.
  T? getRoomAs<T>() => _room is T ? _room as T : null;

  /// Disposes resources safely.
  void dispose() {
    if (scrollController.hasClients) {
      scrollController.dispose();
    }
    pagingController.dispose();
    messageController.dispose();
    focusNode?.dispose();
  }
}


/* 
/// Configuration for ChatController behavior and performance tuning
class ChatControllerConfig {
  const ChatControllerConfig({
    this.scrollAnimationDuration = const Duration(milliseconds: 320),
    this.scrollAnimationCurve = Curves.easeOutCubic,
    this.scrollDelayDuration = const Duration(milliseconds: 100),
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.enableDebugLogging = kDebugMode,
    this.autoScrollThreshold = 50.0,
    this.messageValidationEnabled = true,
  });

  final Duration scrollAnimationDuration;
  final Curve scrollAnimationCurve;
  final Duration scrollDelayDuration;
  final int maxRetryAttempts;
  final Duration retryDelay;
  final bool enableDebugLogging;
  final double autoScrollThreshold;
  final bool messageValidationEnabled;
}

/// Exception thrown when ChatController operations fail
class ChatControllerException implements Exception {
  const ChatControllerException(this.message, [this.originalError]);
  
  final String message;
  final Object? originalError;
  
  @override
  String toString() => 'ChatControllerException: $message';
}

/// Controller for managing chat state, messages, and scrolling with enhanced reliability
class ChatController with ChangeNotifier {
  ChatController({
    required this.scrollController,
    required List<ChatUser> otherUsers,
    required this.currentUser,
    required this.pagingController,
    MarkdownTextEditingController? textController,
    this.config = const ChatControllerConfig(),
  }) : _otherUsers = {for (final user in otherUsers) user.id: user},
       messageController = textController ??
           MarkdownTextEditingController(styles: MarkdownTextStyles()) {
    _initialize();
  }

  /// Configuration for controller behavior
  final ChatControllerConfig config;

  /// Scroll controller for chat list view
  final ScrollController scrollController;

  /// Current logged-in user
  final ChatUser currentUser;

  /// Paging controller for infinite scroll messages
  final PagingController<int, ChatMessage> pagingController;

  /// Internal map of other users for quick lookup
  final Map<String, ChatUser> _otherUsers;

  /// Text controller for composing messages
  late final MarkdownTextEditingController messageController;

  // State management
  bool _isDisposed = false;
  bool _isInitialized = false;
  Timer? _scrollTimer;
  StreamSubscription? _pagingSubscription;
  
  // Operation tracking for reliability
  final Set<String> _pendingOperations = <String>{};
  int _operationCounter = 0;

  /// Callback when a message is marked as seen
  Function(ChatMessage message)? onMarkAsSeen;

  /// Callback when a new message is added
  Function(ChatMessage message)? onMessageAdded;

  /// Callback when a message is updated
  Function(ChatMessage message)? onMessageUpdated;

  /// Callback for error handling
  Function(ChatControllerException error)? onError;

  /// Callback for operation completion
  Function(String operationId, bool success)? onOperationComplete;

  /// Getters with safety checks
  
  /// Exposes other users as an unmodifiable list
  UnmodifiableListView<ChatUser> get otherUsers {
    _ensureNotDisposed();
    return UnmodifiableListView(_otherUsers.values);
  }

  /// Returns the current list of messages with null safety
  List<ChatMessage> get messages {
    _ensureNotDisposed();
    
    try {
      // First try items (most common case)
      final items = pagingController.items;
      if (items != null) {
        return List.unmodifiable(items);
      }
      
      // Fallback to pages expansion
      final pages = pagingController.pages;
      if (pages != null && pages.isNotEmpty) {
        return List.unmodifiable(pages.expand((page) => page).toList());
      }
      
      return const <ChatMessage>[];
    } catch (e) {
      _handleError('Failed to get messages', e);
      return const <ChatMessage>[];
    }
  }

  /// Check if controller is disposed
  bool get isDisposed => _isDisposed;

  /// Check if there are pending operations
  bool get hasPendingOperations => _pendingOperations.isNotEmpty;

  /// Get count of messages
  int get messageCount => messages.length;

  /// Check if messages exist
  bool get hasMessages => messageCount > 0;

  // Initialization
  void _initialize() {
    if (_isInitialized) return;
    
    try {
      // Set up listeners
      _pagingSubscription = pagingController.addListener(_onPagingControllerChanged) as StreamSubscription?;
      
      _isInitialized = true;
      _log('ChatController initialized successfully');
    } catch (e) {
      _handleError('Failed to initialize ChatController', e);
    }
  }

  void _onPagingControllerChanged() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Enhanced message addition with comprehensive error handling
  Future<bool> addMessage(ChatMessage message) async {
    final operationId = _generateOperationId('addMessage');
    
    try {
      _ensureNotDisposed();
      _addPendingOperation(operationId);

      // Validate message if enabled
      if (config.messageValidationEnabled && !_validateMessage(message)) {
        throw ChatControllerException('Invalid message: missing required fields');
      }

      // Ensure pages exist
      final pages = _getOrCreatePages();
      
      // Add message to first page
      pages.first = [message, ...pages.first];
      
      // Update paging controller safely
      await _updatePagingController(pages);
      
      // Trigger callback
      onMessageAdded?.call(message);
      
      _log('Message added successfully: ${message.id}');
      _completeOperation(operationId, true);
      return true;

    } catch (e) {
      _handleError('Failed to add message', e);
      _completeOperation(operationId, false);
      return false;
    } finally {
      _removePendingOperation(operationId);
    }
  }

  /// Batch message addition for better performance
  Future<bool> addMessages(List<ChatMessage> messagesToAdd) async {
    final operationId = _generateOperationId('addMessages');
    
    try {
      _ensureNotDisposed();
      _addPendingOperation(operationId);

      if (messagesToAdd.isEmpty) return true;

      // Validate messages if enabled
      if (config.messageValidationEnabled) {
        final invalidMessages = messagesToAdd.where((msg) => !_validateMessage(msg)).toList();
        if (invalidMessages.isNotEmpty) {
          throw ChatControllerException('Invalid messages found: ${invalidMessages.length}');
        }
      }

      final pages = _getOrCreatePages();
      pages.first = [...messagesToAdd, ...pages.first];
      
      await _updatePagingController(pages);
      
      // Trigger callbacks for each message
      for (final message in messagesToAdd) {
        onMessageAdded?.call(message);
      }
      
      _log('${messagesToAdd.length} messages added successfully');
      _completeOperation(operationId, true);
      return true;

    } catch (e) {
      _handleError('Failed to add messages', e);
      _completeOperation(operationId, false);
      return false;
    } finally {
      _removePendingOperation(operationId);
    }
  }

  /// Enhanced message update with retry logic
  Future<bool> updateMessage(ChatMessage message) async {
    final operationId = _generateOperationId('updateMessage');
    
    try {
      _ensureNotDisposed();
      _addPendingOperation(operationId);

      if (config.messageValidationEnabled && !_validateMessage(message)) {
        throw ChatControllerException('Invalid message for update');
      }

      bool updated = false;
      await _executeWithRetry(() async {
        pagingController.mapItems((item) {
          if (item.id == message.id) {
            updated = true;
            return message;
          }
          return item;
        });
      });

      if (updated) {
        onMessageUpdated?.call(message);
        _log('Message updated successfully: ${message.id}');
      } else {
        _log('Message not found for update: ${message.id}');
      }

      _completeOperation(operationId, updated);
      return updated;

    } catch (e) {
      _handleError('Failed to update message', e);
      _completeOperation(operationId, false);
      return false;
    } finally {
      _removePendingOperation(operationId);
    }
  }

  /// Enhanced scrolling with better safety checks and cancellation
  Future<void> scrollToLastMessage({
    Duration? delay,
    bool animated = true,
  }) async {
    try {
      _ensureNotDisposed();
      
      final effectiveDelay = delay ?? config.scrollDelayDuration;
      
      // Cancel any existing scroll operation
      _scrollTimer?.cancel();
      
      _scrollTimer = Timer(effectiveDelay, () async {
        await _performScroll(animated);
      });
      
    } catch (e) {
      _handleError('Failed to schedule scroll', e);
    }
  }

  Future<void> _performScroll(bool animated) async {
    try {
      if (_isDisposed || !scrollController.hasClients) return;

      final position = scrollController.position;
      if (!position.hasContentDimensions) return;

      if (animated) {
        await scrollController.animateTo(
          position.minScrollExtent,
          curve: config.scrollAnimationCurve,
          duration: config.scrollAnimationDuration,
        );
      } else {
        scrollController.jumpTo(position.minScrollExtent);
      }
      
      _log('Scroll completed successfully');
    } catch (e) {
      _handleError('Scroll operation failed', e);
    }
  }

  /// User management methods
  bool addUser(ChatUser user) {
    try {
      _ensureNotDisposed();
      
      if (_otherUsers.containsKey(user.id)) {
        _log('User already exists: ${user.id}');
        return false;
      }
      
      _otherUsers[user.id] = user;
      notifyListeners();
      _log('User added: ${user.id}');
      return true;
    } catch (e) {
      _handleError('Failed to add user', e);
      return false;
    }
  }

  bool removeUser(String userId) {
    try {
      _ensureNotDisposed();
      
      final removed = _otherUsers.remove(userId);
      if (removed != null) {
        notifyListeners();
        _log('User removed: $userId');
        return true;
      }
      return false;
    } catch (e) {
      _handleError('Failed to remove user', e);
      return false;
    }
  }

  ChatUser? getUser(String userId) {
    try {
      _ensureNotDisposed();
      return _otherUsers[userId];
    } catch (e) {
      _handleError('Failed to get user', e);
      return null;
    }
  }

  /// Message utility methods with safety checks
  
  bool isMessageBySelf(ChatMessage message) {
    try {
      _ensureNotDisposed();
      return message.senderId == currentUser.id;
    } catch (e) {
      _handleError('Failed to check message sender', e);
      return false;
    }
  }

  bool tailForIndex(int index) {
    try {
      _ensureNotDisposed();
      
      final items = messages;
      if (index < 0 || index >= items.length) return true;

      final msg = items[index];
      final next = index + 1 < items.length ? items[index + 1] : null;
      return next == null || next.senderId != msg.senderId;
    } catch (e) {
      _handleError('Failed to calculate tail for index', e);
      return true;
    }
  }

  /// Search functionality
  List<ChatMessage> searchMessages(String query) {
    try {
      _ensureNotDisposed();
      
      if (query.trim().isEmpty) return const <ChatMessage>[];
      
      final lowerQuery = query.toLowerCase();
      return messages.where((message) =>
        message.message.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      _handleError('Failed to search messages', e);
      return const <ChatMessage>[];
    }
  }

  /// Mark message as seen with enhanced safety
  Future<void> markMessageAsSeen(ChatMessage message) async {
    try {
      _ensureNotDisposed();
      
      if (message.senderId == currentUser.id) return;
      
      onMarkAsSeen?.call(message);
      _log('Message marked as seen: ${message.id}');
    } catch (e) {
      _handleError('Failed to mark message as seen', e);
    }
  }

  // Private helper methods

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw ChatControllerException('ChatController has been disposed');
    }
  }

  bool _validateMessage(ChatMessage message) {
    return message.id.isNotEmpty && 
           message.senderId.isNotEmpty && 
           message.message.isNotEmpty;
  }

  List<List<ChatMessage>> _getOrCreatePages() {
    final existingPages = pagingController.pages;
    if (existingPages != null && existingPages.isNotEmpty) {
      return List<List<ChatMessage>>.from(existingPages);
    }
    return [<ChatMessage>[]];
  }

  Future<void> _updatePagingController(List<List<ChatMessage>> pages) async {
    await _executeWithRetry(() async {
      pagingController.value = pagingController.value.copyWith(pages: pages);
      notifyListeners();
    });
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    
    while (attempts < config.maxRetryAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= config.maxRetryAttempts) rethrow;
        
        _log('Operation failed, retrying... (attempt $attempts/${config.maxRetryAttempts})');
        await Future.delayed(config.retryDelay);
      }
    }
    
    throw ChatControllerException('Operation failed after ${config.maxRetryAttempts} attempts');
  }

  String _generateOperationId(String operation) {
    return '${operation}_${++_operationCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _addPendingOperation(String operationId) {
    _pendingOperations.add(operationId);
  }

  void _removePendingOperation(String operationId) {
    _pendingOperations.remove(operationId);
  }

  void _completeOperation(String operationId, bool success) {
    onOperationComplete?.call(operationId, success);
  }

  void _handleError(String message, Object? error) {
    final exception = ChatControllerException(message, error);
    _log('Error: $message - $error');
    onError?.call(exception);
  }

  void _log(String message) {
    if (config.enableDebugLogging) {
      debugPrint('[ChatController] $message');
    }
  }

  /// Enhanced disposal with comprehensive cleanup
  @override
  void dispose() {
    if (_isDisposed) return;
    
    _log('Disposing ChatController...');
    _isDisposed = true;

    // Cancel any pending operations
    _scrollTimer?.cancel();
    _scrollTimer = null;
    
    // Cancel subscriptions
    _pagingSubscription?.cancel();
    _pagingSubscription = null;

    // Clear pending operations
    _pendingOperations.clear();

    // Dispose controllers safely
    try {
      if (scrollController.hasClients) {
        scrollController.dispose();
      }
    } catch (e) {
      _log('Error disposing scroll controller: $e');
    }

    try {
      pagingController.dispose();
    } catch (e) {
      _log('Error disposing paging controller: $e');
    }

    try {
      messageController.dispose();
    } catch (e) {
      _log('Error disposing message controller: $e');
    }

    // Clear maps
    _otherUsers.clear();

    _log('ChatController disposed successfully');
    super.dispose();
  }
} */