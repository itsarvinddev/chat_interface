library;

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';

import 'chatui.dart';

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

export 'src/chat_view.dart';
export 'src/core/controller.dart';
export 'src/extensions/extensions.dart';
export 'src/models/chat_user.dart';
export 'src/models/enums.dart';
export 'src/models/message.dart';
export 'src/utils/debounce.dart';
export 'src/utils/downloader.dart';
export 'src/utils/duration_mapper.dart';
export 'src/utils/markdown_parser.dart';

/// Initialize the ChatUI package
/// Call this once in your app's main() function
// lib/chatui.dart
void initializeChatUI({bool isDebug = true}) {
  try {
    ChatMessageMapper.ensureInitialized();
    ChatReactionMapper.ensureInitialized();
    ChatReplyMessageMapper.ensureInitialized();
    MapperContainer.globals.use(DurationMapper());
    MapperContainer.globals.use(XFileMapper());
    InitializationChecker.markInitialized();

    if (isDebug) {
      if (kDebugMode) {
        print('✅ ChatUI initialized successfully');
      }
    }
  } catch (e) {
    throw ChatUINotInitializedException('Failed to initialize ChatUI: $e');
  }
}

class InitializationChecker {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static void markInitialized() => _isInitialized = true;

  static void ensureInitialized([String? context]) {
    if (!_isInitialized) {
      final contextMessage = context != null
          ? 'ChatUI not initialized when trying to $context'
          : 'ChatUI package not initialized';

      throw ChatUINotInitializedException(
        contextMessage,
        kDebugMode ? StackTrace.current : null,
      );
    }
  }
}

class ChatUINotInitializedException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ChatUINotInitializedException(this.message, [this.stackTrace]);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('❌ ChatUI Initialization Error');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Problem: $message');
    buffer.writeln();
    buffer.writeln('Solution:');
    buffer.writeln('Add this to your main.dart:');
    buffer.writeln();
    buffer.writeln('import \'package:your_package/chatui.dart\';');
    buffer.writeln();
    buffer.writeln('void main() {');
    buffer.writeln('  initializeChatUI(); // 👈 Add this line');
    buffer.writeln('  runApp(MyApp());');
    buffer.writeln('}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (kDebugMode && stackTrace != null) {
      buffer.writeln('Stack trace:');
      buffer.writeln(stackTrace.toString());
    }

    return buffer.toString();
  }
}
