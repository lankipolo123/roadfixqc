// lib/widgets/home_widgets/home_header_widgets/mock_home_header.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class MockHomeHeader extends StatelessWidget {
  const MockHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: inputFill, // Transparent background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          const MockUserAvatar(radius: 24, showBorder: true),
          const SizedBox(width: 12),

          // Greeting and name
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MockGreetingText(text: 'Hi, Welcome'),
                SizedBox(height: 2),
                MockUserNameText(name: 'John Doe'),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Location Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 12, color: secondary),
                SizedBox(width: 4),
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 10,
                    color: secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

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
      style: const TextStyle(
        color: altSecondary,
        fontSize: 14,
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
      style: const TextStyle(
        color: secondary,
        fontSize: 16,
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
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
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
