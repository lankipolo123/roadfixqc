import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class ModuleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final double topHeight;
  final double spacing;
  final TextAlign textAlign;

  const ModuleHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.topHeight = 50,
    this.spacing = 0,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: topHeight, width: double.infinity, color: primary),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              if (showBack) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondary,
                    letterSpacing: spacing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(topHeight + 58);
}
