// Create a separate file: widgets/tutorial_widgets/tutorial_navigation_widget.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class TutorialNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final GlobalKey? photoTabKey; // Optional key for tutorial targeting
  final GlobalKey? homeTabKey; // Optional key for tutorial targeting
  final GlobalKey? reportsTabKey; // Optional key for tutorial targeting
  final GlobalKey? profileTabKey; // Optional key for tutorial targeting

  const TutorialNavigationWidget({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.photoTabKey,
    this.homeTabKey,
    this.reportsTabKey,
    this.profileTabKey,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: primary,
      elevation: 0,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0, homeTabKey),
            _buildNavItem(Icons.camera_alt, 'Photo', 1, photoTabKey),
            _buildNavItem(Icons.receipt_long, 'Reports', 2, reportsTabKey),
            _buildNavItem(Icons.person, 'Profile', 3, profileTabKey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, GlobalKey? key) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: Container(
        key: key,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onTap?.call(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? secondary
                        : altSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: isSelected
                          ? secondary
                          : altSecondary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
