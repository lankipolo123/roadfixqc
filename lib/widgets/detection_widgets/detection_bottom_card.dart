import 'package:flutter/material.dart';
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
    return Container(
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
    if (detections.isNotEmpty) {
      // Group detections by className: count + collect confidences
      final Map<String, List<double>> detectionConfidences = {};
      for (var detection in detections) {
        detectionConfidences
            .putIfAbsent(detection.className, () => [])
            .add(detection.confidence);
      }

      return Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: detectionConfidences.entries.map((entry) {
          final className = entry.key;
          final confidences = entry.value;
          final count = confidences.length;
          final avgConf = confidences.reduce((a, b) => a + b) / count;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              '$count ${className.replaceAll('_', ' ')}${count > 1 ? 's' : ''} — ${(avgConf * 100).toStringAsFixed(0)}% confidence',
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
