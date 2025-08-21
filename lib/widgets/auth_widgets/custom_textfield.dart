import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
            color: Colors.black87,
          ),
          hintStyle: const TextStyle(color: secondary),
          filled: true,
          fillColor: inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
        ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
      ),
    );
  }
}
