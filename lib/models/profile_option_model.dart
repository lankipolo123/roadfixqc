import 'package:flutter/material.dart';

class ProfileOption {
  final IconData icon;
  final String label;
  final Color iconBackgroundColor;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  ProfileOption({
    required this.icon,
    required this.label,
    required this.iconBackgroundColor,
    required this.onTap,
    this.labelStyle,
  });
}
