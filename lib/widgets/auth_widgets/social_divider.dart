import 'package:flutter/material.dart';
import '../themes.dart';

class SocialDivider extends StatelessWidget {
  const SocialDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: primary, thickness: 1.5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "or",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: Divider(color: primary, thickness: 1.5)),
        ],
      ),
    );
  }
}
