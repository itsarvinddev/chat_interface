import 'package:flutter/material.dart';

/// Defines the visual properties for chat UI components
class ChatTheme {
  /// Primary color for the chat interface
  final Color primaryColor;

  /// Secondary color for the chat interface
  final Color secondaryColor;

  /// Background color for the chat area
  final Color backgroundColor;

  /// Color filter for background color
  final ColorFilter? colorFilter;

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

  /// Border width for input field
  final double inputBorderWidth;

  /// Color for send button
  final Color sendButtonColor;

  /// Color for attachment buttons
  final Color attachmentButtonColor;

  /// Background color for date labels
  final Color dateLabelBackgroundColor;

  /// Text color for date labels
  final Color dateLabelTextColor;

  /// Text style for sent messages
  final TextStyle sentMessageTextStyle;

  /// Text style for received messages
  final TextStyle receivedMessageTextStyle;

  /// Text style for timestamps
  final TextStyle timestampTextStyle;

  /// Text style for input field
  final TextStyle inputTextStyle;

  /// InputDecoration for input field
  final InputDecoration inputDecoration;

  /// Text style for sender names
  final TextStyle senderNameTextStyle;

  /// Text style for date labels
  final TextStyle dateLabelTextStyle;

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
    required this.colorFilter,
    required this.sentMessageBackgroundColor,
    required this.receivedMessageBackgroundColor,
    required this.sentMessageTextColor,
    required this.receivedMessageTextColor,
    required this.timestampColor,
    required this.inputTextColor,
    required this.inputBackgroundColor,
    required this.inputBorderColor,
    required this.inputBorderWidth,
    required this.sendButtonColor,
    required this.attachmentButtonColor,
    required this.dateLabelBackgroundColor,
    required this.dateLabelTextColor,
    required this.sentMessageTextStyle,
    required this.receivedMessageTextStyle,
    required this.timestampTextStyle,
    required this.inputTextStyle,
    required this.senderNameTextStyle,
    required this.dateLabelTextStyle,
    required this.messageBorderRadius,
    required this.inputBorderRadius,
    required this.messagePadding,
    required this.inputPadding,
    required this.messageElevation,
    required this.inputElevation,
    required this.inputDecoration,
  });

  /// Creates a light theme with default Material Design colors
  factory ChatTheme.light() {
    return ChatTheme(
      primaryColor: Colors.blue,
      secondaryColor: Colors.blue.shade100,
      backgroundColor: Colors.red,
      colorFilter: ColorFilter.mode(Colors.grey.shade300, BlendMode.srcATop),
      sentMessageBackgroundColor: Colors.blue,
      receivedMessageBackgroundColor: Colors.grey.shade200,
      sentMessageTextColor: Colors.white,
      receivedMessageTextColor: Colors.black87,
      timestampColor: Colors.grey.shade600,
      inputTextColor: Colors.black87,
      inputBackgroundColor: Colors.white,
      inputBorderColor: Colors.transparent,
      inputBorderWidth: 0.0,
      sendButtonColor: Colors.blue,
      attachmentButtonColor: Colors.grey.shade600,
      dateLabelBackgroundColor: Colors.grey.shade300,
      dateLabelTextColor: Colors.grey.shade700,
      sentMessageTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
      receivedMessageTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      timestampTextStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      inputTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      senderNameTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
      dateLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
      messageBorderRadius: BorderRadius.circular(12),
      inputBorderRadius: BorderRadius.circular(18),
      messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageElevation: 1,
      inputElevation: 2,
      inputDecoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Message',
      ),
    );
  }

  /// Creates a dark theme with default Material Design colors
  factory ChatTheme.dark() {
    return ChatTheme(
      primaryColor: Colors.blue.shade300,
      secondaryColor: Colors.blue.shade800,
      backgroundColor: Colors.grey.shade900,
      colorFilter: ColorFilter.mode(Colors.grey.shade800, BlendMode.srcATop),
      sentMessageBackgroundColor: Colors.blue.shade700,
      receivedMessageBackgroundColor: Colors.grey.shade800,
      sentMessageTextColor: Colors.white,
      receivedMessageTextColor: Colors.white70,
      timestampColor: Colors.grey.shade400,
      inputTextColor: Colors.white,
      inputBackgroundColor: Colors.grey.shade800,
      inputBorderColor: Colors.transparent,
      inputBorderWidth: 0.0,
      sendButtonColor: Colors.blue.shade300,
      attachmentButtonColor: Colors.grey.shade400,
      dateLabelBackgroundColor: Colors.grey.shade700,
      dateLabelTextColor: Colors.grey.shade300,
      sentMessageTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
      receivedMessageTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      timestampTextStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      inputTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
      senderNameTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade300,
      ),
      dateLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade300,
      ),
      messageBorderRadius: BorderRadius.circular(12),
      inputBorderRadius: BorderRadius.circular(18),
      messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageElevation: 1,
      inputElevation: 2,
      inputDecoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Message',
      ),
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
      colorFilter: ColorFilter.mode(
        colorScheme.surfaceContainerHigh,
        BlendMode.srcATop,
      ),
      sentMessageBackgroundColor: ElevationOverlay.applySurfaceTint(
        colorScheme.inversePrimary,
        colorScheme.surface,
        0,
      ),
      receivedMessageBackgroundColor: ElevationOverlay.applySurfaceTint(
        colorScheme.surfaceBright,
        colorScheme.primary,
        10,
      ),
      sentMessageTextColor: colorScheme.onSurface,
      receivedMessageTextColor: colorScheme.onSurface,
      timestampColor: colorScheme.onSurface.withValues(alpha: 0.7),
      inputTextColor: colorScheme.onSurface,
      inputBackgroundColor: isDark
          ? colorScheme.surfaceContainer
          : colorScheme.surfaceContainerHighest,
      inputBorderColor: Colors.transparent,
      inputBorderWidth: 0.0,
      sendButtonColor: colorScheme.primary,
      attachmentButtonColor: colorScheme.outline,
      dateLabelBackgroundColor: colorScheme.tertiaryContainer,
      dateLabelTextColor: colorScheme.onTertiaryContainer,
      sentMessageTextStyle:
          materialTheme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ) ??
          TextStyle(fontSize: 16, color: colorScheme.onSurface),
      receivedMessageTextStyle:
          materialTheme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ) ??
          TextStyle(fontSize: 16, color: colorScheme.onSurface),
      timestampTextStyle:
          materialTheme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ) ??
          TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
      inputTextStyle:
          materialTheme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ) ??
          TextStyle(fontSize: 16, color: colorScheme.onSurface),
      senderNameTextStyle:
          materialTheme.textTheme.labelMedium?.copyWith(
            color: colorScheme.outline,
            fontWeight: FontWeight.w600,
          ) ??
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.outline,
          ),
      dateLabelTextStyle:
          materialTheme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ) ??
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onTertiaryContainer,
          ),
      messageBorderRadius: BorderRadius.circular(12),
      inputBorderRadius: BorderRadius.circular(18),
      messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageElevation: 1,
      inputElevation: 2,
      inputDecoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Message',
      ),
    );
  }

  /// Creates a copy of this theme with optional overrides
  ChatTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    ColorFilter? colorFilter,
    Color? sentMessageBackgroundColor,
    Color? receivedMessageBackgroundColor,
    Color? sentMessageTextColor,
    Color? receivedMessageTextColor,
    Color? timestampColor,
    Color? inputTextColor,
    Color? inputBackgroundColor,
    Color? inputBorderColor,
    double? inputBorderWidth,
    Color? sendButtonColor,
    Color? attachmentButtonColor,
    Color? dateLabelBackgroundColor,
    Color? dateLabelTextColor,
    TextStyle? sentMessageTextStyle,
    TextStyle? receivedMessageTextStyle,
    TextStyle? timestampTextStyle,
    TextStyle? inputTextStyle,
    TextStyle? senderNameTextStyle,
    TextStyle? dateLabelTextStyle,
    BorderRadius? messageBorderRadius,
    BorderRadius? inputBorderRadius,
    EdgeInsets? messagePadding,
    EdgeInsets? inputPadding,
    double? messageElevation,
    double? inputElevation,
    InputDecoration? inputDecoration,
  }) {
    return ChatTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      colorFilter: colorFilter ?? this.colorFilter,
      sentMessageBackgroundColor:
          sentMessageBackgroundColor ?? this.sentMessageBackgroundColor,
      receivedMessageBackgroundColor:
          receivedMessageBackgroundColor ?? this.receivedMessageBackgroundColor,
      sentMessageTextColor: sentMessageTextColor ?? this.sentMessageTextColor,
      receivedMessageTextColor:
          receivedMessageTextColor ?? this.receivedMessageTextColor,
      timestampColor: timestampColor ?? this.timestampColor,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputBorderWidth: inputBorderWidth ?? this.inputBorderWidth,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      attachmentButtonColor:
          attachmentButtonColor ?? this.attachmentButtonColor,
      dateLabelBackgroundColor:
          dateLabelBackgroundColor ?? this.dateLabelBackgroundColor,
      dateLabelTextColor: dateLabelTextColor ?? this.dateLabelTextColor,
      sentMessageTextStyle: sentMessageTextStyle ?? this.sentMessageTextStyle,
      receivedMessageTextStyle:
          receivedMessageTextStyle ?? this.receivedMessageTextStyle,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      dateLabelTextStyle: dateLabelTextStyle ?? this.dateLabelTextStyle,
      messageBorderRadius: messageBorderRadius ?? this.messageBorderRadius,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      messagePadding: messagePadding ?? this.messagePadding,
      inputPadding: inputPadding ?? this.inputPadding,
      messageElevation: messageElevation ?? this.messageElevation,
      inputElevation: inputElevation ?? this.inputElevation,
      inputDecoration: inputDecoration ?? this.inputDecoration,
    );
  }
}
