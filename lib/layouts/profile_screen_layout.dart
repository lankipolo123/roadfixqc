// layouts/profile_screen_layout.dart
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/diagonal_background.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/themes.dart';

class ProfileScreenLayout extends StatelessWidget {
  final String title;
  final bool showBack;
  final Widget Function(BuildContext context) contentBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? errorBuilder;
  final Widget Function(BuildContext context)? noDataBuilder;

  const ProfileScreenLayout({
    super.key,
    required this.title,
    this.showBack = false,
    required this.contentBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.noDataBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DiagonalBackgroundLayout(
      child: Scaffold(
        backgroundColor: transparent,
        body: Column(
          children: [
            ModuleHeader(title: title, showBack: showBack),
            Expanded(
              child: Container(
                color: inputFill,
                child: contentBuilder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for common loading state
  static Widget buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: primary));
  }

  // Helper method for common error state
  static Widget buildErrorState({
    String title = 'Failed to load profile',
    String subtitle = 'Please try again later',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: statusDanger),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: secondary),
          ),
        ],
      ),
    );
  }

  // Helper method for common no data state
  static Widget buildNoDataState({
    String title = 'No profile data found',
    IconData icon = Icons.person_outline,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: secondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for scrollable content
  static Widget buildScrollableContent({
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(children: children),
    );
  }
}
