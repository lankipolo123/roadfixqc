// lib/widgets/profile_widgets/profile_card.dart (CLEAN - NO DEBUG)
import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_summary.dart';
import 'package:roadfix/widgets/themes.dart';

class ProfileCard extends StatefulWidget {
  final ProfileSummary user;
  final Widget? summary;

  const ProfileCard({super.key, required this.user, this.summary});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String? _cachedImageUrl;

  @override
  void initState() {
    super.initState();
    _cachedImageUrl = widget.user.imageUrl;
  }

  @override
  void didUpdateWidget(ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.imageUrl != widget.user.imageUrl) {
      setState(() {
        _cachedImageUrl = widget.user.imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: inputFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: altSecondary,
                    key: ValueKey(_cachedImageUrl),
                    backgroundImage:
                        _cachedImageUrl != null && _cachedImageUrl!.isNotEmpty
                        ? NetworkImage(_cachedImageUrl!)
                        : null,
                    child: _cachedImageUrl == null || _cachedImageUrl!.isEmpty
                        ? const Icon(Icons.person, color: secondary, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: secondary,
                          ),
                        ),
                        Text(
                          widget.user.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: altSecondary,
                          ),
                        ),
                        Text(
                          widget.user.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: altSecondary,
                          ),
                        ),
                        Text(
                          widget.user.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (widget.summary != null) ...[
                const SizedBox(height: 12),
                widget.summary!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
