import 'package:flutter/material.dart';

class DiagonalStripes extends StatelessWidget {
  final double height;
  final Color stripeColor;
  final Color backgroundColor;
  final double stripeWidth;
  final double gapWidth;

  const DiagonalStripes({
    super.key,
    this.height = 15,
    this.stripeColor = Colors.black,
    this.backgroundColor = const Color(0xFFF7C90D),
    this.stripeWidth = 8,
    this.gapWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StripesPainter(
          stripeColor: stripeColor,
          backgroundColor: backgroundColor,
          stripeWidth: stripeWidth,
          gapWidth: gapWidth,
        ),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  final Color stripeColor;
  final Color backgroundColor;
  final double stripeWidth;
  final double gapWidth;

  _StripesPainter({
    required this.stripeColor,
    required this.backgroundColor,
    required this.stripeWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;

    // Fill background
    paint.color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw diagonal stripes
    paint.color = stripeColor;
    final totalWidth = stripeWidth + gapWidth;
    final double hypotenuse = size.height * 1.5;

    for (double x = -hypotenuse; x < size.width + hypotenuse; x += totalWidth) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + stripeWidth, 0);
      path.lineTo(x + stripeWidth - size.height, size.height);
      path.lineTo(x - size.height, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
