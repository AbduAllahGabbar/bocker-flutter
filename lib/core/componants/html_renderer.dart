import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HtmlRenderer
// A lightweight Flutter-native HTML renderer.
// Supports: h1–h4, p, strong/b, em/i, a (link), br, hr, div (auto-detected),
//           span (transparent passthrough). Handles both clean EN HTML and
//           div-heavy AR HTML structures.
// ─────────────────────────────────────────────────────────────────────────────

class HtmlRenderer extends StatelessWidget {
  final String html;
  final bool isRtl;

  const HtmlRenderer({super.key, required this.html, this.isRtl = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final blocks = _HtmlParser.parse(html);

    return Column(
      crossAxisAlignment:  CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          _buildBlock(theme, primary, onSurface, block),
      ],
    );
  }

  Widget _buildBlock(
    ThemeData theme,
    Color primary,
    Color onSurface,
    _Block block,
  ) {
    final dir = isRtl ? TextDirection.rtl : TextDirection.ltr;

    switch (block.type) {
      // ── Headings ────────────────────────────────────────────────────────
      case _BType.h1:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Text(
            block.plainText,
            textDirection: dir,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 25.h,
              color: onSurface,
              height: 1.3,
            ),
          ),
        );

      case _BType.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            block.plainText,
            textDirection: dir,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: onSurface,
              height: 1.3,
              fontSize: 20.h,
            ),
          ),
        );

      case _BType.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(
            block.plainText,
            textDirection: dir,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18.h,
              color: onSurface,
            ),
          ),
        );

      case _BType.h4:
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            block.plainText,
            textDirection: dir,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
        );

      // ── Horizontal rule ─────────────────────────────────────────────────
      case _BType.hr:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(thickness: 1),
        );

      // ── Paragraph / div text ─────────────────────────────────────────────
      case _BType.p:
      default:
        final spans = _InlineParser.parse(block.rawHtml, primary);
        if (spans.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RichText(
            textDirection: dir,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.82),
                height: 1.75,
                fontSize: 14.h,
              ),
              children: spans,
            ),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Block model
// ─────────────────────────────────────────────────────────────────────────────

enum _BType { h1, h2, h3, h4, p, hr }

class _Block {
  final _BType type;
  final String rawHtml; // inner HTML (for inline parsing)
  final String plainText; // stripped text (used for headings)

  const _Block({required this.type, required this.rawHtml, this.plainText = ''});
}

// ─────────────────────────────────────────────────────────────────────────────
// Block-level parser
// ─────────────────────────────────────────────────────────────────────────────

class _HtmlParser {
  static List<_Block> parse(String html) {
    final blocks = <_Block>[];

    // Collapse excessive whitespace (keep single spaces / newlines)
    final cleaned = html
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    // ── Step 1: extract explicit block elements (h1-h4, p, hr) ────────────
    final blockPattern = RegExp(
      r'<(h[1-4]|p)([^>]*)>([\s\S]*?)<\/\1>|<hr[^>]*\/?>',
      caseSensitive: false,
    );

    int lastEnd = 0;
    for (final match in blockPattern.allMatches(cleaned)) {
      // Text / divs BETWEEN block elements → scan for div-wrapped content
      final between = cleaned.substring(lastEnd, match.start);
      _extractDivContent(between, blocks);

      final tagName = match.group(1)?.toLowerCase();
      final innerHtml = match.group(3) ?? '';

      if (tagName == null) {
        // <hr>
        blocks.add(const _Block(type: _BType.hr, rawHtml: ''));
      } else {
        final type = _tagToType(tagName);
        final plain = _stripTags(innerHtml);
        if (plain.trim().isNotEmpty) {
          blocks.add(_Block(type: type, rawHtml: innerHtml, plainText: plain));
        }
      }
      lastEnd = match.end;
    }

    // ── Step 2: content after the last known block (AR div-heavy HTML) ─────
    final remaining = cleaned.substring(lastEnd);
    _extractDivContent(remaining, blocks);

    return blocks;
  }

