// lib/widgets/common_widgets/user_avatar.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final int? lastUpdated; // Cache-busting parameter

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.onTap,
    this.showBorder = false,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    // Create cache-busted URL if we have both imageUrl and lastUpdated
    String? finalImageUrl;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (lastUpdated != null) {
        final separator = imageUrl!.contains('?') ? '&' : '?';
        finalImageUrl = '$imageUrl${separator}v=$lastUpdated';
      } else {
        finalImageUrl = imageUrl;
      }
    }

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: finalImageUrl != null && finalImageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedNetworkImage(
                imageUrl: finalImageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                // Use lastUpdated as cache key to force refresh when image changes
                cacheKey: lastUpdated != null ? 'avatar_$lastUpdated' : null,
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            )
          : Icon(Icons.person, size: radius * 1.2, color: Colors.grey[600]),
    );

    // Add border if requested
    if (showBorder) {
      avatarWidget = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: avatarWidget,
      );
    }

    // Add tap functionality if provided
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatarWidget);
    }

    return avatarWidget;
  }
}
