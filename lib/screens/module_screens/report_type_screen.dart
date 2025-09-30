import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_categories.dart';
import 'package:roadfix/utils/detection_navigation_helper.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/dual_color_text.dart';
import 'package:roadfix/widgets/reporting_widgets/report_category_button.dart';
import 'package:roadfix/widgets/dialog_widgets/image_source_dialog.dart';

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
    final imageSource = await ImageSourceDialog.show(
      context,
      allowGallery: category.type != ReportCategoryType.utilityPole,
    );
    if (imageSource != null && context.mounted) {
      NavigationHelper.navigateToDetection(context, category, imageSource);
    }
  }
}
