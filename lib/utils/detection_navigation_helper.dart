import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/hybrid_detection_screen.dart';
import 'package:roadfix/widgets/dialog_widgets/detection_image_source.dart';

/// 🚀 UNIFIED NAVIGATION: Single model for all hazard detection!
class NavigationHelper {
  /// Navigate to unified detection screen - runs single RoadFix model
  static Future<void> navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSourceOption imageSourceOption,
  ) async {
    debugPrint('🧭 Unified Navigation: ${category.type} with $imageSourceOption');
    debugPrint('   → Using Unified Detection (Single RoadFix Model)');

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
