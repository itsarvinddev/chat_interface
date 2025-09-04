import 'package:flutter/material.dart';

/// Defines the visual properties for chat UI components
class ChatTheme {
  /// Primary color for the chat interface
  final Color primaryColor;
  
  /// Secondary color for the chat interface
  final Color secondaryColor;
  
  /// Background color for the chat area
  final Color backgroundColor;
  
  /// Background color for sent messages (user's messages)
  final Color sentMessageBackgroundColor;
  
  /// Background color for received messages (other users' messages)
  final Color receivedMessageBackgroundColor;
  
  /// Text color for sent messages
  final Color sentMessageTextColor;
  
  /// Text color for received messages
  final Color receivedMessageTextColor;
  
  /// Color for message timestamps
  final Color timestampColor;
  
  /// Color for input field text
  final Color inputTextColor;
  
  /// Background color for input field
  final Color inputBackgroundColor;
  
  /// Border color for input field
  final Color inputBorderColor;
  
  /// Color for send button
  final Color sendButtonColor;
  
  /// Color for attachment buttons
  final Color attachmentButtonColor;
  
  /// Text style for sent messages
  final TextStyle sentMessageTextStyle;
  
  /// Text style for received messages
  final TextStyle receivedMessageTextStyle;
  
  /// Text style for timestamps
  final TextStyle timestampTextStyle;
  
  /// Text style for input field
  final TextStyle inputTextStyle;
  
  /// Border radius for message bubbles
  final BorderRadius messageBorderRadius;
  
  /// Border radius for input field
  final BorderRadius inputBorderRadius;
  
  /// Padding for message bubbles
  final EdgeInsets messagePadding;
  
  /// Padding for input container
  final EdgeInsets inputPadding;
  
  /// Elevation for message bubbles
  final double messageElevation;
  
  /// Elevation for input container
  final double inputElevation;

