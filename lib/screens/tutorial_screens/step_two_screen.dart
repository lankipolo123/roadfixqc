import 'package:flutter/material.dart';
import 'package:roadfix/screens/tutorial_screens/step_three_screen.dart';
import 'package:roadfix/services/tutorial_service.dart';
import 'package:roadfix/widgets/bottom_navbar_widgets/tutorial_navigation_widget.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/tutorial_widgets/tutorial_overlay.dart';
import 'package:roadfix/widgets/common_widgets/dual_color_text.dart';

class TutorialStep2Screen extends StatefulWidget {
  const TutorialStep2Screen({super.key});

  @override
  State<TutorialStep2Screen> createState() => _TutorialStep2ScreenState();
}

class _TutorialStep2ScreenState extends State<TutorialStep2Screen> {
  bool _isTutorialEnabled = true;
  final GlobalKey _detectButtonKey = GlobalKey();

  void _completeTutorial() {
    setState(() {
      _isTutorialEnabled = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TutorialStep3Screen()),
    );
  }

  Future<void> _skipTutorial() async {
    setState(() {
      _isTutorialEnabled = false;
    });
    await TutorialService.markTutorialSeen();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      enabled: _isTutorialEnabled,
      targetKey: _detectButtonKey,
      title: 'Detect Road Issues',
      description: 'Tap the button to start detecting road issues',
      bulletPoints: const [
        'Tap the detect button',
        'Choose camera or gallery',
        'AI will detect issues',
      ],
      actionText: 'Tap to Detect',
      currentStep: 2,
      totalSteps: 5,
      onComplete: _completeTutorial,
      onSkip: _skipTutorial,
      child: Scaffold(
        backgroundColor: inputFill,
        body: _MockReportTypeScreen(
          detectButtonKey: _detectButtonKey,
          onDetectTap: _completeTutorial,
        ),
        bottomNavigationBar: TutorialNavigationWidget(
          currentIndex: 1,
          onTap: (index) {},
        ),
      ),
    );
  }
}

class _MockReportTypeScreen extends StatelessWidget {
  final GlobalKey detectButtonKey;
  final VoidCallback? onDetectTap;

  const _MockReportTypeScreen({
    required this.detectButtonKey,
    this.onDetectTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoHeight = screenHeight < 700 ? 70.0 : 100.0;
    final circleSize = screenHeight < 700 ? 200.0 : 250.0;
    final iconSize = screenHeight < 700 ? 70.0 : 100.0;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.02),

          // Logo
          Center(
            child: Image.asset(
              'assets/images/roadfix_logo_alt2.webp',
              height: logoHeight,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: logoHeight,
                  width: logoHeight,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.build, color: inputFill, size: 50),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          const DualColorText(
            leftText: 'Report ',
            rightText: 'NOW!',
            leftColor: primary,
            rightColor: secondary,
          ),

          // Big detection circle
          Expanded(
            child: Center(
              child: GestureDetector(
                key: detectButtonKey,
                onTap: onDetectTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      foregroundPainter: const _StripedCircleBorderPainter(
                        borderWidth: 6,
                        stripeColor: altSecondary,
                        backgroundColor: primary,
                        stripeWidth: 12,
                        gapWidth: 12,
                      ),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: inputFill,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.question_mark_rounded,
                                size: iconSize,
                                color: secondary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Detect Road Issues',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Tap to detect potholes, cracks, poles, and roadblocks',
                        style: TextStyle(fontSize: 14, color: altSecondary),
                        textAlign: TextAlign.center,
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

class _StripedCircleBorderPainter extends CustomPainter {
  final double borderWidth;
  final Color stripeColor;
  final Color backgroundColor;
  final double stripeWidth;
  final double gapWidth;

  const _StripedCircleBorderPainter({
    required this.borderWidth,
    required this.stripeColor,
    required this.backgroundColor,
    required this.stripeWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - borderWidth;

    final ringPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius))
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.save();
    canvas.clipPath(ringPath);

    final paint = Paint()..isAntiAlias = false;

    paint.color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = stripeColor;
    final totalWidth = stripeWidth + gapWidth;
    final double hypotenuse = size.height * 3.5;

    for (double x = -hypotenuse; x < size.width + hypotenuse; x += totalWidth) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + stripeWidth, 0);
      path.lineTo(x + stripeWidth - size.height, size.height);
      path.lineTo(x - size.height, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
