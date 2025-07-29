import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart'; // ✅ Import your theme colors

class Header2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double topHeight;

  const Header2({super.key, required this.title, this.topHeight = 50});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: topHeight,
          width: double.infinity,
          color: primary, // ✅ Use your primary yellow
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          decoration: BoxDecoration(
            color: inputFill, // ✅ White background using your constant
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: secondary, // ✅ Use custom black color
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
