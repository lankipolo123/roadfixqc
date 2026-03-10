import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/home_widgets/home_report_preview_card.dart';

class HomeReportGrid extends StatelessWidget {
  const HomeReportGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
      ), // No vertical padding
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 6.h,
        crossAxisSpacing: 6.w,
        childAspectRatio: 2.6, // Small box shape
      ),
      itemCount: 4,
      itemBuilder: (_, index) {
        return HomeReportPreviewCard(status: 'PENDING', isActive: index == 0);
      },
    );
  }
}
