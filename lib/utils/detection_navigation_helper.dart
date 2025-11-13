import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/hybrid_detection_screen.dart';
import 'package:roadfix/widgets/dialog_widgets/detection_image_source.dart';

/// 🚀 SEQUENTIAL NAVIGATION: 2 models running sequentially!
class NavigationHelper {
  /// Navigate to sequential detection screen - runs 2 models (Pothole → Unified)
  static Future<void> navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSourceOption imageSourceOption,
  ) async {
    debugPrint('🧭 Sequential Navigation: ${category.type} with $imageSourceOption');
    debugPrint('   → Using Sequential Detection (2 Models)');

    // Convert ImageSourceOption to ImageSource
    ImageSource? source;
    if (imageSourceOption == ImageSourceOption.camera) {
      source = ImageSource.camera;
    } else if (imageSourceOption == ImageSourceOption.gallery) {
      source = ImageSource.gallery;
    }

    // Navigate to hybrid detection screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HybridDetectionScreen(
          initialImageSource: source,
          category: category,
        ),
      ),
    );
  }
}
