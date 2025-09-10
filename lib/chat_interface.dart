library;

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';

import 'chat_interface.dart';
import 'src/utils/storage_paths.dart';

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

export 'src/chat_view.dart';
export 'src/core/controller.dart';
export 'src/core/provider.dart';
export 'src/extensions/extensions.dart';
export 'src/models/chat_user.dart';
export 'src/models/enums.dart';
export 'src/models/message.dart';
export 'src/theme/chat_theme.dart';
export 'src/theme/chat_theme_provider.dart';
export 'src/utils/config.dart';
export 'src/utils/debounce.dart';
export 'src/utils/downloader.dart';
export 'src/utils/duration_mapper.dart';
export 'src/utils/file_picker_utils.dart';
export 'src/utils/markdown_parser.dart';

/// Initialize the ChatInterface package
/// Call this once in your app's main() function
// lib/chat_interface.dart
void initializeChatInterface({bool isDebug = true}) {
  try {
    ChatMessageMapper.ensureInitialized();
    ChatReactionMapper.ensureInitialized();
    ChatReplyMessageMapper.ensureInitialized();
    MapperContainer.globals.use(DurationMapper());
    MapperContainer.globals.use(XFileMapper());
    InitializationChecker.markInitialized();
    DeviceStorage.init();

    if (isDebug) {
      if (kDebugMode) {
        print('✅ ChatInterface initialized successfully');
      }
    }
  } catch (e) {
    throw ChatInterfaceNotInitializedException(
      'Failed to initialize ChatInterface: $e',
    );
  }
}

class InitializationChecker {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static void markInitialized() => _isInitialized = true;

  static void ensureInitialized([String? context]) {
    if (!_isInitialized) {
      final contextMessage = context != null
          ? 'ChatInterface not initialized when trying to $context'
          : 'ChatInterface package not initialized';

      throw ChatInterfaceNotInitializedException(
        contextMessage,
        kDebugMode ? StackTrace.current : null,
      );
    }
  }
}

class ChatInterfaceNotInitializedException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ChatInterfaceNotInitializedException(this.message, [this.stackTrace]);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('❌ ChatInterface Initialization Error');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Problem: $message');
    buffer.writeln();
    buffer.writeln('Solution:');
    buffer.writeln('Add this to your main.dart:');
    buffer.writeln();
    buffer.writeln('import \'package:your_package/chat_interface.dart\';');
    buffer.writeln();
    buffer.writeln('void main() {');
    buffer.writeln('  initializeChatInterface(); // 👈 Add this line');
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
