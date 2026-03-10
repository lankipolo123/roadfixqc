import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';

class DetectionTags extends StatelessWidget {
  final List<String> detections;

  const DetectionTags({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags:',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: detections
              .map(
                (detection) => Chip(
                  label: Text(detection),
                  backgroundColor: Colors.red[50],
                  side: BorderSide(color: Colors.red[200]!),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
