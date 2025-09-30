/// Security-related data models and enums
library security_models;

/// Enum for different types of security validation failures
enum SecurityFailureType {
  fileNotFound,
  fileTooLarge,
  fileTooSmall,
  fileCorrupted,
  descriptionEmpty,
  descriptionTooLong,
  descriptionTooShort,
  locationEmpty,
  suspiciousContent,
  spamCooldown,
  dailyLimitReached,
  bruteForceDetected,
  accountLocked,
  invalidInput,
  unknown,
}

/// Enum for security validation severity levels
enum SecuritySeverity {
  low, // Minor issues, user can retry immediately
  medium, // Moderate issues, short wait required
  high, // Serious issues, longer wait or manual review
  critical, // Account compromised, immediate lockout
}

/// Main result class for security validation
class SecurityResult {
  final bool isValid;
  final String message;
  final String? cleanDescription;
  final String? cleanLocation;
  final SecurityFailureType? failureType;
  final SecuritySeverity severity;
  final Map<String, dynamic>? metadata;

  const SecurityResult({
    required this.isValid,
    required this.message,
    this.cleanDescription,
    this.cleanLocation,
    this.failureType,
    this.severity = SecuritySeverity.low,
    this.metadata,
  });

  /// Factory constructor for successful validation
  factory SecurityResult.success({
    String message = 'Validation passed',
    String? cleanDescription,
    String? cleanLocation,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityResult(
      isValid: true,
      message: message,
      cleanDescription: cleanDescription,
      cleanLocation: cleanLocation,
      metadata: metadata,
    );
  }

  /// Factory constructor for validation failure
  factory SecurityResult.failure({
    required String message,
    required SecurityFailureType failureType,
    SecuritySeverity severity = SecuritySeverity.medium,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityResult(
      isValid: false,
      message: message,
      failureType: failureType,
      severity: severity,
      metadata: metadata,
    );
  }

  /// Factory constructor for brute force lockout
  factory SecurityResult.locked({
    required int remainingMinutes,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityResult(
      isValid: false,
      message:
          'Account locked due to multiple failed attempts. Try again in $remainingMinutes minutes.',
      failureType: SecurityFailureType.accountLocked,
      severity: SecuritySeverity.critical,
      metadata: {'remainingMinutes': remainingMinutes, ...?metadata},
    );
  }

  /// Factory constructor for spam detection
  factory SecurityResult.spam({
    required int cooldownMinutes,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityResult(
      isValid: false,
      message:
          'Please wait $cooldownMinutes minutes before submitting another report',
      failureType: SecurityFailureType.spamCooldown,
      severity: SecuritySeverity.medium,
      metadata: {'cooldownMinutes': cooldownMinutes, ...?metadata},
    );
  }

  /// Check if this is a temporary failure (user can retry later)
  bool get isTemporaryFailure {
    return failureType == SecurityFailureType.spamCooldown ||
        failureType == SecurityFailureType.accountLocked ||
        failureType == SecurityFailureType.dailyLimitReached;
  }

  /// Check if this requires immediate attention
  bool get requiresImmediateAction {
    return severity == SecuritySeverity.critical ||
        failureType == SecurityFailureType.bruteForceDetected;
  }

  /// Get user-friendly error category
  String get errorCategory {
    switch (failureType) {
      case SecurityFailureType.fileNotFound:
      case SecurityFailureType.fileTooLarge:
      case SecurityFailureType.fileTooSmall:
      case SecurityFailureType.fileCorrupted:
        return 'File Error';
      case SecurityFailureType.descriptionEmpty:
      case SecurityFailureType.descriptionTooLong:
      case SecurityFailureType.descriptionTooShort:
      case SecurityFailureType.locationEmpty:
        return 'Input Error';
      case SecurityFailureType.suspiciousContent:
        return 'Content Error';
      case SecurityFailureType.spamCooldown:
      case SecurityFailureType.dailyLimitReached:
        return 'Rate Limit';
      case SecurityFailureType.bruteForceDetected:
      case SecurityFailureType.accountLocked:
        return 'Security Alert';
      default:
        return 'Validation Error';
    }
  }

  @override
  String toString() {
    return 'SecurityResult(isValid: $isValid, message: $message, failureType: $failureType, severity: $severity)';
  }

  /// Convert to JSON for logging or API responses
  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'message': message,
      'cleanDescription': cleanDescription,
      'cleanLocation': cleanLocation,
      'failureType': failureType?.name,
      'severity': severity.name,
      'errorCategory': errorCategory,
      'isTemporaryFailure': isTemporaryFailure,
      'requiresImmediateAction': requiresImmediateAction,
      'metadata': metadata,
    };
  }
}

/// Model for brute force tracking data
class BruteForceData {
  final int failedAttempts;
  final DateTime? lastFailedAttempt;
  final DateTime? lockoutTime;
  final bool isLocked;
  final int remainingLockoutMinutes;

  const BruteForceData({
    required this.failedAttempts,
    this.lastFailedAttempt,
    this.lockoutTime,
    required this.isLocked,
    required this.remainingLockoutMinutes,
  });

  factory BruteForceData.fromPrefs({
    required int failedAttempts,
    required int lastFailedAttemptMs,
    required int lockoutTimeMs,
    required int lockoutDurationMinutes,
  }) {
    final now = DateTime.now();
    DateTime? lastFailed;
    DateTime? lockout;
    bool locked = false;
    int remaining = 0;

    if (lastFailedAttemptMs > 0) {
      lastFailed = DateTime.fromMillisecondsSinceEpoch(lastFailedAttemptMs);
    }

    if (lockoutTimeMs > 0) {
      lockout = DateTime.fromMillisecondsSinceEpoch(lockoutTimeMs);
      final lockoutDurationMs = lockoutDurationMinutes * 60 * 1000;
      final timeSinceLockout = now.millisecondsSinceEpoch - lockoutTimeMs;

      if (timeSinceLockout < lockoutDurationMs) {
        locked = true;
        remaining = ((lockoutDurationMs - timeSinceLockout) / 60000).ceil();
      }
    }

    return BruteForceData(
      failedAttempts: failedAttempts,
      lastFailedAttempt: lastFailed,
      lockoutTime: lockout,
      isLocked: locked,
      remainingLockoutMinutes: remaining,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'failedAttempts': failedAttempts,
      'lastFailedAttempt': lastFailedAttempt?.toIso8601String(),
      'lockoutTime': lockoutTime?.toIso8601String(),
      'isLocked': isLocked,
      'remainingLockoutMinutes': remainingLockoutMinutes,
    };
  }
}

/// Model for spam tracking data
class SpamTrackingData {
  final DateTime? lastReportTime;
  final String? lastReportDate;
  final int dailyCount;
  final int remainingCooldownMinutes;
  final bool hasReachedDailyLimit;

  const SpamTrackingData({
    this.lastReportTime,
    this.lastReportDate,
    required this.dailyCount,
    required this.remainingCooldownMinutes,
    required this.hasReachedDailyLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastReportTime': lastReportTime?.toIso8601String(),
      'lastReportDate': lastReportDate,
      'dailyCount': dailyCount,
      'remainingCooldownMinutes': remainingCooldownMinutes,
      'hasReachedDailyLimit': hasReachedDailyLimit,
    };
  }
}

/// Model for file validation data
class FileValidationData {
  final bool exists;
  final int sizeBytes;
  final double sizeMB;
  final bool isValidSize;
  final String? errorMessage;

  const FileValidationData({
    required this.exists,
    required this.sizeBytes,
    required this.sizeMB,
    required this.isValidSize,
    this.errorMessage,
  });

  factory FileValidationData.fromFile({
    required bool exists,
    required int sizeBytes,
    required int maxSizeBytes,
    required int minSizeBytes,
  }) {
    final sizeMB = sizeBytes / (1024 * 1024);
    final isValidSize = sizeBytes <= maxSizeBytes && sizeBytes >= minSizeBytes;

    String? errorMessage;
    if (!exists) {
      errorMessage = 'File not found';
    } else if (sizeBytes > maxSizeBytes) {
      errorMessage = 'File too large (${sizeMB.toStringAsFixed(1)}MB)';
    } else if (sizeBytes < minSizeBytes) {
      errorMessage = 'File too small or corrupted';
    }

    return FileValidationData(
      exists: exists,
      sizeBytes: sizeBytes,
      sizeMB: sizeMB,
      isValidSize: isValidSize,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'sizeBytes': sizeBytes,
      'sizeMB': sizeMB,
      'isValidSize': isValidSize,
      'errorMessage': errorMessage,
    };
  }
}

/// Configuration model for security settings
class SecurityConfig {
  final int maxFileSize;
  final int minFileSize;
  final int cooldownMinutes;
  final int maxReportsPerDay;
  final int maxDescriptionLength;
  final int maxFailedAttempts;
  final int lockoutDurationMinutes;
  final int failedAttemptResetHours;
  final List<String> forbiddenPatterns;

  const SecurityConfig({
    this.maxFileSize = 25 * 1024 * 1024, // 25MB
    this.minFileSize = 100 * 1024, // 100KB
    this.cooldownMinutes = 5,
    this.maxReportsPerDay = 10,
    this.maxDescriptionLength = 500,
    this.maxFailedAttempts = 5,
    this.lockoutDurationMinutes = 30,
    this.failedAttemptResetHours = 1,
    this.forbiddenPatterns = const [
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
    ],
  });

  Map<String, dynamic> toJson() {
    return {
      'maxFileSize': maxFileSize,
      'minFileSize': minFileSize,
      'cooldownMinutes': cooldownMinutes,
      'maxReportsPerDay': maxReportsPerDay,
      'maxDescriptionLength': maxDescriptionLength,
      'maxFailedAttempts': maxFailedAttempts,
      'lockoutDurationMinutes': lockoutDurationMinutes,
      'failedAttemptResetHours': failedAttemptResetHours,
      'forbiddenPatterns': forbiddenPatterns,
    };
  }
}
