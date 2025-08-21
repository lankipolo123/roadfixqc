import 'package:flutter/material.dart';
import 'package:roadfix/utils/pagination_helper.dart';
import 'package:roadfix/widgets/themes.dart';
// 👈 Import the helper

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
    final effectiveBottomMargin = fabSpacing(context); // 👈 Use the helper

    return IgnorePointer(
      ignoring: pageCount <= 1,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(bottom: effectiveBottomMargin),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withAlpha(204),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pageCount, (index) {
              final page = index + 1;
              final isSelected = page == currentPage;

              return GestureDetector(
                onTap: () => onPageSelected(page),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color: isSelected ? secondary : altSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
