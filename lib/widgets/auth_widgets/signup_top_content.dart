import 'package:flutter/material.dart';
import 'package:roadfix/widgets/common_widgets/logo_widget.dart';
import 'package:roadfix/widgets/auth_widgets/title_widget.dart';

class SignupTopContent extends StatelessWidget {
  const SignupTopContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double sectionHeight = screenHeight * 0.22;

    return SizedBox(
      width: double.infinity,
      height: sectionHeight,
      child: const Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: Image(
              image: AssetImage('assets/images/roadwidget2.webp'),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: SizedBox(
                height: 120, // ⬅️ adjust for logo size
                child: LogoWidget(),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TitleWidget(text: "Create an Account"),
          ),
        ],
      ),
    );
  }
}
