// lib/widgets/home_widgets/home_header.dart (COMPLETE UPDATED)
import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_summary.dart';
import 'package:roadfix/widgets/common_widgets/user_avatar.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/gretting_text.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/user_name_text.dart';
import 'package:roadfix/widgets/themes.dart';

class HomeHeader extends StatelessWidget {
  final ProfileSummary user;
  final String locationText;
  final bool isLoadingLocation;
  final VoidCallback? onLocationTap;
  final VoidCallback? onAvatarTap; // ✅ ADDED: Avatar tap handler

  const HomeHeader({
    super.key,
    required this.user,
    required this.locationText,
    required this.isLoadingLocation,
    this.onLocationTap,
    this.onAvatarTap, // ✅ ADDED
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Yellow strip
        Container(height: 50, width: double.infinity, color: primary),

        // White rounded header content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar - NOW USING UserAvatar COMPONENT
              UserAvatar(
                imageUrl: user.imageUrl,
                radius: 24,
                onTap: onAvatarTap, // ✅ ADDED: Make avatar tappable
                showBorder: true,
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
                    UserNameText(name: user.name),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Location Badge (receives data from parent)
              GestureDetector(
                onTap: onLocationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Loading indicator or location icon
                      if (isLoadingLocation)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              secondary,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: secondary,
                        ),
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

              // Notification icon
              Material(
                color: transparent,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none),
                  color: secondary,
                  onPressed: () {
                    debugPrint('Notification icon tapped');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
