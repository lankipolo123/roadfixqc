import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/road_fix_logo.webp',
      height: 100.h,
      fit: BoxFit.contain,
    );
  }
}
