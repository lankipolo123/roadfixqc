import 'package:flutter/material.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password logic
        },
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color.fromARGB(255, 219, 16, 16),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
