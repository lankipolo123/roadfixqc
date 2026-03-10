// widgets/auth_widgets/auth_scaffold.dart
import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: -3,
            left: 0,
            right: 0,
            child: SizedBox(height: 120.h, child: const DiagonalStripes()),
          ),
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: SizedBox(height: 120.h, child: const DiagonalStripes()),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.only(bottom: 30.h),
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  children: [
                    SizedBox(height: topPadding.h),
                    topContent,
                    SizedBox(height: 20.h),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          30.w, 0, 30.w, 24.h,
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
