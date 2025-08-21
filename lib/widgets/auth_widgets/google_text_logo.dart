import 'package:flutter/material.dart';

class GoogleTextLogo extends StatelessWidget {
  final double fontSize;

  const GoogleTextLogo({super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          // Gradient "G"
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4285F4), // Blue
                  Color(0xFF34A853), // Green
                  Color(0xFFFBBC05), // Yellow
                  Color(0xFFEA4335), // Red
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 10, // Needed for ShaderMask
                ),
              ),
            ),
          ),
          // Normal "oogle"
          TextSpan(
            text: 'oogle',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Or `secondary` if themed
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }
}
