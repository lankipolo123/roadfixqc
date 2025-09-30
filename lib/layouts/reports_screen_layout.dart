// layouts/report_screen_layout.dart
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/diagonal_background.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportScreenLayout extends StatelessWidget {
  final String title;
  final bool showBack;
  final Widget filterTabs;
  final Widget content;
  final Widget? floatingWidget; // For pagination FAB

  const ReportScreenLayout({
    super.key,
    required this.title,
    this.showBack = false,
    required this.filterTabs,
    required this.content,
    this.floatingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DiagonalBackgroundLayout(
          child: Scaffold(
            backgroundColor: transparent,
            body: Column(
              children: [
                ModuleHeader(title: title, showBack: showBack),
                Container(
                  width: double.infinity,
                  color: inputFill,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: filterTabs,
                ),
                Expanded(
                  child: Container(
                    color: inputFill,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (floatingWidget != null) floatingWidget!,
      ],
    );
  }

  // Helper method for loading state
  static Widget buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primary),
          SizedBox(height: 16),
          Text('Loading your reports...', style: TextStyle(color: secondary)),
        ],
      ),
    );
  }

  // Helper method for error state
  static Widget buildErrorState({
    required String error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: statusDanger, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading reports:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: statusDanger),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: secondary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper method for empty state
  static Widget buildEmptyState({
    required IconData icon,
    required String message,
    Widget? actionButton,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: secondary.withValues(alpha: 0.5), size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 16),
            actionButton,
          ],
        ],
      ),
    );
  }

  // Helper method for report list with refresh
  static Widget buildReportList({
    required List<Widget> children,
    required VoidCallback onRefresh,
  }) {
    return RefreshIndicator(
      color: primary,
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Reports sorted by date (newest first)',
              style: TextStyle(
                color: secondary.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
