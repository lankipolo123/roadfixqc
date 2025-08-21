import 'package:flutter/material.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: inputFill,
        foregroundColor: secondary,
      ),
      onPressed: onPressed,
      child: const GoogleTextLogo(fontSize: 18),
    );
  }
}
