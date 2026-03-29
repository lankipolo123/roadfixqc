import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/unified_detection_screen.dart';

class NavigationHelper {
  static Future<void> navigateToDetection(
    BuildContext context,
    ReportCategory category,
    ImageSource source,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectionScreen(
          initialImageSource: source,
          category: category,
        ),
      ),
    );
  }
}
