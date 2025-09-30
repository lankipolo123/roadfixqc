// layouts/home_screen_layout.dart
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/diagonal_background.dart';
import 'package:roadfix/widgets/themes.dart';

class HomeScreenLayout extends StatelessWidget {
  final Widget header;
  final List<Widget> children;

  const HomeScreenLayout({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return DiagonalBackgroundLayout(
      child: Column(
        children: [
          header,
          Expanded(
            child: Container(
              color: inputFill,
              child: SingleChildScrollView(child: Column(children: children)),
            ),
          ),
        ],
      ),
    );
  }
}
