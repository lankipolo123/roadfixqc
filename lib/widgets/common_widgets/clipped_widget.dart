import 'package:flutter/material.dart';

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // top-left
    path.lineTo(size.width, 0); // top-right

    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.15,
      size.width * 0.85,
      size.height * 0.35,
    );

    path.quadraticBezierTo(
      size.width,
      size.height * 0.6,
      size.width,
      size.height,
    );

    path.lineTo(0, size.height); // bottom-left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
