import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/unified_detection_screen.dart';

/// Navigation helper for detection - routes to Unified Detection (single model)
class NavigationHelper {
  /// Navigate to unified detection screen - one model detects all hazards
  static Future<void> navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSource source,
  ) async {
    debugPrint('Navigation: ${category.type} with $source');
    debugPrint('   -> Using Unified Detection (Single Model)');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedDetectionScreen(
          initialImageSource: source,
          category: category,
        ),
      ),
    );
  }
}
