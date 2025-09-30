// lib/widgets/profile_widgets/profile_option_tile.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_option_model.dart';
import 'package:roadfix/widgets/themes.dart';

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
      color: transparent,
      child: InkWell(
        onTap: option.mode == ProfileOptionMode.toggle ? null : option.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: option.iconBackgroundColor,
                child: Icon(option.icon, color: inputFill, size: 12),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(option.label, style: labelStyle)),
              _buildTrailingWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingWidget() {
    // If custom trailing widget is provided, use it
    if (option.trailing != null) {
      return option.trailing!;
    }

    // Build trailing based on mode
    switch (option.mode) {
      case ProfileOptionMode.toggle:
        return Switch(
          value: option.toggleValue ?? false,
          onChanged: option.onToggleChanged,
          activeColor: inputFill, // Thumb color when ON
          activeTrackColor: statusSuccess, // Track color when ON
          inactiveThumbColor: inputFill, // Thumb color when OFF
          inactiveTrackColor: secondary, // Track color when OFF
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashRadius: 10,
        );

      case ProfileOptionMode.iconOnly:
        return Icon(
          option.trailingIcon ?? Icons.check_circle,
          size: 10,
          color: option.trailingIconColor ?? statusSuccess,
        );

      case ProfileOptionMode.normal:
        return const Icon(Icons.chevron_right, size: 20, color: altSecondary);
    }
  }
}
