import 'package:flutter/material.dart';
import 'package:roadfix/services/language_service.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';
import '../../models/detection_result.dart';

class DetectionBottomCard extends StatelessWidget {
  final List<DetectionResult> detections;
  final String? categoryLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback? onRetry;

  const DetectionBottomCard({
    super.key,
    required this.detections,
    required this.onConfirm,
    required this.onCancel,
    this.categoryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService(),
      builder: (context, _) => Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: const [
          BoxShadow(color: secondary, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: detections.isEmpty ? _buildEmptyState() : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetectionTags(),
          SizedBox(height: 20.h),
          _buildButtons(),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off, size: 40.w, color: altSecondary),
        SizedBox(height: 12.h),
        Text(
          'No issues detected',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: altSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Try another photo to detect road hazards',
          style: TextStyle(
            fontSize: 13.sp,
            color: altSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        ElevatedButton(
          onPressed: onRetry ?? onCancel,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
          ),
          child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
        ),
      ],
    );
  }

  Widget _buildDetectionTags() {
    final lang = LanguageService();

    if (detections.isNotEmpty) {
      // Group detections by className
      final Map<String, int> detectionCounts = {};
      for (var detection in detections) {
        detectionCounts[detection.className] =
            (detectionCounts[detection.className] ?? 0) + 1;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.detectionResult,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: secondary,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: detectionCounts.entries.map((entry) {
              final className = entry.key;
              final count = entry.value;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14.w, color: statusDanger),
                    SizedBox(width: 6.w),
                    Text(
                      lang.detectionStatement(className, count),
                      style: const TextStyle(
                        color: statusDanger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: altSecondary),
        ),
        child: Text(
          lang.noHazardDetected(categoryLabel),
          style: const TextStyle(
            color: altSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
          ),
          child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
        ),
        SizedBox(width: 20.w),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
          ),
          child: Text('Confirm', style: TextStyle(fontSize: 16.sp)),
        ),
      ],
    );
  }
}
