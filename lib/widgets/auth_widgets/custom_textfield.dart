import 'package:flutter/material.dart';
import '../themes.dart';

class CustomTextField extends StatefulWidget {
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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: (_) => widget.onNext?.call(),
        decoration: InputDecoration(
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: primary)
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: altSecondary,
                  ),
                  onPressed: () {
                    setState(() => _isObscured = !_isObscured);
                  },
                )
              : null,
          labelText: widget.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: altSecondary,
          ),
          hintStyle: const TextStyle(color: altSecondary),
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
