import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class UserNameText extends StatelessWidget {
  final String name;

  const UserNameText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 200.w, // Adjust this value based on your needs
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 15.sp,
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
