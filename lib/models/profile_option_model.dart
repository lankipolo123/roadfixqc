// lib/models/profile_option_model.dart
import 'package:flutter/material.dart';

enum ProfileOptionMode {
  normal, // Shows chevron (default)
  toggle, // Shows switch
  iconOnly, // Shows only an icon
}

class ProfileOption {
  final IconData icon;
  final String label;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final TextStyle? labelStyle;
  final Widget? trailing;

  // New properties for different modes
  final ProfileOptionMode mode;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final IconData? trailingIcon;
  final Color? trailingIconColor;

  ProfileOption({
    required this.icon,
    required this.label,
    required this.iconBackgroundColor,
    this.onTap,
    this.labelStyle,
    this.trailing,
    this.mode = ProfileOptionMode.normal,
    this.toggleValue,
    this.onToggleChanged,
    this.trailingIcon,
    this.trailingIconColor,
  }) : assert(
         mode != ProfileOptionMode.toggle ||
             (toggleValue != null && onToggleChanged != null),
         'toggleValue and onToggleChanged must be provided when mode is toggle',
       );
}
