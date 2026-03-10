import 'package:flutter/material.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportCategoryButton extends StatelessWidget {
  final ReportCategory category;
  final VoidCallback? onTap;

  const ReportCategoryButton({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: secondary, width: 1),
          boxShadow: [
            BoxShadow(
              color: secondary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: transparent, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.asset(
                  category.imagePath,
                  width: 60.r,
                  height: 60.r,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    category.description,
                    style: TextStyle(color: altSecondary, fontSize: 14.sp),
                  ),
                ],
              ),
            ),

            // Arrow icon with background
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: inputFill,
                size: 16.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
