import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart'; // for primary, secondary, altSecondary

class NavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
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
            _navItem(Icons.home, 'Home', 0),
            _navItem(
              Icons.camera_alt,
              'Photo',
              1,
            ), // You can rename this to "Map" if needed
            _navItem(Icons.receipt_long, 'Reports', 2),
            _navItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: isSelected ? secondary : altSecondary),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? secondary : altSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
