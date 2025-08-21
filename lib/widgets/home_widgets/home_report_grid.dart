import 'package:flutter/material.dart';
import 'package:roadfix/widgets/home_widgets/home_report_preview_card.dart';

class HomeReportGrid extends StatelessWidget {
  const HomeReportGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ), // ❌ No vertical padding
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 2.6, // Small box shape
      ),
      itemCount: 4,
      itemBuilder: (_, index) {
        return HomeReportPreviewCard(status: 'PENDING', isActive: index == 0);
      },
    );
  }
}
