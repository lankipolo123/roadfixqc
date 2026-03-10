import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class HomeReportPreviewCard extends StatelessWidget {
  final String status;
  final bool isActive;

  const HomeReportPreviewCard({
    super.key,
    required this.status,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: isActive ? primary : altSecondary, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_outlined, size: 20.r, color: secondary),
          SizedBox(height: 4.h),
          Text(
            status,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? primary : altSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
