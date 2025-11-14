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

            const SizedBox(height: 60),

            // Big detection button with circles
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _handleDetectionTap(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Big circle with question mark and text inside
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.1),
                          border: Border.all(color: primary, width: 4),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Question mark
                              Icon(
                                Icons.question_mark_rounded,
                                size: 100,
                                color: primary,
                              ),

                              SizedBox(height: 16),

                              // Text inside circle
                              Text(
                                'Detect Road Issues',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Subtitle below circle
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Tap to detect potholes, cracks, poles, and roadblocks',
                          style: TextStyle(fontSize: 14, color: altSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDetectionTap(BuildContext context) async {
    try {
      // Show camera/gallery dialog
      final imageSourceOption = await DetectionImageSourceDialog.show(
        context,
        allowGallery: true,
      );

      if (imageSourceOption != null && context.mounted) {
        // Use first category as default (doesn't matter since unified detection)
        final category = reportCategories.first;
        await NavigationHelper.navigateToDetection(
          context,
          category,
          imageSourceOption,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detection failed: $e'),
            backgroundColor: statusDanger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
