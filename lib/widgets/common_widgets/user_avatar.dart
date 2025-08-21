// lib/widgets/home_widgets/home_header_widgets/user_avatar.dart (COMPLETE ENHANCED)
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: altSecondary,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!) // ✅ FIXED: Use raw URL
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.person, color: secondary, size: radius * 0.8)
          : null,
    );

    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primary.withValues(alpha: 0.3), width: 2),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
