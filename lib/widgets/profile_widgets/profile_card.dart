// lib/widgets/profile_widgets/profile_card.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/widgets/themes.dart';

class ProfileCard extends StatelessWidget {
  final UserModel user;

  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final cacheBuster =
        user.lastUpdated ??
        (user.joinedAt != null
            ? user.joinedAt!.millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch);

    final avatarUrl = user.userProfile.isNotEmpty
        ? "${user.userProfile}?v=$cacheBuster"
        : '';

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: inputFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: altSecondary,
                key: ValueKey(avatarUrl),
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: secondary, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondary,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 12, color: altSecondary),
                    ),
                    Text(
                      user.contactNumber.isNotEmpty
                          ? user.contactNumber
                          : 'No phone number',
                      style: const TextStyle(fontSize: 12, color: altSecondary),
                    ),
                    Text(
                      user.address.isNotEmpty
                          ? user.address
                          : 'No address provided',
                      style: const TextStyle(fontSize: 12, color: secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
