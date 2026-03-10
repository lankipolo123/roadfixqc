import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import '../themes.dart';

class SocialDivider extends StatelessWidget {
  const SocialDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Row(
        children: [
          const Expanded(child: Divider(color: primary, thickness: 1.5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              "or",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
          const Expanded(child: Divider(color: primary, thickness: 1.5)),
        ],
      ),
    );
  }
}
