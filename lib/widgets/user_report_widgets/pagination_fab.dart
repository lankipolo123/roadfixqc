import 'package:flutter/material.dart';
import 'package:roadfix/utils/pagination_helper.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class PaginationFAB extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final void Function(int) onPageSelected;

  const PaginationFAB({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBottomMargin = fabSpacing(context);

    return IgnorePointer(
      ignoring: pageCount <= 1,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(bottom: effectiveBottomMargin),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Arrow
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 18.r),
                color: currentPage > 1 ? Colors.black87 : Colors.grey,
                onPressed: currentPage > 1
                    ? () => onPageSelected(currentPage - 1)
                    : null,
              ),

              // Page numbers (truncated with ellipsis)
              ..._buildPageItems(),

              // Next Arrow
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18.r),
                color: currentPage < pageCount ? Colors.black87 : Colors.grey,
                onPressed: currentPage < pageCount
                    ? () => onPageSelected(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build page number buttons with ellipsis truncation.
  /// Shows: first, last, current, and 1 neighbor on each side.
  /// Example: 1 ... 4 5 6 ... 20
  List<Widget> _buildPageItems() {
    const int sidePagesCount = 1;
    final Set<int> pages = {};

    // Always include first and last
    pages.add(1);
    pages.add(pageCount);

    // Include current page and its neighbors
    for (int i = currentPage - sidePagesCount;
        i <= currentPage + sidePagesCount;
        i++) {
      if (i >= 1 && i <= pageCount) pages.add(i);
    }

    final sorted = pages.toList()..sort();
    final List<Widget> items = [];

    for (int i = 0; i < sorted.length; i++) {
      // Add ellipsis if there's a gap
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        items.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }

      final page = sorted[i];
      final isSelected = page == currentPage;
      items.add(
        GestureDetector(
          onTap: () => onPageSelected(page),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }
}
