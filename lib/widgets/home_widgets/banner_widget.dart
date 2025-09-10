import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/dual_color_text.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Background gradient bar (positioned behind)
            Container(
              height: 96, // Same height as main banner
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [statusDanger, orangeAccent, statusSuccess],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Main banner (on top)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [secondary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/icons/roadFixLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const DualColorText(
                          leftText: 'ROAD',
                          rightText: 'FIX',
                          leftColor: inputFill,
                          rightColor: primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 12,
                        ),

                        const SizedBox(height: 12),

                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '•Detect ',
                                style: TextStyle(
                                  color: statusDanger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: '•Report ',
                                style: TextStyle(
                                  color: orangeAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: '•Action ',
                                style: TextStyle(
                                  color: statusSuccess,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: '•ROAD',
                                style: TextStyle(
                                  color: inputFill,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'FIXED',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Separate gradient bar below
      ],
    );
  }
}
