import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/dual_color_text.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Background gradient bar (positioned behind)
            Container(
              height: 96.h, // Same height as main banner
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [statusDanger, orangeAccent, statusSuccess],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),

            // Main banner (on top)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [secondary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.asset(
                        'assets/images/icons/roadFixLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DualColorText(
                          leftText: 'ROAD',
                          rightText: 'FIX',
                          leftColor: inputFill,
                          rightColor: primary,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 12,
                        ),

                        SizedBox(height: 12.h),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '•Detect ',
                                style: TextStyle(
                                  color: statusDanger,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: '•Report ',
                                style: TextStyle(
                                  color: orangeAccent,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: '•Action ',
                                style: TextStyle(
                                  color: statusSuccess,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: '•ROAD',
                                style: TextStyle(
                                  color: inputFill,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'FIXED',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Separate gradient bar below
      ],
    );
  }
}
