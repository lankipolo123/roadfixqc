import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import '../themes.dart';
import 'google_text_logo.dart'; // Import the component

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: primary, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        backgroundColor: inputFill,
        foregroundColor: secondary,
      ),
      onPressed: onPressed,
      child: GoogleTextLogo(fontSize: 18.sp),
    );
  }
}
