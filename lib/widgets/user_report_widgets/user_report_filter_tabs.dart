import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_constant.dart';
import 'package:roadfix/utils/responsive.dart';
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
        SizedBox(height: 8.h),
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
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: GestureDetector(
              onTap: () => onChanged(globalIndex),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  color: isActive ? secondary : Colors.transparent,
                  border: Border.all(
                    color: isActive ? secondary : filterColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? primary : filterColor,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12.sp,
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
      case 0: // All
        return primary;
      case 1: // Pending
        return statusWarning;
      case 2: // Accepted
        return statusSuccess;
      case 3: // Invalid
        return statusDanger;
      case 4: // In Progress
        return purpleAccent;
      case 5: // Resolved
        return statusResolved;
      default:
        return secondary;
    }
  }
}
