import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

// bro how dare u forget this
class GreetingText extends StatelessWidget {
  final String text;

  const GreetingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: altSecondary,
      ),
    );
  }
}
