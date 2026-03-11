import 'dart:math';
import 'package:flutter/material.dart';

/// Responsive sizing utility for consistent scaling across screen sizes.
/// Reference design: 375 x 812 (standard mobile).
/// Call Responsive.init(context) once in the root widget.
class Responsive {
  static double _screenWidth = 375;
  static double _screenHeight = 812;

  static const double _designWidth = 375;
  static const double _designHeight = 812;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  /// Scale value by width ratio
  static double w(double size) => size * _screenWidth / _designWidth;

  /// Scale value by height ratio
  static double h(double size) => size * _screenHeight / _designHeight;

  /// Scale font size — uses width ratio, capped at 1.3x to avoid giant text
  static double sp(double size) =>
      size * min(_screenWidth / _designWidth, 1.3);

  /// Scale radius — uses the smaller of width/height ratio for consistency
  static double r(double size) =>
      size * min(_screenWidth / _designWidth, _screenHeight / _designHeight);
}

/// Extension on num for cleaner syntax: 16.w, 14.sp, etc.
extension ResponsiveExtension on num {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
  double get r => Responsive.r(toDouble());
}
