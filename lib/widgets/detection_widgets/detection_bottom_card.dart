import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';
import '../../models/detection_result.dart';

class DetectionBottomCard extends StatelessWidget {
  final List<DetectionResult> detections;
  final String? categoryLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DetectionBottomCard({
    super.key,
    required this.detections,
    required this.onConfirm,
    required this.onCancel,
    this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: const [
          BoxShadow(color: secondary, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Detection tags
          _buildDetectionTags(),
          SizedBox(height: 20.h),
          // Buttons
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildDetectionTags() {
    if (detections.isNotEmpty) {
      // Group detections by className and count quantities
      final Map<String, int> detectionCounts = {};
      for (var detection in detections) {
        detectionCounts[detection.className] =
            (detectionCounts[detection.className] ?? 0) + 1;
      }

      return Wrap(
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
            child: Text(
              'Quantity: $count $className${count > 1 ? 's' : ''}',
              style: const TextStyle(
                color: statusDanger,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
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
          'Tag: No ${categoryLabel?.toLowerCase() ?? 'pothole'} detected',
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
