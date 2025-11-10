import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_categories.dart';
import 'package:roadfix/utils/detection_navigation_helper.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/widgets/dialog_widgets/detection_image_source.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/dual_color_text.dart';
import 'package:roadfix/widgets/reporting_widgets/report_category_button.dart';

class ReportTypeScreen extends StatelessWidget {
  const ReportTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Logo
            Center(
              child: Image.asset(
                'assets/images/roadfix_logo_alt2.webp',
                height: 100,
              ),
            ),

            const SizedBox(height: 16),

            const DualColorText(
              leftText: 'Report ',
              rightText: 'NOW!',
              leftColor: primary,
              rightColor: secondary,
            ),

            const SizedBox(height: 24),

            // Report category list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: reportCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return ReportCategoryButton(
                    category: reportCategories[index],
                    onTap: () =>
                        _handleCategoryTap(context, reportCategories[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCategoryTap(
    BuildContext context,
    ReportCategory category,
  ) async {
    // ✅ Show the right dialog options based on category type
    final imageSourceOption = await _showImageSourceDialog(context, category);

    if (imageSourceOption != null && context.mounted) {
      await NavigationHelper.navigateToDetection(
        context,
        category,
        imageSourceOption,
      );
    }
  }

  /// ✅ Show dialog with correct options for each category
  Future<ImageSourceOption?> _showImageSourceDialog(
    BuildContext context,
    ReportCategory category,
  ) async {
    switch (category.type) {
      case ReportCategoryType.pothole:
        // ✅ POTHOLE: Show all 3 options (Camera, Distance Camera, Gallery)
        return DetectionImageSourceDialog.show(
          context,
          allowGallery: true,
          allowDistanceCamera: true,
        );

      case ReportCategoryType.roadConcern: // ✅ FIXED - was roadblock
        // ✅ ROADBLOCK: Show 2 options (Camera, Gallery)
        return DetectionImageSourceDialog.show(
          context,
          allowGallery: true,
          allowDistanceCamera: false,
        );

      case ReportCategoryType.utilityPole:
        // ✅ UTILITY POLE: Go straight to camera (no dialog)
        return ImageSourceOption.camera;

      case ReportCategoryType.roadCrack:
        // ✅ ROAD CRACK: Show 2 options (Camera, Gallery)
        return DetectionImageSourceDialog.show(
          context,
          allowGallery: true,
          allowDistanceCamera: false,
        );

      default:
        return null;
    }
  }
}
