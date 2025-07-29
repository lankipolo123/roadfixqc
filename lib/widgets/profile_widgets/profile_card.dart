import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_summary.dart';
import 'package:roadfix/widgets/themes.dart'; // ✅ Import your theme colors

class ProfileCard extends StatelessWidget {
  final ProfileSummary user;
  final Widget? summary;

  const ProfileCard({super.key, required this.user, this.summary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: inputFill, // ✅ Use input background color (white)
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8), // Reduced padding from 12 to 8
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: avatar and user info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.imageUrl.isNotEmpty
                        ? NetworkImage(user.imageUrl)
                        : null,
                    child: user.imageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: secondary,
                          ) // ✅ Black icon
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: secondary, // ✅ Black
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: altSecondary, // ✅ Faded black
                          ),
                        ),
                        Text(
                          user.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: altSecondary,
                          ),
                        ),
                        Text(
                          user.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: secondary, // ✅ Stronger for location
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (summary != null) ...[
                const SizedBox(height: 12),
                summary!,
              ], // Reduced height from 16 to 12
            ],
          ),
        ),
      ),
    );
  }
}
