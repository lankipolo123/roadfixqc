import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/utils/responsive.dart';

class ModuleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final double topHeight;
  final double spacing;
  final TextAlign textAlign;

  const ModuleHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.topHeight = 50,
    this.spacing = 2,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Replace the solid color container with DiagonalStripes
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new, size: 20.r),
                ),
              if (showBack) SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: secondary,
                    letterSpacing: spacing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(topHeight + 58);
}
