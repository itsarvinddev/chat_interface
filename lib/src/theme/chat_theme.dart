import 'package:flutter/material.dart';

import '../utils/markdown_parser.dart';

/// Professional design tokens for ChatUI
class ChatDesignTokens {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 350);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutQuart;

  // Spacing scale
  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double space2xl = 24.0;
  static const double space3xl = 32.0;

  // Border radius scale
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;

  // Shadow elevations
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 12.0;
}

/// Comprehensive theming for ChatUI with professional design system
class ChatThemeData {
  // Colors
  final Color incomingBubbleColor;
  final Color outgoingBubbleColor;
  final Color incomingTextColor;
  final Color outgoingTextColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color dividerColor;
  final Color timestampColor;
  final Color reactionBackgroundColor;
  final Color reactionTextColor;
  final Color linkColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;

  // Typography
  final TextStyle messageTextStyle;
  final TextStyle timestampTextStyle;
  final TextStyle authorTextStyle;
  final TextStyle systemTextStyle;
  final TextStyle linkTextStyle;
  final TextStyle reactionTextStyle;
  final TextStyle headerTextStyle;
  final TextStyle captionTextStyle;

  // Bubble styling
  final double bubbleRadius;
  final EdgeInsets bubblePadding;
  final EdgeInsets bubbleMargin;
  final double bubbleMaxWidth;
  final BoxShadow? bubbleShadow;

  // Animations
  final Duration messageAnimationDuration;
  final Duration reactionAnimationDuration;
  final Duration typingAnimationDuration;
  final Duration scrollAnimationDuration;
  final Curve animationCurve;

  // Effects
  final bool enableBubbleShadows;
  final bool enableHoverEffects;
  final bool enableRippleEffects;
  final bool enableScaleAnimations;
  final bool enableSlideAnimations;

  // Spacing
  final double messageSpacing;
  final double sectionSpacing;
  final double componentSpacing;

  // Markdown styles
  final MarkdownTextStyles markdownStyles;

  const ChatThemeData({
    required this.incomingBubbleColor,
    required this.outgoingBubbleColor,
    required this.incomingTextColor,
    required this.outgoingTextColor,
    required this.messageTextStyle,
    this.accentColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.surfaceColor = Colors.white,
    this.borderColor = Colors.grey,
    this.dividerColor = Colors.grey,
    this.timestampColor = Colors.grey,
    this.reactionBackgroundColor = Colors.grey,
    this.reactionTextColor = Colors.black,
    this.linkColor = Colors.blue,
    this.errorColor = Colors.red,
    this.successColor = Colors.green,
    this.warningColor = Colors.orange,
    this.timestampTextStyle = const TextStyle(fontSize: 11, color: Colors.grey),
    this.authorTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    this.systemTextStyle = const TextStyle(
      fontSize: 12,
      fontStyle: FontStyle.italic,
    ),
    this.linkTextStyle = const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    this.reactionTextStyle = const TextStyle(fontSize: 12),
    this.headerTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.captionTextStyle = const TextStyle(fontSize: 10, color: Colors.grey),
    this.bubbleRadius = 16,
    this.bubblePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.bubbleMargin = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.bubbleMaxWidth = 0.75,
    this.bubbleShadow,
    this.messageAnimationDuration = const Duration(milliseconds: 250),
    this.reactionAnimationDuration = const Duration(milliseconds: 150),
    this.typingAnimationDuration = const Duration(milliseconds: 300),
    this.scrollAnimationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeInOutCubic,
    this.enableBubbleShadows = true,
    this.enableHoverEffects = true,
    this.enableRippleEffects = true,
    this.enableScaleAnimations = true,
    this.enableSlideAnimations = true,
    this.messageSpacing = 8,
    this.sectionSpacing = 16,
    this.componentSpacing = 12,
    MarkdownTextStyles? markdownStyles,
  }) : markdownStyles = markdownStyles ?? const MarkdownTextStyles();

