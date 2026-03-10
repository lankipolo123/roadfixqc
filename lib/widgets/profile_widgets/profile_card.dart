// lib/widgets/profile_widgets/profile_card.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/utils/responsive.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: altSecondary,
                key: ValueKey(avatarUrl),
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Icon(Icons.person, color: secondary, size: 30.r)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: secondary,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12.sp, color: altSecondary),
                    ),
                    Text(
                      user.contactNumber.isNotEmpty
                          ? user.contactNumber
                          : 'No phone number',
                      style: TextStyle(fontSize: 12.sp, color: altSecondary),
                    ),
                    Text(
                      user.address.isNotEmpty
                          ? user.address
                          : 'No address provided',
                      style: TextStyle(fontSize: 12.sp, color: secondary),
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
