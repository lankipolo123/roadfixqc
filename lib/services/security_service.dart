import 'dart:io';
import 'package:roadfix/models/security_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html_unescape/html_unescape.dart';
// Import the models file

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Direct constants for immediate use
  static const int _maxFileSize = 25 * 1024 * 1024; // 25MB
  static const int _minFileSize = 100 * 1024; // 100KB
  static const int _cooldownMinutes = 5;
  static const int _maxReportsPerDay = 10;
  static const int _maxDescriptionLength = 500;
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationMinutes = 30;
  static const int _failedAttemptResetHours = 1;
  static const List<String> _forbiddenPatterns = [
    '<script',
    '</script>',
    'javascript:',
    'onclick=',
    'onerror=',
    'onload=',
    'eval(',
    'document.',
    'window.',
    'alert(',
  ];

  // Config object for external access
  static const SecurityConfig _config = SecurityConfig(
    maxFileSize: _maxFileSize,
    minFileSize: _minFileSize,
    cooldownMinutes: _cooldownMinutes,
    maxReportsPerDay: _maxReportsPerDay,
    maxDescriptionLength: _maxDescriptionLength,
    maxFailedAttempts: _maxFailedAttempts,
    lockoutDurationMinutes: _lockoutDurationMinutes,
    failedAttemptResetHours: _failedAttemptResetHours,
    forbiddenPatterns: _forbiddenPatterns,
  );

  static final HtmlUnescape _htmlUnescape = HtmlUnescape();

  /// Main validation method - checks everything at once
  Future<SecurityResult> validateReport({
    required File imageFile,
    required String description,
    required String location,
  }) async {
    // 0. Check for brute force lockout first
    final bruteForceResult = await _checkBruteForce();
    if (!bruteForceResult.isValid) return bruteForceResult;

    // 1. File validation
    final fileResult = await _validateFile(imageFile);
    if (!fileResult.isValid) {
      await _recordFailedAttempt();
      return fileResult;
    }

    // 2. Text validation
    final textResult = _validateText(description, location);
    if (!textResult.isValid) {
      await _recordFailedAttempt();
      return textResult;
    }

    // 3. Spam check
    final spamResult = await _checkSpam(location, description);
    if (!spamResult.isValid) {
      await _recordFailedAttempt();
      return spamResult;
    }

    // If all validations pass, reset failed attempts
    await _resetFailedAttempts();

    return SecurityResult.success(
      cleanDescription: _sanitizeText(description),
      cleanLocation: _sanitizeText(location),
      metadata: {
        'validationTimestamp': DateTime.now().toIso8601String(),
        'fileSize': await imageFile.length(),
      },
    );
  }

  /// Record successful submission for spam tracking
  Future<void> recordSubmission(String location, String description) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Update last report time
    await prefs.setInt('last_report_time', now.millisecondsSinceEpoch);

    // Update daily count
    final today = _getDateString(now);
    final lastDate = prefs.getString('last_report_date');

    if (lastDate == today) {
      final count = prefs.getInt('daily_count') ?? 0;
      await prefs.setInt('daily_count', count + 1);
    } else {
      await prefs.setString('last_report_date', today);
      await prefs.setInt('daily_count', 1);
    }
  }

  /// Get current brute force status
  Future<BruteForceData> getBruteForceStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return BruteForceData.fromPrefs(
      failedAttempts: prefs.getInt('failed_attempts') ?? 0,
      lastFailedAttemptMs: prefs.getInt('last_failed_attempt') ?? 0,
      lockoutTimeMs: prefs.getInt('lockout_time') ?? 0,
      lockoutDurationMinutes: _lockoutDurationMinutes,
    );
  }

  /// Get current spam tracking status
  Future<SpamTrackingData> getSpamTrackingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final lastReportTimeMs = prefs.getInt('last_report_time') ?? 0;
    final lastReportDate = prefs.getString('last_report_date');
    final dailyCount = prefs.getInt('daily_count') ?? 0;

    // Calculate remaining cooldown
    final timeDiff = now.millisecondsSinceEpoch - lastReportTimeMs;
    const cooldownMs = _cooldownMinutes * 60 * 1000;
    final remainingCooldown = timeDiff < cooldownMs
        ? ((cooldownMs - timeDiff) / 60000).ceil()
        : 0;

    // Check daily limit
    final today = _getDateString(now);
    final hasReachedLimit =
        lastReportDate == today && dailyCount >= _maxReportsPerDay;

    return SpamTrackingData(
      lastReportTime: lastReportTimeMs > 0
          ? DateTime.fromMillisecondsSinceEpoch(lastReportTimeMs)
          : null,
      lastReportDate: lastReportDate,
      dailyCount: lastReportDate == today ? dailyCount : 0,
      remainingCooldownMinutes: remainingCooldown,
      hasReachedDailyLimit: hasReachedLimit,
    );
  }

  /// Check if account is locked due to brute force attempts
  Future<bool> isLockedOut() async {
    final status = await getBruteForceStatus();
    return status.isLocked;
  }

  /// Get remaining lockout time in minutes
  Future<int> getRemainingLockoutMinutes() async {
    final status = await getBruteForceStatus();
    return status.remainingLockoutMinutes;
  }

  /// Get security configuration
  SecurityConfig get config => _config;

  // Private helper methods
  Future<SecurityResult> _validateFile(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        return SecurityResult.failure(
          message: 'Image file not found',
          failureType: SecurityFailureType.fileNotFound,
          severity: SecuritySeverity.medium,
        );
      }

      final fileSize = await imageFile.length();
      final fileData = FileValidationData.fromFile(
        exists: true,
        sizeBytes: fileSize,
        maxSizeBytes: _maxFileSize,
        minSizeBytes: _minFileSize,
      );

      if (!fileData.isValidSize) {
        final failureType = fileSize > _maxFileSize
            ? SecurityFailureType.fileTooLarge
            : SecurityFailureType.fileTooSmall;

        return SecurityResult.failure(
          message: fileData.errorMessage!,
          failureType: failureType,
          severity: SecuritySeverity.low,
          metadata: fileData.toJson(),
        );
      }

      return SecurityResult.success(
        message: 'File valid',
        metadata: fileData.toJson(),
      );
    } catch (e) {
      return SecurityResult.failure(
        message: 'File validation error: $e',
        failureType: SecurityFailureType.fileCorrupted,
        severity: SecuritySeverity.medium,
        metadata: {'error': e.toString()},
      );
    }
  }

  SecurityResult _validateText(String description, String location) {
    if (description.trim().isEmpty) {
      return SecurityResult.failure(
        message: 'Description is required',
        failureType: SecurityFailureType.descriptionEmpty,
        severity: SecuritySeverity.low,
      );
    }

    if (location.trim().isEmpty) {
      return SecurityResult.failure(
        message: 'Location is required',
        failureType: SecurityFailureType.locationEmpty,
        severity: SecuritySeverity.low,
      );
    }

    if (description.length > _maxDescriptionLength) {
      return SecurityResult.failure(
        message: 'Description too long (max $_maxDescriptionLength characters)',
        failureType: SecurityFailureType.descriptionTooLong,
        severity: SecuritySeverity.low,
        metadata: {
          'currentLength': description.length,
          'maxLength': _maxDescriptionLength,
        },
      );
    }

    // Check for suspicious content
    final lowerDesc = description.toLowerCase();
    for (String pattern in _forbiddenPatterns) {
      if (lowerDesc.contains(pattern.toLowerCase())) {
        return SecurityResult.failure(
          message: 'Description contains suspicious content',
          failureType: SecurityFailureType.suspiciousContent,
          severity: SecuritySeverity.high,
          metadata: {'detectedPattern': pattern},
        );
      }
    }

    // Check if cleaned text is meaningful
    final cleanDesc = _sanitizeText(description);
    if (cleanDesc.length < 10) {
      return SecurityResult.failure(
        message: 'Description too short or invalid',
        failureType: SecurityFailureType.descriptionTooShort,
        severity: SecuritySeverity.low,
        metadata: {
          'cleanedLength': cleanDesc.length,
          'originalLength': description.length,
        },
      );
    }

    return SecurityResult.success(message: 'Text valid');
  }

  Future<SecurityResult> _checkSpam(String location, String description) async {
    final spamData = await getSpamTrackingStatus();

    // Time cooldown check
    if (spamData.remainingCooldownMinutes > 0) {
      return SecurityResult.spam(
        cooldownMinutes: spamData.remainingCooldownMinutes,
        metadata: spamData.toJson(),
      );
    }

    // Daily limit check
    if (spamData.hasReachedDailyLimit) {
      return SecurityResult.failure(
        message: 'Daily report limit ($_maxReportsPerDay) reached',
        failureType: SecurityFailureType.dailyLimitReached,
        severity: SecuritySeverity.medium,
        metadata: spamData.toJson(),
      );
    }

    return SecurityResult.success(message: 'Spam check passed');
  }

  /// Check for brute force attempts and lockout
  Future<SecurityResult> _checkBruteForce() async {
    final bruteForceData = await getBruteForceStatus();

    if (bruteForceData.isLocked) {
      return SecurityResult.locked(
        remainingMinutes: bruteForceData.remainingLockoutMinutes,
        metadata: bruteForceData.toJson(),
      );
    }

    // Check if failed attempts should be reset (after configured hours of no activity)
    if (bruteForceData.lastFailedAttempt != null) {
      final timeSinceLastFailed = DateTime.now().difference(
        bruteForceData.lastFailedAttempt!,
      );
      const resetDuration = Duration(hours: _failedAttemptResetHours);

      if (timeSinceLastFailed > resetDuration) {
        await _resetFailedAttempts();
      }
    }

    return SecurityResult.success(message: 'Brute force check passed');
  }

  /// Record a failed validation attempt
  Future<void> _recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final currentFailedAttempts = prefs.getInt('failed_attempts') ?? 0;
    final newFailedAttempts = currentFailedAttempts + 1;

    await prefs.setInt('failed_attempts', newFailedAttempts);
    await prefs.setInt('last_failed_attempt', now.millisecondsSinceEpoch);

    // If max attempts reached, initiate lockout
    if (newFailedAttempts >= _maxFailedAttempts) {
      await prefs.setInt('lockout_time', now.millisecondsSinceEpoch);
    }
  }

  /// Reset failed attempts counter
  Future<void> _resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('failed_attempts');
    await prefs.remove('last_failed_attempt');
  }

  String _sanitizeText(String input) {
    if (input.isEmpty) return input;

    String clean = input.trim();

    // Limit length
    if (clean.length > _maxDescriptionLength) {
      clean = clean.substring(0, _maxDescriptionLength);
    }

    // Remove dangerous patterns (escaped properly)
    for (String pattern in _forbiddenPatterns) {
      clean = clean.replaceAll(
        RegExp(RegExp.escape(pattern), caseSensitive: false),
        '',
      );
    }

    // Remove HTML tags
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    clean = _htmlUnescape.convert(clean);

    // Remove dangerous characters
    clean = clean.replaceAll(RegExp(r'[<>{}\\]'), '');

    // Clean up spaces
    clean = clean.replaceAll(RegExp(r'\s+'), ' ');

    return clean.trim();
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
