import 'package:flutter/material.dart';
import 'package:roadfix/utils/pagination_helper.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
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
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: currentPage > 1 ? Colors.black87 : Colors.grey,
                onPressed: currentPage > 1
                    ? () => onPageSelected(currentPage - 1)
                    : null,
              ),

              // Page numbers
              ...List.generate(pageCount, (index) {
                final page = index + 1;
                final isSelected = page == currentPage;

                return GestureDetector(
                  onTap: () => onPageSelected(page),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }),

              // Next Arrow
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
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
}
