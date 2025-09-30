import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/pothole_detection_screen.dart';
import 'package:roadfix/screens/secondary_screens/road_concern_screen.dart';
import 'package:roadfix/screens/secondary_screens/utility_pole_camera_screen.dart';

class NavigationHelper {
  static void navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSource imageSource,
  ) {
    switch (category.type) {
      case ReportCategoryType.pothole:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PotholeDetectionScreen(
              initialImageSource: imageSource,
              category: category,
            ),
          ),
        );
        break;

      case ReportCategoryType.utilityPole:
        // Utility pole uses custom camera screen (ignores imageSource)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UtilityPoleCameraScreen(category: category),
          ),
        );
        break;

      case ReportCategoryType.roadConcern:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RoadConcernScreen(initialImageSource: imageSource),
          ),
        );
        break;
    }
  }
}
