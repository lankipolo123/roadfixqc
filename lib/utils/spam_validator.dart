import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadfix/constant/image_kit_constant.dart';
import 'dart:convert';

class SpamValidator {
  static const String _lastReportKey = 'last_report_timestamp';
  static const String _dailyReportsKey = 'daily_reports_count';
  static const String _lastReportDateKey = 'last_report_date';
  static const String _recentLocationsKey = 'recent_report_locations';
  static const String _recentDescriptionsKey = 'recent_descriptions';

  /// Check if user can submit a new report
  static Future<SpamValidationResult> canSubmitReport({
    String? location,
    String? description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Check 1: Time-based cooldown
    final cooldownResult = await _checkTimeCooldown(prefs, now);
    if (!cooldownResult.canSubmit) return cooldownResult;

    // Check 2: Daily limit
    final dailyLimitResult = await _checkDailyLimit(prefs, now);
    if (!dailyLimitResult.canSubmit) return dailyLimitResult;

    // Check 3: Location spam (if location provided)
    if (location != null && location.isNotEmpty) {
      final locationResult = await _checkLocationSpam(prefs, location);
      if (!locationResult.canSubmit) return locationResult;
    }

    // Check 4: Content similarity (if description provided)
    if (description != null && description.isNotEmpty) {
      final contentResult = await _checkContentSimilarity(prefs, description);
      if (!contentResult.canSubmit) return contentResult;
    }

    return SpamValidationResult(
      canSubmit: true,
      message: 'Report can be submitted',
    );
  }

  /// Record successful report submission
  static Future<void> recordReportSubmission({
    String? location,
    String? description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Update last report timestamp
    await prefs.setInt(_lastReportKey, now.millisecondsSinceEpoch);

    // Update daily count
    final today = _getDateString(now);
    final lastReportDate = prefs.getString(_lastReportDateKey);

    if (lastReportDate == today) {
      final currentCount = prefs.getInt(_dailyReportsKey) ?? 0;
      await prefs.setInt(_dailyReportsKey, currentCount + 1);
    } else {
      await prefs.setString(_lastReportDateKey, today);
      await prefs.setInt(_dailyReportsKey, 1);
    }

    // Store recent location (for duplicate checking)
    if (location != null && location.isNotEmpty) {
      await _storeRecentLocation(prefs, location);
    }

    // Store recent description (for similarity checking)
    if (description != null && description.isNotEmpty) {
      await _storeRecentDescription(prefs, description);
    }
  }

  // Private helper methods
  static Future<SpamValidationResult> _checkTimeCooldown(
    SharedPreferences prefs,
    DateTime now,
  ) async {
    final lastReportTime = prefs.getInt(_lastReportKey) ?? 0;
    final timeDifference = now.millisecondsSinceEpoch - lastReportTime;
    const cooldownMs = ImageKitConstants.spamCooldownMinutes * 60 * 1000;

    if (timeDifference < cooldownMs) {
      final remainingMinutes = ((cooldownMs - timeDifference) / 60000).ceil();
      return SpamValidationResult(
        canSubmit: false,
        message:
            'Please wait $remainingMinutes minutes before submitting another report',
        type: SpamType.timeCooldown,
      );
    }

    return SpamValidationResult(canSubmit: true, message: '');
  }

  static Future<SpamValidationResult> _checkDailyLimit(
    SharedPreferences prefs,
    DateTime now,
  ) async {
    final today = _getDateString(now);
    final lastReportDate = prefs.getString(_lastReportDateKey);

    if (lastReportDate == today) {
      final todayCount = prefs.getInt(_dailyReportsKey) ?? 0;
      if (todayCount >= ImageKitConstants.maxReportsPerDay) {
        return SpamValidationResult(
          canSubmit: false,
          message:
              'Daily report limit (${ImageKitConstants.maxReportsPerDay}) reached. Try again tomorrow',
          type: SpamType.dailyLimit,
        );
      }
    }

    return SpamValidationResult(canSubmit: true, message: '');
  }

  static Future<SpamValidationResult> _checkLocationSpam(
    SharedPreferences prefs,
    String location,
  ) async {
    final recentLocationsJson = prefs.getString(_recentLocationsKey);
    if (recentLocationsJson != null) {
      final List<dynamic> recentLocations = json.decode(recentLocationsJson);

      for (var locationData in recentLocations) {
        final storedLocation = locationData['location'] as String;
        final timestamp = locationData['timestamp'] as int;

        // Check if same location reported in last 30 minutes
        final timeDiff = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (timeDiff < (30 * 60 * 1000) &&
            _isSimilarLocation(location, storedLocation)) {
          return SpamValidationResult(
            canSubmit: false,
            message: 'A report from this location was recently submitted',
            type: SpamType.locationSpam,
          );
        }
      }
    }

    return SpamValidationResult(canSubmit: true, message: '');
  }

  static Future<SpamValidationResult> _checkContentSimilarity(
    SharedPreferences prefs,
    String description,
  ) async {
    final recentDescriptionsJson = prefs.getString(_recentDescriptionsKey);
    if (recentDescriptionsJson != null) {
      final List<dynamic> recentDescriptions = json.decode(
        recentDescriptionsJson,
      );

      for (var descriptionData in recentDescriptions) {
        final storedDescription = descriptionData['description'] as String;
        final timestamp = descriptionData['timestamp'] as int;

        // Check if similar content in last 2 hours
        final timeDiff = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (timeDiff < (2 * 60 * 60 * 1000) &&
            _isSimilarContent(description, storedDescription)) {
          return SpamValidationResult(
            canSubmit: false,
            message: 'A similar report was recently submitted',
            type: SpamType.contentSimilarity,
          );
        }
      }
    }

    return SpamValidationResult(canSubmit: true, message: '');
  }

  static Future<void> _storeRecentLocation(
    SharedPreferences prefs,
    String location,
  ) async {
    final recentLocationsJson = prefs.getString(_recentLocationsKey);
    List<dynamic> recentLocations = [];

    if (recentLocationsJson != null) {
      recentLocations = json.decode(recentLocationsJson);
    }

    // Add new location
    recentLocations.add({
      'location': location,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Keep only last 10 locations
    if (recentLocations.length > 10) {
      recentLocations = recentLocations.sublist(recentLocations.length - 10);
    }

    await prefs.setString(_recentLocationsKey, json.encode(recentLocations));
  }

  static Future<void> _storeRecentDescription(
    SharedPreferences prefs,
    String description,
  ) async {
    final recentDescriptionsJson = prefs.getString(_recentDescriptionsKey);
    List<dynamic> recentDescriptions = [];

    if (recentDescriptionsJson != null) {
      recentDescriptions = json.decode(recentDescriptionsJson);
    }

    // Add new description
    recentDescriptions.add({
      'description': description.toLowerCase(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Keep only last 5 descriptions
    if (recentDescriptions.length > 5) {
      recentDescriptions = recentDescriptions.sublist(
        recentDescriptions.length - 5,
      );
    }

    await prefs.setString(
      _recentDescriptionsKey,
      json.encode(recentDescriptions),
    );
  }

  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static bool _isSimilarLocation(String location1, String location2) {
    // Simple similarity check - can be improved with more sophisticated algorithms
    final words1 = location1.toLowerCase().split(' ');
    final words2 = location2.toLowerCase().split(' ');

    int commonWords = 0;
    for (String word in words1) {
      if (words2.contains(word) && word.length > 2) {
        commonWords++;
      }
    }

    return commonWords >= 2; // At least 2 common significant words
  }

  static bool _isSimilarContent(String content1, String content2) {
    // Simple similarity check using common words
    final words1 = content1.toLowerCase().split(' ');
    final words2 = content2.toLowerCase().split(' ');

    int commonWords = 0;
    for (String word in words1) {
      if (words2.contains(word) && word.length > 3) {
        commonWords++;
      }
    }

    // If more than 60% of significant words are common, it's similar
    final significantWords = words1.where((w) => w.length > 3).length;
    return significantWords > 0 && (commonWords / significantWords) > 0.6;
  }
}

// Result classes
class SpamValidationResult {
  final bool canSubmit;
  final String message;
  final SpamType? type;

  SpamValidationResult({
    required this.canSubmit,
    required this.message,
    this.type,
  });
}

enum SpamType { timeCooldown, dailyLimit, locationSpam, contentSimilarity }
