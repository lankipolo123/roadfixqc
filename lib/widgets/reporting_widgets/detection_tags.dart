import 'package:flutter/material.dart';

class DetectionTags extends StatelessWidget {
  final List<String> detections;

  const DetectionTags({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
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
        const SizedBox(height: 24),
      ],
    );
  }
}
