import 'package:flutter/material.dart';
import '../themes.dart';

class AuthRedirectTextButton extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onPressed;

  const AuthRedirectTextButton({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22.0),
      child: TextButton(
        onPressed: onPressed,
        child: RichText(
          text: TextSpan(
            text: "$prompt ",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: action,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
