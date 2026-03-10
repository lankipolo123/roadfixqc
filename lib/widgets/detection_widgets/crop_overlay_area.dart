import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class CameraGuideOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final startY = size.height * 0.6;
    final height = size.height * 0.4;
    final rect = Rect.fromLTWH(0, startY, size.width, height);

    // Semi-transparent yellow fill
    final fillPaint = Paint()
      ..color = primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Yellow border
    final borderPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, borderPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    const cornerSize = 30.0;

    // Top-left corner
    canvas.drawLine(Offset(0, startY), Offset(cornerSize, startY), cornerPaint);
    canvas.drawLine(
      Offset(0, startY),
      Offset(0, startY + cornerSize),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerSize, startY),
      Offset(size.width, startY),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, startY),
      Offset(size.width, startY + cornerSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, startY + height - cornerSize),
      Offset(0, startY + height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(0, startY + height),
      Offset(cornerSize, startY + height),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, startY + height - cornerSize),
      Offset(size.width, startY + height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - cornerSize, startY + height),
      Offset(size.width, startY + height),
      cornerPaint,
    );

    // Label text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DETECTION AREA',
        style: TextStyle(
          color: primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textX = (size.width - textPainter.width) / 2;
    final textY = startY + 15;

    // Background for text
    final textBgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        textX - 8,
        textY - 4,
        textPainter.width + 16,
        textPainter.height + 8,
      ),
      const Radius.circular(4),
    );
    final textBgPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawRRect(textBgRect, textBgPaint);

    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
