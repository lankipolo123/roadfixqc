import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';

class SuccessHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;

  const SuccessHeader({
    super.key,
    this.title = "Report submitted successfully!",
    this.subtitle,
    this.icon = Icons.check_circle,
    this.iconColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 60.r),
        SizedBox(height: 16.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
