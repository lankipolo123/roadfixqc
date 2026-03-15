// lib/widgets/home_widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/utils/responsive.dart';

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
  final LocationStatus locationStatus;
  final VoidCallback? onLocationTap;
  final VoidCallback? onAvatarTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.locationText,
    required this.isLoadingLocation,
    required this.locationStatus,
    this.onLocationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar - NOW PASSES lastUpdated for cache busting
          UserAvatar(
            imageUrl: user.userProfile,
            radius: 24.r,
            onTap: onAvatarTap,
            showBorder: true,
            lastUpdated: user.lastUpdated, // This ensures fresh images!
          ),
          SizedBox(width: 12.w),

          // Greeting and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const GreetingText(text: 'Hi, Welcome'),
                SizedBox(height: 2.h),
                UserNameText(name: user.fullName),
              ],
            ),
          ),

          SizedBox(width: 6.w),

          // Location Badge
          Flexible(
            child: GestureDetector(
              onTap: onLocationTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoadingLocation)
                      SizedBox(
                        width: 10.r,
                        height: 10.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(secondary),
                        ),
                      )
                    else
                      Icon(
                        locationStatus == LocationStatus.serviceOff
                            ? Icons.gps_off
                            : (locationStatus == LocationStatus.denied ||
                                    locationStatus ==
                                        LocationStatus.deniedForever)
                                ? Icons.location_disabled
                                : Icons.location_on,
                        size: 12.r,
                        color: secondary,
                      ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        locationText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Notification icon with badge - UPDATED!
          NotificationIconWithBadge(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
