import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadfix/widgets/themes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets padding;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: altSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? secondary : altSecondary,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label',
            hintStyle: const TextStyle(color: altSecondary, fontSize: 16),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: altSecondary)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    onPressed: onSuffixIconTap,
                    icon: Icon(suffixIcon, color: altSecondary),
                  )
                : null,
            filled: true,
            fillColor:
                backgroundColor ?? (enabled ? inputFill : Colors.grey[300]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? altSecondary,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? altSecondary,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: statusDanger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: statusDanger, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            contentPadding: padding,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class NameTextField extends CustomTextField {
  NameTextField({
    super.key,
    required super.controller,
    super.label = 'Full Name',
    super.prefixIcon = Icons.person_outline,
  }) : super(
         textCapitalization: TextCapitalization.words,
         validator: (value) =>
             value?.isEmpty == true ? 'Please enter your full name' : null,
       );
}

class PhoneTextField extends CustomTextField {
  PhoneTextField({
    super.key,
    required super.controller,
    super.label = 'Phone Number',
    super.prefixIcon = Icons.phone_outlined,
  }) : super(
         keyboardType: TextInputType.phone,
         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
         validator: (value) =>
             value?.isEmpty == true ? 'Please enter your phone number' : null,
       );
}

class EmailTextField extends CustomTextField {
  EmailTextField({
    super.key,
    required super.controller,
    super.label = 'Email Address',
    super.prefixIcon = Icons.email_outlined,
  }) : super(
         keyboardType: TextInputType.emailAddress,
         textCapitalization: TextCapitalization.none,
         validator: (value) {
           if (value?.isEmpty == true) {
             return 'Please enter your email address';
           }
           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
             return 'Please enter a valid email address';
           }
           return null;
         },
       );
}

class DescriptionTextField extends CustomTextField {
  DescriptionTextField({
    super.key,
    required super.controller,
    super.label = 'Description',
    super.maxLines = 4,
    super.maxLength = 500,
    super.hintText,
    super.readOnly = false,
    super.enabled = true,
  }) : super(
         textCapitalization: TextCapitalization.sentences,
         validator: (value) =>
             value?.isEmpty == true ? 'Please enter a description' : null,
       );
}
