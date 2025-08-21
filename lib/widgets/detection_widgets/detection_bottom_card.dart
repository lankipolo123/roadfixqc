import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: secondary, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Detection tags
          _buildDetectionTags(),
          const SizedBox(height: 20),
          // Buttons
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildDetectionTags() {
    if (detections.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: detections
            .map(
              (detection) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  'Tag: ${detection.className} (${(detection.confidence * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    color: statusDanger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text('Confirm', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
