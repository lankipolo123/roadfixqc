// lib/widgets/bottom_navbar_widgets/mock_navigation.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class MockNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final int?
  highlightIndex; // Which tab should be highlighted/enlarged for tutorial

  const MockNavigationWidget({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.highlightIndex,
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
            _navItem(Icons.camera_alt, 'Photo', 1),
            _navItem(Icons.receipt_long, 'Reports', 2),
            _navItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final shouldHighlight = highlightIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap?.call(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: shouldHighlight
                      ? 28
                      : 22, // Larger size for highlighted tab
                  color: shouldHighlight
                      ? secondary
                      : (isSelected ? secondary : altSecondary),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: shouldHighlight
                      ? 12
                      : 10, // Larger text for highlighted tab
                  fontWeight: shouldHighlight
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: shouldHighlight
                      ? secondary
                      : (isSelected ? secondary : altSecondary),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