  /// Recursively finds leaf `<div>` nodes (those that contain no child divs)
  /// and treats them as paragraphs. Also handles heading-marked divs.
  static void _extractDivContent(String html, List<_Block> blocks) {
    if (html.trim().isEmpty) return;

    // Detect divs with "heading" in their class (Arabic heading pattern)
    final headingDivPattern = RegExp(
      r'<div[^>]*class="[^"]*heading[^"]*"[^>]*>\s*<div[^>]*>([\s\S]*?)<\/div>\s*<\/div>',
      caseSensitive: false,
    );

    // Track ranges consumed by heading matches so we don't double-process them
    final headingRanges = <(int, int)>[];
    for (final m in headingDivPattern.allMatches(html)) {
      final inner = m.group(1) ?? '';
      final text = _stripTags(inner).trim();
      if (text.isNotEmpty) {
        blocks.add(_Block(type: _BType.h2, rawHtml: inner, plainText: text));
        headingRanges.add((m.start, m.end));
      }
    }

    // Leaf divs: divs that don't contain any child <div
    final leafPattern = RegExp(
      r'<div([^>]*)>((?![\s\S]*?<div)[\s\S]*?)<\/div>',
      caseSensitive: false,
    );

    for (final m in leafPattern.allMatches(html)) {
      // Skip if already consumed as a heading
      if (headingRanges.any((r) => m.start >= r.$1 && m.end <= r.$2)) continue;

      final attrs = m.group(1) ?? '';
      final innerHtml = m.group(2) ?? '';
      final text = _stripTags(innerHtml).trim();
      if (text.isEmpty) continue;

      // Check for horizontal-rule class
      if (attrs.contains('horizontal-rule')) {
        blocks.add(const _Block(type: _BType.hr, rawHtml: ''));
        continue;
      }

      blocks.add(_Block(type: _BType.p, rawHtml: innerHtml, plainText: text));
    }
  }

  static _BType _tagToType(String tag) {
    switch (tag) {
      case 'h1': return _BType.h1;
      case 'h2': return _BType.h2;
      case 'h3': return _BType.h3;
      case 'h4': return _BType.h4;
      default:   return _BType.p;
    }
  }

  static String _stripTags(String html) => html
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', '\u00a0')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .trim();
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline parser — converts HTML inner content to a list of InlineSpan
// ─────────────────────────────────────────────────────────────────────────────

class _InlineParser {
  static List<InlineSpan> parse(String rawHtml, Color linkColor) {
    final spans = <InlineSpan>[];

    // Normalize <br> → newline marker; </p> → newline
    final html = rawHtml
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\/p>', caseSensitive: false), '\n');

    int pos = 0;
    while (pos < html.length) {
      if (html[pos] != '<') {
        // Plain text token
        final next = html.indexOf('<', pos);
        final chunk = next == -1 ? html.substring(pos) : html.substring(pos, next);
        final text = _decodeEntities(chunk);
        if (text.isNotEmpty) spans.add(TextSpan(text: text));
        pos = next == -1 ? html.length : next;
      } else {
        // Tag token — find closing >
        final closePos = html.indexOf('>', pos);
        if (closePos == -1) { pos++; continue; }

        final tag = html.substring(pos, closePos + 1);
        final tagNameMatch = RegExp(r'^<\/?([a-zA-Z][a-zA-Z0-9]*)').firstMatch(tag);
        final tagName = tagNameMatch?.group(1)?.toLowerCase() ?? '';

        // Skip closing tags — their text is handled when opening tag is found
        if (tag.startsWith('</')) { pos = closePos + 1; continue; }

        switch (tagName) {
          case 'strong':
          case 'b':
            pos = _consumeInlineTag(html, pos, closePos, tagName, spans, (text) =>
              TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w700)));
            break;

          case 'em':
          case 'i':
            pos = _consumeInlineTag(html, pos, closePos, tagName, spans, (text) =>
              TextSpan(text: text, style: const TextStyle(fontStyle: FontStyle.italic)));
            break;

          case 'a':
            pos = _consumeInlineTag(html, pos, closePos, 'a', spans, (text) =>
              TextSpan(
                text: text,
                style: TextStyle(
                  color: linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                ),
              ));
            break;

          default:
            // Transparent tags (span, div, etc.) — skip the tag, keep inner text
            pos = closePos + 1;
        }
      }
    }

    // Remove leading/trailing empty spans
    while (spans.isNotEmpty && (spans.first as TextSpan?)?.text?.trim().isEmpty == true) {
      spans.removeAt(0);
    }

    return spans;
  }

  /// Finds the matching close tag, extracts inner text, creates a styled span.
  static int _consumeInlineTag(
    String html,
    int tagStart,
    int openClose, // position of the `>` closing the opening tag
    String tagName,
    List<InlineSpan> spans,
    InlineSpan Function(String plainText) builder,
  ) {
    final closeTag = '</$tagName>';
    final closeIdx = html.toLowerCase().indexOf(closeTag, openClose + 1);
    if (closeIdx == -1) return openClose + 1; // unclosed tag → skip

    final inner = html.substring(openClose + 1, closeIdx);
    // Strip nested tags and decode entities
    final text = _decodeEntities(inner.replaceAll(RegExp(r'<[^>]+>'), ''));
    if (text.isNotEmpty) spans.add(builder(text));

    return closeIdx + closeTag.length;
  }

  static String _decodeEntities(String text) => text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', '\u00a0')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}
