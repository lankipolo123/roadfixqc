import 'package:flutter/material.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/widgets/themes.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;

  BoundingBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    // Clip to canvas bounds to prevent overflow
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..color = statusDanger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var detection in detections) {
      // Convert normalized coordinates to screen coordinates
      final double centerX = (detection.centerX * size.width).clamp(
        0,
        size.width,
      );
      final double centerY = (detection.centerY * size.height).clamp(
        0,
        size.height,
      );
      final double boxWidth = (detection.width * size.width).clamp(
        0,
        size.width,
      );
      final double boxHeight = (detection.height * size.height).clamp(
        0,
        size.height,
      );

      // Calculate top-left corner
      final double left = (centerX - (boxWidth / 2)).clamp(
        0,
        size.width - boxWidth,
      );
      final double top = (centerY - (boxHeight / 2)).clamp(
        0,
        size.height - boxHeight,
      );

      // Ensure box doesn't go outside bounds
      final double finalWidth = (left + boxWidth > size.width)
          ? size.width - left
          : boxWidth;
      final double finalHeight = (top + boxHeight > size.height)
          ? size.height - top
          : boxHeight;

      // Only draw if box has valid dimensions and is within bounds
      if (finalWidth > 0 && finalHeight > 0 && left >= 0 && top >= 0) {
        final rect = Rect.fromLTWH(left, top, finalWidth, finalHeight);
        canvas.drawRect(rect, paint);

        // Draw confidence label
        final textSpan = TextSpan(
          text: '${(detection.confidence * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: secondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        // Position label above the box, within bounds
        final double labelX = left.clamp(0, size.width - textPainter.width);
        final double labelY = (top - textPainter.height - 2).clamp(
          0,
          size.height - textPainter.height,
        );

        // Draw background for text
        final textBgRect = Rect.fromLTWH(
          labelX,
          labelY,
          textPainter.width + 4,
          textPainter.height + 2,
        );

        canvas.drawRect(
          textBgRect,
          Paint()..color = statusDanger.withValues(alpha: 0.9),
        );

        textPainter.paint(canvas, Offset(labelX + 2, labelY + 1));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
