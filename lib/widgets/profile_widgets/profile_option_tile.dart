import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_option_model.dart';
import 'package:roadfix/widgets/themes.dart'; // contains secondary, altSecondary, inputFill

class ProfileOptionTile extends StatelessWidget {
  final ProfileOption option;

  const ProfileOptionTile({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final TextStyle labelStyle =
        option.labelStyle ??
        textTheme.bodyMedium!.copyWith(fontSize: 14, color: secondary);

    return Material(
      color: transparent, // Let parent color (e.g., inputFill) show
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(10),
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
              Expanded(child: Text(option.label, style: labelStyle)),
              const Icon(Icons.chevron_right, size: 20, color: altSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
