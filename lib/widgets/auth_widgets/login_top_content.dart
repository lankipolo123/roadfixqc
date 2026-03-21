import 'package:flutter/material.dart';
import 'package:roadfix/widgets/common_widgets/logo_widget.dart';
import 'package:roadfix/widgets/auth_widgets/title_widget.dart';

class LoginTopContent extends StatelessWidget {
  const LoginTopContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: screenHeight * 0.22,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // ✅ Background image — full width
              RepaintBoundary(
                child: Image.asset(
                  'assets/images/roadwidget4.webp',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  alignment: Alignment.center,
                ),
              ),

              // ✅ Centered Logo
              const RepaintBoundary(child: LogoWidget()),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const TitleWidget(text: "RoadFix"),
      ],
    );
  }
}
