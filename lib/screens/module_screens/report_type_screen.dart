import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_categories.dart';
import 'package:roadfix/utils/detection_navigation_helper.dart';
import 'package:roadfix/widgets/dialog_widgets/image_source_dialog.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/dual_color_text.dart';
import 'package:roadfix/utils/responsive.dart';

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
            SizedBox(height: 24.h),

            // Logo
            Center(
              child: Image.asset(
                'assets/images/roadfix_logo_alt2.webp',
                height: 100.h,
              ),
            ),

            SizedBox(height: 16.h),

            const DualColorText(
              leftText: 'Report ',
              rightText: 'NOW!',
              leftColor: primary,
              rightColor: secondary,
            ),

            SizedBox(height: 60.h),

            // Big detection button with circles
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _handleDetectionTap(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Big circle with question mark and text inside
                      CustomPaint(
                        foregroundPainter: const _StripedCircleBorderPainter(
                          borderWidth: 6,
                          stripeColor: altSecondary,
                          backgroundColor: primary,
                          stripeWidth: 12,
                          gapWidth: 12,
                        ),
                        child: Container(
                          width: 250.r,
                          height: 250.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withValues(alpha: 0.1),
                          ),
                          child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Question mark
                              Icon(
                                Icons.question_mark_rounded,
                                size: 100.r,
                                color: primary,
                              ),

                              SizedBox(height: 16.h),

                              // Text inside circle
                              Text(
                                'Detect Road Issues',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),

                      SizedBox(height: 32.h),

                      // Subtitle below circle
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          'Tap to detect potholes, cracks, poles, and roadblocks',
                          style: TextStyle(fontSize: 14.sp, color: altSecondary),
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
      final source = await ImageSourceDialog.show(context);

      if (source != null && context.mounted) {
        // Use first category as default (doesn't matter since unified detection)
        final category = reportCategories.first;
        await NavigationHelper.navigateToDetection(
          context,
          category,
          source,
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

class _StripedCircleBorderPainter extends CustomPainter {
  final double borderWidth;
  final Color stripeColor;
  final Color backgroundColor;
  final double stripeWidth;
  final double gapWidth;

  const _StripedCircleBorderPainter({
    required this.borderWidth,
    required this.stripeColor,
    required this.backgroundColor,
    required this.stripeWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - borderWidth;

    // Create annulus (ring) clip path
    final ringPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius))
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.save();
    canvas.clipPath(ringPath);

    final paint = Paint()..isAntiAlias = false;

    // Fill ring with background color
    paint.color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw diagonal stripes (same logic as _StripesPainter)
    paint.color = stripeColor;
    final totalWidth = stripeWidth + gapWidth;
    final double hypotenuse = size.height * 3.5;

    for (double x = -hypotenuse; x < size.width + hypotenuse; x += totalWidth) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + stripeWidth, 0);
      path.lineTo(x + stripeWidth - size.height, size.height);
      path.lineTo(x - size.height, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
