import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/distance_detection_camera_screen.dart';
import 'package:roadfix/screens/secondary_screens/pothole_detection_screen.dart';
import 'package:roadfix/screens/secondary_screens/road_block_detection_screen.dart';
import 'package:roadfix/screens/secondary_screens/utility_pole_camera_screen.dart';
import 'package:roadfix/widgets/dialog_widgets/detection_image_source.dart';

/// ✅ FIXED: Navigation helper that properly handles all detection types
class NavigationHelper {
  /// Main navigation method that routes based on category and image source
  static Future<void> navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSourceOption imageSourceOption,
  ) async {
    debugPrint('🧭 Navigation: ${category.type} with $imageSourceOption');

    switch (category.type) {
      // ====================================
      // POTHOLE DETECTION (3 options)
      // ====================================
      case ReportCategoryType.pothole:
        if (imageSourceOption == ImageSourceOption.distanceCamera) {
          // Option 1: Distance Detection Camera (hybrid zoom)
          debugPrint('   → Distance Detection Camera Screen');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DistanceDetectionCameraScreen(
                category: category,
                detectionType: DetectionType.pothole,
              ),
            ),
          );
        } else if (imageSourceOption == ImageSourceOption.camera) {
          // Option 2: Normal Camera (no distance detection)
          debugPrint('   → Normal Pothole Camera Screen');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PotholeDetectionScreen(
                initialImageSource: ImageSource.camera,
                category: category,
              ),
            ),
          );
        } else {
          // Option 3: Gallery
          debugPrint('   → Pothole Gallery Screen');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PotholeDetectionScreen(
                initialImageSource: ImageSource.gallery,
                category: category,
              ),
            ),
          );
        }
        break;

      // ====================================
      // ROADBLOCK DETECTION (2 options)
      // ====================================
      case ReportCategoryType.roadConcern: // ✅ FIXED - was roadblock
        // Use built-in camera/gallery picker for both options
        debugPrint(
          '   → Roadblock Detection Screen (${imageSourceOption == ImageSourceOption.camera ? 'Camera' : 'Gallery'})',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoadblockDetectionScreen(
              initialImageSource: imageSourceOption == ImageSourceOption.camera
                  ? ImageSource.camera
                  : ImageSource.gallery,
              category: category,
            ),
          ),
        );
        break;

      // ====================================
      // UTILITY POLE DETECTION (1 option: camera only)
      // ====================================
      case ReportCategoryType.utilityPole:
        debugPrint('   → Utility Pole Camera Screen');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UtilityPoleCameraScreen(category: category),
          ),
        );
        break;

      // ====================================
      // ROAD CRACK DETECTION (2 options: camera/gallery)
      // ====================================
      case ReportCategoryType.roadCrack:
        debugPrint(
          '   → Road Crack Detection Screen (${imageSourceOption == ImageSourceOption.camera ? 'Camera' : 'Gallery'})',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoadblockDetectionScreen(
              initialImageSource: imageSourceOption == ImageSourceOption.camera
                  ? ImageSource.camera
                  : ImageSource.gallery,
              category: category,
            ),
          ),
        );
        break;

      default:
        debugPrint('   ⚠️ Unknown category type');
    }
  }
}