  /// Create a professional light theme
  factory ChatThemeData.light() {
    const primaryColor = Color(0xFF007AFF);
    const backgroundColor = Color(0xFFF8F9FA);
    const surfaceColor = Colors.white;
    const textColor = Color(0xFF1C1C1E);
    const secondaryTextColor = Color(0xFF8E8E93);

    return ChatThemeData(
      incomingBubbleColor: const Color(0xFFF2F2F7),
      outgoingBubbleColor: primaryColor,
      incomingTextColor: textColor,
      outgoingTextColor: Colors.white,
      messageTextStyle: const TextStyle(
        fontSize: 16,
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      accentColor: primaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      borderColor: const Color(0xFFE5E5EA),
      dividerColor: const Color(0xFFE5E5EA),
      timestampColor: secondaryTextColor,
      reactionBackgroundColor: const Color(0xFFF2F2F7),
      reactionTextColor: textColor,
      linkColor: primaryColor,
      errorColor: const Color(0xFFFF3B30),
      successColor: const Color(0xFF34C759),
      warningColor: const Color(0xFFFF9500),
      timestampTextStyle: TextStyle(
        fontSize: 11,
        color: secondaryTextColor,
        fontWeight: FontWeight.w400,
      ),
      authorTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      systemTextStyle: TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
        color: secondaryTextColor,
      ),
      linkTextStyle: const TextStyle(
        color: primaryColor,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      bubbleShadow: const BoxShadow(
        color: Color(0x08000000),
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
      markdownStyles: MarkdownTextStyles(
        boldStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        italicStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          color: textColor,
        ),
        strikethroughStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          color: textColor.withOpacity(0.7),
        ),
        inlineCodeStyle: const TextStyle(
          fontFamily: 'SF Mono',
          backgroundColor: Color(0xFFF2F2F7),
          color: Color(0xFFAF52DE),
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        codeBlockStyle: const TextStyle(
          fontFamily: 'SF Mono',
          backgroundColor: Color(0xFFF2F2F7),
          color: textColor,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Create a professional dark theme
  factory ChatThemeData.dark() {
    const primaryColor = Color(0xFF0A84FF);
    const backgroundColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF1C1C1E);
    const textColor = Color(0xFFFFFFFF);
    const secondaryTextColor = Color(0xFF8E8E93);

    return ChatThemeData(
      incomingBubbleColor: const Color(0xFF2C2C2E),
      outgoingBubbleColor: primaryColor,
      incomingTextColor: textColor,
      outgoingTextColor: Colors.white,
      messageTextStyle: const TextStyle(
        fontSize: 16,
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      accentColor: primaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      borderColor: const Color(0xFF38383A),
      dividerColor: const Color(0xFF38383A),
      timestampColor: secondaryTextColor,
      reactionBackgroundColor: const Color(0xFF2C2C2E),
      reactionTextColor: textColor,
      linkColor: primaryColor,
      errorColor: const Color(0xFFFF453A),
      successColor: const Color(0xFF32D74B),
      warningColor: const Color(0xFFFF9F0A),
      timestampTextStyle: TextStyle(
        fontSize: 11,
        color: secondaryTextColor,
        fontWeight: FontWeight.w400,
      ),
      authorTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      systemTextStyle: TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
        color: secondaryTextColor,
      ),
      linkTextStyle: const TextStyle(
        color: primaryColor,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      bubbleShadow: const BoxShadow(
        color: Color(0x20000000),
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
      markdownStyles: MarkdownTextStyles(
        boldStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        italicStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          color: textColor,
        ),
        strikethroughStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          color: textColor.withOpacity(0.7),
        ),
        inlineCodeStyle: const TextStyle(
          fontFamily: 'SF Mono',
          backgroundColor: Color(0xFF2C2C2E),
          color: Color(0xFFBF5AF2),
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        codeBlockStyle: const TextStyle(
          fontFamily: 'SF Mono',
          backgroundColor: Color(0xFF2C2C2E),
          color: textColor,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Create theme from Flutter ThemeData with enhanced styling
  factory ChatThemeData.fromTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return ChatThemeData(
      incomingBubbleColor: theme.colorScheme.surfaceContainerHighest,
      outgoingBubbleColor: primaryColor,
      incomingTextColor: onSurfaceColor,
      outgoingTextColor: theme.colorScheme.onPrimary,
      messageTextStyle:
          theme.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            letterSpacing: 0.1,
          ) ??
          const TextStyle(),
      accentColor: primaryColor,
      backgroundColor: theme.colorScheme.surface,
      surfaceColor: surfaceColor,
      borderColor: theme.colorScheme.outline,
      dividerColor: theme.dividerColor,
      timestampColor: theme.colorScheme.onSurface.withOpacity(0.6),
      reactionBackgroundColor: theme.colorScheme.surfaceContainer,
      reactionTextColor: theme.colorScheme.onSurface,
      linkColor: primaryColor,
      errorColor: theme.colorScheme.error,
      successColor: Colors.green,
      warningColor: Colors.orange,
      timestampTextStyle:
          theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ) ??
          const TextStyle(),
      authorTextStyle:
          theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(),
      systemTextStyle:
          theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ) ??
          const TextStyle(),
      linkTextStyle: TextStyle(
        color: primaryColor,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      bubbleShadow: isDark
          ? const BoxShadow(
              color: Color(0x20000000),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            )
          : const BoxShadow(
              color: Color(0x08000000),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
      markdownStyles: MarkdownTextStyles(
        boldStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
        ),
        italicStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: onSurfaceColor,
        ),
        strikethroughStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          color: onSurfaceColor.withOpacity(0.7),
        ),
        inlineCodeStyle: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainer,
          color: theme.colorScheme.primary,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        codeBlockStyle: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainer,
          color: onSurfaceColor,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Copy with modifications
  ChatThemeData copyWith({
    Color? incomingBubbleColor,
    Color? outgoingBubbleColor,
    Color? incomingTextColor,
    Color? outgoingTextColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? borderColor,
    Color? dividerColor,
    Color? timestampColor,
    Color? reactionBackgroundColor,
    Color? reactionTextColor,
    Color? linkColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    TextStyle? messageTextStyle,
    TextStyle? timestampTextStyle,
    TextStyle? authorTextStyle,
    TextStyle? systemTextStyle,
    TextStyle? linkTextStyle,
    TextStyle? reactionTextStyle,
    TextStyle? headerTextStyle,
    TextStyle? captionTextStyle,
    double? bubbleRadius,
    EdgeInsets? bubblePadding,
    EdgeInsets? bubbleMargin,
    double? bubbleMaxWidth,
    BoxShadow? bubbleShadow,
    Duration? messageAnimationDuration,
    Duration? reactionAnimationDuration,
    Duration? typingAnimationDuration,
    Duration? scrollAnimationDuration,
    Curve? animationCurve,
    bool? enableBubbleShadows,
    bool? enableHoverEffects,
    bool? enableRippleEffects,
    bool? enableScaleAnimations,
    bool? enableSlideAnimations,
    double? messageSpacing,
    double? sectionSpacing,
    double? componentSpacing,
    MarkdownTextStyles? markdownStyles,
  }) {
    return ChatThemeData(
      incomingBubbleColor: incomingBubbleColor ?? this.incomingBubbleColor,
      outgoingBubbleColor: outgoingBubbleColor ?? this.outgoingBubbleColor,
      incomingTextColor: incomingTextColor ?? this.incomingTextColor,
      outgoingTextColor: outgoingTextColor ?? this.outgoingTextColor,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      timestampColor: timestampColor ?? this.timestampColor,
      reactionBackgroundColor:
          reactionBackgroundColor ?? this.reactionBackgroundColor,
      reactionTextColor: reactionTextColor ?? this.reactionTextColor,
      linkColor: linkColor ?? this.linkColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      authorTextStyle: authorTextStyle ?? this.authorTextStyle,
      systemTextStyle: systemTextStyle ?? this.systemTextStyle,
      linkTextStyle: linkTextStyle ?? this.linkTextStyle,
      reactionTextStyle: reactionTextStyle ?? this.reactionTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      bubblePadding: bubblePadding ?? this.bubblePadding,
      bubbleMargin: bubbleMargin ?? this.bubbleMargin,
      bubbleMaxWidth: bubbleMaxWidth ?? this.bubbleMaxWidth,
      bubbleShadow: bubbleShadow ?? this.bubbleShadow,
      messageAnimationDuration:
          messageAnimationDuration ?? this.messageAnimationDuration,
      reactionAnimationDuration:
          reactionAnimationDuration ?? this.reactionAnimationDuration,
      typingAnimationDuration:
          typingAnimationDuration ?? this.typingAnimationDuration,
      scrollAnimationDuration:
          scrollAnimationDuration ?? this.scrollAnimationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableBubbleShadows: enableBubbleShadows ?? this.enableBubbleShadows,
      enableHoverEffects: enableHoverEffects ?? this.enableHoverEffects,
      enableRippleEffects: enableRippleEffects ?? this.enableRippleEffects,
      enableScaleAnimations:
          enableScaleAnimations ?? this.enableScaleAnimations,
      enableSlideAnimations:
          enableSlideAnimations ?? this.enableSlideAnimations,
      messageSpacing: messageSpacing ?? this.messageSpacing,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      componentSpacing: componentSpacing ?? this.componentSpacing,
      markdownStyles: markdownStyles ?? this.markdownStyles,
    );
  }
}

class ChatTheme extends InheritedWidget {
  final ChatThemeData data;

  const ChatTheme({super.key, required this.data, required super.child});

  static ChatThemeData of(BuildContext context) {
    final ChatTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<ChatTheme>();
    if (inherited != null) return inherited.data;
    return ChatThemeData.fromTheme(Theme.of(context));
  }

  @override
  bool updateShouldNotify(ChatTheme oldWidget) => data != oldWidget.data;
}
