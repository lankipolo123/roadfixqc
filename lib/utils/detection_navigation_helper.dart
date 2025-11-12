import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/sequential_detection_screen.dart';
import 'package:roadfix/widgets/dialog_widgets/detection_image_source.dart';

/// 🚀 SEQUENTIAL NAVIGATION: 3 specialized models for maximum accuracy!
class NavigationHelper {
  /// Navigate to sequential detection screen - runs 3 models sequentially
  static Future<void> navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSourceOption imageSourceOption,
  ) async {
    debugPrint('🧭 Sequential Navigation: ${category.type} with $imageSourceOption');
    debugPrint('   → Using Sequential Detection (3 models for max accuracy)');

    // Convert ImageSourceOption to ImageSource
    ImageSource? source;
    if (imageSourceOption == ImageSourceOption.camera) {
      source = ImageSource.camera;
    } else if (imageSourceOption == ImageSourceOption.gallery) {
      source = ImageSource.gallery;
    }

    // Navigate to sequential detection screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SequentialDetectionScreen(
          initialImageSource: source,
          category: category,
        ),
      ),
    );
  }
}
