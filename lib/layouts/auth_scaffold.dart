// widgets/auth_widgets/auth_scaffold.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/diagonal_stripes.dart';

class AuthScaffold extends StatelessWidget {
  final Widget topContent;
  final List<Widget> children;
  final double topPadding;

  const AuthScaffold({
    super.key,
    required this.topContent,
    required this.children,
    this.topPadding = 35,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      resizeToAvoidBottomInset: false, // ✅ Prevent shrinking
      body: Stack(
        children: [
          // Background diagonal stripes (decorative only) - MADE TALLER
          const Positioned(
            top: -3,
            left: 0,
            right: 0,
            child: SizedBox(height: 120, child: DiagonalStripes()),
          ),
          const Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: SizedBox(height: 120, child: DiagonalStripes()),
          ),

          // Main content container with margins to show stripes
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 30, // Show bottom stripes
                ),
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    SizedBox(height: topPadding),
                    topContent,
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          30,
                          0,
                          30,
                          24, // ✅ Fixed padding, no viewInsets
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
