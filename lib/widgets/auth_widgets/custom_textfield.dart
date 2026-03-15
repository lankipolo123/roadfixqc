import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import '../themes.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? icon;
  final FocusNode? focusNode;
  final VoidCallback? onNext;
  final TextInputAction textInputAction;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.focusNode,
    this.onNext,
    this.textInputAction = TextInputAction.next,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: (_) => onNext?.call(),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: primary) : null,
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: altSecondary,
          ),
          hintStyle: const TextStyle(color: altSecondary),
          filled: true,
          fillColor: inputFill,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
        ),
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
      ),
    );
  }
}
