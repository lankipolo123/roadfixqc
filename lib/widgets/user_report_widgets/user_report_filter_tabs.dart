import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ReportFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Pending', 'Approved', 'Resolved', 'Rejected'];

    return Row(
      children: filters.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;

        return Expanded(
          // 🔑 each filter takes equal width
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selectedIndex == index ? primary : inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selectedIndex == index ? inputFill : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
