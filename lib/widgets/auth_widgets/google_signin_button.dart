import 'package:flutter/material.dart';
import '../themes.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Image.asset(
        'assets/images/google_logo.webp',
        height: 18,
        width: 18,
        fit: BoxFit.contain,
      ),
      label: const Text(
        "Google",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: primary, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ), // ↓ tighter
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        // TODO: Add Google sign-in logic
      },
    );
  }
}
