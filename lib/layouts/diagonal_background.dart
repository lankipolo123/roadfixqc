// layouts/diagonal_background_layout.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/common_widgets/diagonal_stripes.dart';
import 'package:roadfix/widgets/themes.dart';

class DiagonalBackgroundLayout extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? stripeColor;
  final double stripeWidth;
  final double gapWidth;

  const DiagonalBackgroundLayout({
    super.key,
    required this.child,
    this.backgroundColor = primary,
    this.stripeColor = altSecondary,
    this.stripeWidth = 25,
    this.gapWidth = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen diagonal background
          Positioned.fill(
            child: DiagonalStripes(
              height: MediaQuery.of(context).size.height,
              backgroundColor: backgroundColor!,
              stripeColor: stripeColor!,
              stripeWidth: stripeWidth,
              gapWidth: gapWidth,
            ),
          ),
          // Content overlay
          SafeArea(child: child),
        ],
      ),
    );
  }
}
