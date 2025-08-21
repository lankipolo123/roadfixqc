import 'package:flutter/material.dart';
import 'package:roadfix/widgets/common_widgets/diagonal_stripes.dart';

class StripedFormLayout extends StatelessWidget {
  final Widget child;
  final double stripeHeight;

  const StripedFormLayout({
    super.key,
    required this.child,
    this.stripeHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background diagonal stripes (decorative only)
        const Positioned(
          top: -3,
          left: 0,
          right: 0,
          child: SizedBox(height: 100, child: DiagonalStripes()),
        ),
        const Positioned(
          bottom: -1,
          left: 0,
          right: 0,
          child: SizedBox(height: 100, child: DiagonalStripes()),
        ),

        // Main content
        Positioned.fill(child: child),
      ],
    );
  }
}
