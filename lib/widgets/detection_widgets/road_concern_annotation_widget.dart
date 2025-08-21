import 'package:flutter/material.dart';
import 'package:bounding_box_annotation/bounding_box_annotation.dart';

class AnnotationControls extends StatelessWidget {
  final List<AnnotationDetails> annotations;
  final VoidCallback onRefresh;
  final VoidCallback onChangeImage;
  final VoidCallback onConfirm;

  const AnnotationControls({
    super.key,
    required this.annotations,
    required this.onRefresh,
    required this.onChangeImage,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact instructions
          _buildCompactInstructions(),
          const SizedBox(height: 12), // Reduced spacing
          // Show annotations count if any
          if (annotations.isNotEmpty) ...[
            _buildAnnotationsCount(),
            const SizedBox(height: 12),
          ],

          // Action buttons only
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCompactInstructions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Smaller padding
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.gesture,
            color: Colors.blue[700],
            size: 18,
          ), // Changed icon and smaller
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Tap and drag to draw boxes',
              style: TextStyle(fontSize: 13), // Smaller text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationsCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(
        '${annotations.length} annotations added',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Refresh button (smaller)
        Expanded(
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh', style: TextStyle(fontSize: 14)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Retake button
        Expanded(
          child: TextButton(
            onPressed: onChangeImage,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Retake', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),

        // Confirm button
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
