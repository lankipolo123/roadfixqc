import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class UserNameText extends StatelessWidget {
  final String name;

  const UserNameText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 200, // Adjust this value based on your needs
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: secondary,
          height: 1.3,
        ),
        maxLines: 2, // Allow up to 2 lines
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }
}