  const ChatTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.sentMessageBackgroundColor,
    required this.receivedMessageBackgroundColor,
    required this.sentMessageTextColor,
    required this.receivedMessageTextColor,
    required this.timestampColor,
    required this.inputTextColor,
    required this.inputBackgroundColor,
    required this.inputBorderColor,
    required this.sendButtonColor,
    required this.attachmentButtonColor,
    required this.sentMessageTextStyle,
    required this.receivedMessageTextStyle,
    required this.timestampTextStyle,
    required this.inputTextStyle,
    required this.messageBorderRadius,
    required this.inputBorderRadius,
    required this.messagePadding,
    required this.inputPadding,
    required this.messageElevation,
    required this.inputElevation,
  });

  /// Creates a light theme with default Material Design colors
  factory ChatTheme.light() {
    return ChatTheme(
      primaryColor: Colors.blue,
      secondaryColor: Colors.blue.shade100,
      backgroundColor: Colors.grey.shade50,
      sentMessageBackgroundColor: Colors.blue,
      receivedMessageBackgroundColor: Colors.grey.shade200,
      sentMessageTextColor: Colors.white,
      receivedMessageTextColor: Colors.black87,
      timestampColor: Colors.grey.shade600,
      inputTextColor: Colors.black87,
      inputBackgroundColor: Colors.white,
      inputBorderColor: Colors.grey.shade300,
      sendButtonColor: Colors.blue,
      attachmentButtonColor: Colors.grey.shade600,
      sentMessageTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      receivedMessageTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      timestampTextStyle: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
      inputTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      messageBorderRadius: BorderRadius.circular(18),
      inputBorderRadius: BorderRadius.circular(25),
      messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageElevation: 1,
      inputElevation: 2,
    );
  }

  /// Creates a dark theme with default Material Design colors
  factory ChatTheme.dark() {
    return ChatTheme(
      primaryColor: Colors.blue.shade300,
      secondaryColor: Colors.blue.shade800,
      backgroundColor: Colors.grey.shade900,
      sentMessageBackgroundColor: Colors.blue.shade700,
      receivedMessageBackgroundColor: Colors.grey.shade800,
      sentMessageTextColor: Colors.white,
      receivedMessageTextColor: Colors.white70,
      timestampColor: Colors.grey.shade400,
      inputTextColor: Colors.white,
      inputBackgroundColor: Colors.grey.shade800,
      inputBorderColor: Colors.grey.shade600,
      sendButtonColor: Colors.blue.shade300,
      attachmentButtonColor: Colors.grey.shade400,
      sentMessageTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      receivedMessageTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      timestampTextStyle: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade400,
      ),
      inputTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      messageBorderRadius: BorderRadius.circular(18),
      inputBorderRadius: BorderRadius.circular(25),
      messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageElevation: 1,
      inputElevation: 2,
    );
  }

  /// Creates a theme based on the current Flutter ThemeData
  factory ChatTheme.fromMaterialTheme(ThemeData materialTheme) {
    final colorScheme = materialTheme.colorScheme;
    final isDark = materialTheme.brightness == Brightness.dark;
    
    return ChatTheme(
      primaryColor: colorScheme.primary,
      secondaryColor: colorScheme.secondary,
      backgroundColor: colorScheme.surface,
      sentMessageBackgroundColor: colorScheme.primary,
      receivedMessageBackgroundColor: isDark 
          ? colorScheme.surfaceVariant 
          : colorScheme.surfaceVariant,
      sentMessageTextColor: colorScheme.onPrimary,
      receivedMessageTextColor: colorScheme.onSurfaceVariant,
      timestampColor: colorScheme.outline,
      inputTextColor: colorScheme.onSurface,
      inputBackgroundColor: colorScheme.surface,
      inputBorderColor: colorScheme.outline,
      sendButtonColor: colorScheme.primary,
      attachmentButtonColor: colorScheme.outline,
      sentMessageTextStyle: materialTheme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimary,
      ) ?? TextStyle(fontSize: 16, color: colorScheme.onPrimary),
      receivedMessageTextStyle: materialTheme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ) ?? TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
      timestampTextStyle: materialTheme.textTheme.bodySmall?.copyWith(
        color: colorScheme.outline,
      ) ?? TextStyle(fontSize: 12, color: colorScheme.outline),
      inputTextStyle: materialTheme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ) ?? TextStyle(fontSize: 16, color: colorScheme.onSurface),
      messageBorderRadius: BorderRadius.circular(18),
      inputBorderRadius: BorderRadius.circular(25),
      messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageElevation: 1,
      inputElevation: 2,
    );
  }

  /// Creates a copy of this theme with optional overrides
  ChatTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? sentMessageBackgroundColor,
    Color? receivedMessageBackgroundColor,
    Color? sentMessageTextColor,
    Color? receivedMessageTextColor,
    Color? timestampColor,
    Color? inputTextColor,
    Color? inputBackgroundColor,
    Color? inputBorderColor,
    Color? sendButtonColor,
    Color? attachmentButtonColor,
    TextStyle? sentMessageTextStyle,
    TextStyle? receivedMessageTextStyle,
    TextStyle? timestampTextStyle,
    TextStyle? inputTextStyle,
    BorderRadius? messageBorderRadius,
    BorderRadius? inputBorderRadius,
    EdgeInsets? messagePadding,
    EdgeInsets? inputPadding,
    double? messageElevation,
    double? inputElevation,
  }) {
    return ChatTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      sentMessageBackgroundColor: sentMessageBackgroundColor ?? this.sentMessageBackgroundColor,
      receivedMessageBackgroundColor: receivedMessageBackgroundColor ?? this.receivedMessageBackgroundColor,
      sentMessageTextColor: sentMessageTextColor ?? this.sentMessageTextColor,
      receivedMessageTextColor: receivedMessageTextColor ?? this.receivedMessageTextColor,
      timestampColor: timestampColor ?? this.timestampColor,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      attachmentButtonColor: attachmentButtonColor ?? this.attachmentButtonColor,
      sentMessageTextStyle: sentMessageTextStyle ?? this.sentMessageTextStyle,
      receivedMessageTextStyle: receivedMessageTextStyle ?? this.receivedMessageTextStyle,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      messageBorderRadius: messageBorderRadius ?? this.messageBorderRadius,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      messagePadding: messagePadding ?? this.messagePadding,
      inputPadding: inputPadding ?? this.inputPadding,
      messageElevation: messageElevation ?? this.messageElevation,
      inputElevation: inputElevation ?? this.inputElevation,
    );
  }
}