import 'package:flutter/material.dart';

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      0,
      size.height * 0.5,
      size.width * 0.2,
      size.height * 0.2,
    );
    path.quadraticBezierTo(size.width * 0.7, 0, size.width, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.85,
      size.width * 0.3,
      size.height * 0.95,
    );
    path.quadraticBezierTo(0, size.height, 0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
