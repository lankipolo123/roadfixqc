// lib/widgets/common_widgets/notification_icon_with_badge.dart
import 'package:flutter/material.dart';
import 'package:roadfix/services/notification_service.dart';
import 'package:roadfix/widgets/themes.dart';

class NotificationIconWithBadge extends StatelessWidget {
  final VoidCallback onPressed;
  final NotificationService _notificationService = NotificationService();

  NotificationIconWithBadge({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Use the dedicated unread count stream instead of combining two streams
    return StreamBuilder<int>(
      stream: _notificationService.getUnreadNotificationCountStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildNotificationIcon(0);
        }

        final unreadCount = snapshot.data ?? 0;
        return _buildNotificationIcon(unreadCount);
      },
    );
  }

  Widget _buildNotificationIcon(int notificationCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: transparent,
          shape: const CircleBorder(),
          child: IconButton(
            icon: const Icon(Icons.notifications_none),
            color: secondary,
            onPressed: onPressed,
          ),
        ),
        if (notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: inputFill, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
