// lib/utils/markdown_parser.dart

import 'package:flutter/material.dart';

/// Parses a Markdown-formatted string into a list of [TextSpan] widgets.
///
/// This version uses a recursive approach to correctly handle nested styles.
List<TextSpan> parseMarkdownText(String text, MarkdownTextStyles styles) {
  final List<TextSpan> spans = [];
  // 1. First, handle multi-line code blocks, as they are top-level
  //    and do not contain other formatting.
  final parts = text.split('```');

  for (int i = 0; i < parts.length; i++) {
    String part = parts[i];
    if (i % 2 == 1) {
      // This is a code block (odd-indexed part)
      // Trim leading/trailing newlines for cleaner rendering
      part = part.trim();
      if (part.isNotEmpty) {
        spans.add(
          TextSpan(
            // Wrap in newlines to ensure it behaves like a block
            text: '\n$part\n',
            style: styles.codeBlockStyle,
          ),
        );
      }
    } else {
      // This is regular text that needs inline parsing (even-indexed part)
      if (part.isNotEmpty) {
        spans.addAll(_parseInlineText(part, styles, styles.defaultStyle!));
      }
    }
  }

  return spans;
}

/// Recursively parses inline Markdown elements (`*`, `_`, `~`, `` ` ``).
List<TextSpan> _parseInlineText(
  String text,
  MarkdownTextStyles styles,
  TextStyle currentStyle,
) {
  final List<TextSpan> children = [];
  final pattern = RegExp(r'(`[^`]+`)|(\*[^\*]+\*)|(_[^_]+_)|(~[^~]+~)');

  text.splitMapJoin(
    pattern,
    onMatch: (Match match) {
      final String fullMatch = match.group(0)!;
      final String delimiter = fullMatch[0];
      // Extract content without the delimiters
      final String content = fullMatch.substring(1, fullMatch.length - 1);

      TextStyle newStyle;
      switch (delimiter) {
        case '`':
          newStyle = currentStyle.merge(styles.inlineCodeStyle);
          // Inline code does not support nesting, so we add it directly.
          children.add(TextSpan(text: content, style: newStyle));
          break;
        case '*':
          newStyle = currentStyle.merge(styles.boldStyle);
          // Recursively parse the content for further styles
          children.addAll(_parseInlineText(content, styles, newStyle));
          break;
        case '_':
          newStyle = currentStyle.merge(styles.italicStyle);
          children.addAll(_parseInlineText(content, styles, newStyle));
          break;
        case '~':
          newStyle = currentStyle.merge(styles.strikethroughStyle);
          children.addAll(_parseInlineText(content, styles, newStyle));
          break;
      }
      return '';
    },
    onNonMatch: (String nonMatch) {
      if (nonMatch.isNotEmpty) {
        children.add(TextSpan(text: nonMatch, style: currentStyle));
      }
      return '';
    },
  );

  return children;
}

/// A widget to display parsed Markdown text.
/// Reuses the same parsing logic for consistency.
class MarkdownText extends StatelessWidget {
  final String text;
  final MarkdownTextStyles styles;

  const MarkdownText({super.key, required this.text, required this.styles});

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =
        styles.defaultStyle ?? DefaultTextStyle.of(context).style;

    final effectiveStyles = MarkdownTextStyles(
      defaultStyle: defaultTextStyle,
      boldStyle: defaultTextStyle.merge(styles.boldStyle),
      italicStyle: defaultTextStyle.merge(styles.italicStyle),
      strikethroughStyle: defaultTextStyle.merge(styles.strikethroughStyle),
      inlineCodeStyle: defaultTextStyle.merge(styles.inlineCodeStyle),
      codeBlockStyle: defaultTextStyle.merge(styles.codeBlockStyle),
    );

    return RichText(
      text: TextSpan(
        style: defaultTextStyle,
        children: parseMarkdownText(text, effectiveStyles),
      ),
      softWrap: true,
      textWidthBasis: TextWidthBasis.longestLine,
    );
  }
}

class MarkdownTextStyles {
  final TextStyle? defaultStyle;
  final TextStyle boldStyle;
  final TextStyle italicStyle;
  final TextStyle strikethroughStyle;
  final TextStyle inlineCodeStyle;
  final TextStyle codeBlockStyle;

  MarkdownTextStyles({
    this.defaultStyle,
    this.boldStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.italicStyle = const TextStyle(fontStyle: FontStyle.italic),
    this.strikethroughStyle = const TextStyle(
      decoration: TextDecoration.lineThrough,
    ),
    this.inlineCodeStyle = const TextStyle(
      fontFamily: 'monospace',
      backgroundColor: Colors.white24,
      letterSpacing: 0.8,
    ),
    this.codeBlockStyle = const TextStyle(
      fontFamily: 'monospace',
      backgroundColor: Color(0xFF212121),
      color: Color(0xFFFAFAFA),
    ),
  });
}

class MarkdownTextEditingController extends TextEditingController {
  final MarkdownTextStyles styles;

  MarkdownTextEditingController({super.text, required this.styles});

  List<TextSpan> _buildSpans(
    String text, {
    required TextStyle currentStyle,
    required TextStyle syntaxStyle,
  }) {
    final List<TextSpan> children = [];
    final pattern = RegExp(r'(`[^`]+`)|(\*[^\*]+\*)|(_[^_]+_)|(~[^~]+~)');

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final String fullMatch = match.group(0)!;
        final String delimiter = fullMatch[0];
        final String content = fullMatch.substring(1, fullMatch.length - 1);

        TextStyle newStyle;
        switch (delimiter) {
          case '`':
            newStyle = currentStyle.merge(styles.inlineCodeStyle);
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            children.add(TextSpan(text: content, style: newStyle));
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            break;
          case '*':
            newStyle = currentStyle.merge(styles.boldStyle);
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            children.addAll(
              _buildSpans(
                content,
                currentStyle: newStyle,
                syntaxStyle: syntaxStyle,
              ),
            );
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            break;
          case '_':
            newStyle = currentStyle.merge(styles.italicStyle);
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            children.addAll(
              _buildSpans(
                content,
                currentStyle: newStyle,
                syntaxStyle: syntaxStyle,
              ),
            );
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            break;
          case '~':
            newStyle = currentStyle.merge(styles.strikethroughStyle);
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            children.addAll(
              _buildSpans(
                content,
                currentStyle: newStyle,
                syntaxStyle: syntaxStyle,
              ),
            );
            children.add(TextSpan(text: delimiter, style: syntaxStyle));
            break;
        }
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          children.add(TextSpan(text: nonMatch, style: currentStyle));
        }
        return '';
      },
    );

    return children;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ?? const TextStyle();

    final syntaxStyle = defaultStyle.copyWith(
      color: defaultStyle.color?.withValues(alpha: 0.6),
    );

    final List<TextSpan> children = [];

    // ✅ Do NOT insert/remove characters, just style them
    final pattern = RegExp(r'```([\s\S]*?)```');
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        //  final fullMatch = match.group(0)!; // includes ```
        final inner = match.group(1)!;

        // Render exactly as typed: ```inner```
        children.add(TextSpan(text: '```', style: syntaxStyle));
        children.add(TextSpan(text: inner, style: styles.codeBlockStyle));
        children.add(TextSpan(text: '```', style: syntaxStyle));
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          children.addAll(
            _buildSpans(
              nonMatch,
              currentStyle: defaultStyle,
              syntaxStyle: syntaxStyle,
            ),
          );
        }
        return '';
      },
    );

    return TextSpan(style: defaultStyle, children: children);
  }
}
