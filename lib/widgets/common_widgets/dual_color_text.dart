import 'package:flutter/material.dart';

class DualColorText extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color leftColor;
  final Color rightColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const DualColorText({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.leftColor,
    required this.rightColor,
    this.fontSize = 32,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 5,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: leftText,
            style: TextStyle(
              color: leftColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              fontFamily: 'Roboto', // built-in font
            ),
          ),
          TextSpan(
            text: rightText,
            style: TextStyle(
              color: rightColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
