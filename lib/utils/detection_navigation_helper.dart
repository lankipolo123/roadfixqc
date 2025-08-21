import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/reporting_detection_screens/pothole_detection_screen.dart';
import 'package:roadfix/screens/reporting_detection_screens/road_concern_screen.dart';

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
        _showComingSoon(context, 'Utility Pole Detection');
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

  static void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
