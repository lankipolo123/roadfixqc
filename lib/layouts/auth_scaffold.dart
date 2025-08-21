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
    this.topPadding = 40,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: inputFill,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background diagonal stripes (decorative only)
          const Positioned(
            top: -3,
            left: 0,
            right: 0,
            child: SizedBox(height: 100, child: DiagonalStripes()),
          ),
          const Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: SizedBox(height: 100, child: DiagonalStripes()),
          ),

          // Main content container (no margins, but still rounded)
          Positioned.fill(
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(
                    24,
                  ), // Keep rounded corners
                ),
                child: Column(
                  children: [
                    SizedBox(height: topPadding),
                    topContent,
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          30,
                          0,
                          30,
                          viewInsets + 24,
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
