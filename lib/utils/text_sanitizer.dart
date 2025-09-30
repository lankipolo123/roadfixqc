import 'package:html_unescape/html_unescape.dart';
import 'package:roadfix/constant/image_kit_constant.dart';

class TextSanitizer {
  static final HtmlUnescape _htmlUnescape = HtmlUnescape();

  /// Sanitize text input to prevent script injection and malicious content
  static String sanitize(String input) {
    if (input.isEmpty) return input;

    // Step 1: Trim and limit length
    String sanitized = input.trim();
    if (sanitized.length > ImageKitConstants.maxDescriptionLength) {
      sanitized = sanitized.substring(
        0,
        ImageKitConstants.maxDescriptionLength,
      );
    }

    // Step 2: Remove dangerous patterns
    for (String pattern in ImageKitConstants.forbiddenPatterns) {
      sanitized = sanitized.replaceAll(
        RegExp(pattern, caseSensitive: false),
        '',
      );
    }

    // Step 3: Remove HTML tags completely
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Step 4: Decode HTML entities
    sanitized = _htmlUnescape.convert(sanitized);

    // Step 5: Remove dangerous characters but keep basic punctuation
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}\\]'), '');

    // Step 6: Remove excessive special characters
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\s.,!?-]'), '');

    // Step 7: Clean up multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized.trim();
  }

  /// Validate if text contains suspicious patterns
  static bool containsSuspiciousContent(String input) {
    if (input.isEmpty) return false;

    final lowerInput = input.toLowerCase();

    // Check for forbidden patterns
    for (String pattern in ImageKitConstants.forbiddenPatterns) {
      if (lowerInput.contains(pattern.toLowerCase())) {
        return true;
      }
    }

    // Check for excessive special characters (possible obfuscation)
    final specialCharCount = RegExp(r'[^\w\s.,!?-]').allMatches(input).length;
    final totalLength = input.length;

    if (totalLength > 0 && (specialCharCount / totalLength) > 0.3) {
      return true; // More than 30% special characters is suspicious
    }

    return false;
  }

  /// Get clean version for display (more restrictive)
  static String forDisplay(String input) {
    String cleaned = sanitize(input);

    // Even more restrictive for display
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s.,!?-]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }
}
