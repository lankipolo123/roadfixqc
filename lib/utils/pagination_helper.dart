import 'package:flutter/material.dart';

List<T> paginate<T>({
  required List<T> items,
  required int page,
  required int itemsPerPage,
}) {
  final start = (page - 1) * itemsPerPage;
  if (start >= items.length) return [];

  final end = start + itemsPerPage;
  return items.sublist(start, end > items.length ? items.length : end);
}

int totalPages({required int itemCount, required int itemsPerPage}) {
  return (itemCount / itemsPerPage).ceil();
}

/// Calculates the appropriate bottom spacing for FABs to prevent overlap
/// with bottom navigation bars or system UI elements
double fabSpacing(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);

  // Get bottom padding (includes system navigation bar)
  final bottomPadding = mediaQuery.padding.bottom;

  // Standard bottom navigation bar height (typically 60-80px)
  const standardNavBarHeight = 20.0;

  // Additional spacing for visual breathing room
  const additionalSpacing = 6.0;

  // Calculate total spacing needed
  final totalSpacing = bottomPadding + standardNavBarHeight + additionalSpacing;

  // Ensure minimum spacing even on devices without bottom navigation
  const minimumSpacing = 50.0;

  return totalSpacing > minimumSpacing ? totalSpacing : minimumSpacing;
}
