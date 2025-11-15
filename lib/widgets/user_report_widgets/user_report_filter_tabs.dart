import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_constant.dart';
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
    const filters = ReportConstants.filterLabels;

    final firstRow = filters.sublist(0, 4);
    final secondRow = filters.sublist(4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterRow(firstRow, 0),
        const SizedBox(height: 8),
        _buildFilterRow(secondRow, 4),
      ],
    );
  }

  Widget _buildFilterRow(List<String> rowFilters, int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: rowFilters.asMap().entries.map((entry) {
        final localIndex = entry.key;
        final globalIndex = startIndex + localIndex;
        final label = entry.value;
        final isActive = selectedIndex == globalIndex;
        final filterColor = _getFilterColor(globalIndex);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onChanged(globalIndex),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: isActive ? secondary : Colors.transparent,
                  border: Border.all(
                    color: isActive ? secondary : filterColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? primary : filterColor,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getFilterColor(int index) {
    switch (index) {
      case 0:
        return primary;
      case 1:
        return statusWarning;
      case 2:
        return statusSuccess;
      case 3:
        return statusDanger;
      case 4:
        return purpleAccent;
      case 5:
        return statusResolved;
      case 6:
        return statusDanger;
      default:
        return secondary;
    }
  }
}
