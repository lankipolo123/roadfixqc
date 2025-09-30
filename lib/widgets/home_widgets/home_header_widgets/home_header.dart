// lib/widgets/home_widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/user_model.dart';

import 'package:roadfix/screens/secondary_screens/notification_screen.dart';
import 'package:roadfix/widgets/common_widgets/user_avatar.dart';

import 'package:roadfix/widgets/home_widgets/home_header_widgets/gretting_text.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/user_name_text.dart';
import 'package:roadfix/widgets/home_widgets/notification_widget.dart';
import 'package:roadfix/widgets/themes.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;
  final String locationText;
  final bool isLoadingLocation;
  final VoidCallback? onLocationTap;
  final VoidCallback? onAvatarTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.locationText,
    required this.isLoadingLocation,
    this.onLocationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar - NOW PASSES lastUpdated for cache busting
          UserAvatar(
            imageUrl: user.userProfile,
            radius: 24,
            onTap: onAvatarTap,
            showBorder: true,
            lastUpdated: user.lastUpdated, // This ensures fresh images!
          ),
          const SizedBox(width: 12),

          // Greeting and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const GreetingText(text: 'Hi, Welcome'),
                const SizedBox(height: 2),
                UserNameText(name: user.fullName),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Location Badge
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingLocation)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(secondary),
                      ),
                    )
                  else
                    const Icon(Icons.location_on, size: 12, color: secondary),
                  const SizedBox(width: 4),
                  Text(
                    locationText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Notification icon with badge - UPDATED!
          NotificationIconWithBadge(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
