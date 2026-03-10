// lib/widgets/home_widgets/home_header_widgets/mock_home_header.dart
import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class MockHomeHeader extends StatelessWidget {
  const MockHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: inputFill, // Transparent background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          MockUserAvatar(radius: 24.r, showBorder: true),
          SizedBox(width: 12.w),

          // Greeting and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MockGreetingText(text: 'Hi, Welcome'),
                SizedBox(height: 2.h),
                MockUserNameText(name: 'John Doe'),
              ],
            ),
          ),

          SizedBox(width: 6.w),

          // Location Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 12.r, color: secondary),
                SizedBox(width: 4.w),
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Notification icon with badge
          const MockNotificationIconWithBadge(),
        ],
      ),
    );
  }
}

// Mock User Avatar
class MockUserAvatar extends StatelessWidget {
  final double radius;
  final bool showBorder;

  const MockUserAvatar({
    super.key,
    required this.radius,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: showBorder
            ? Border.all(color: primary.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}

// Mock Greeting Text
class MockGreetingText extends StatelessWidget {
  final String text;

  const MockGreetingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: altSecondary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

// Mock User Name Text
class MockUserNameText extends StatelessWidget {
  final String name;

  const MockUserNameText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        color: secondary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Mock Notification Widget
class MockNotificationIconWithBadge extends StatelessWidget {
  const MockNotificationIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: IconButton(
            icon: const Icon(Icons.notifications_none),
            color: secondary,
            onPressed: () {
              // No action in tutorial/mock
            },
          ),
        ),
        // Notification badge
        Positioned(
          right: 8.w,
          top: 8.h,
          child: Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: statusDanger,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
