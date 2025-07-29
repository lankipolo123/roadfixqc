import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_option_model.dart';

class ProfileOptionTile extends StatelessWidget {
  final ProfileOption option;

  const ProfileOptionTile({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: option.iconBackgroundColor,
              child: Icon(option.icon, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.label,
                style:
                    option.labelStyle?.copyWith(fontSize: 14) ??
                    const TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(0, 0, 0, 0.867),
                    ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color.fromARGB(255, 9, 9, 9),
            ),
          ],
        ),
      ),
    );
  }
}
