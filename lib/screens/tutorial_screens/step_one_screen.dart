import 'package:flutter/material.dart';
import 'package:roadfix/screens/tutorial_screens/step_two_screen.dart';
import 'package:roadfix/widgets/bottom_navbar_widgets/tutorial_navigation_widget.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/screens/tutorial_screens/mock_home_screen.dart';
import 'package:roadfix/widgets/tutorial_widgets/tutorial_overlay.dart';

class TutorialStep1Screen extends StatefulWidget {
  const TutorialStep1Screen({super.key});

  @override
  State<TutorialStep1Screen> createState() => _TutorialStep1ScreenState();
}

class _TutorialStep1ScreenState extends State<TutorialStep1Screen> {
  bool _isTutorialEnabled = true;
  final GlobalKey _photoTabKey = GlobalKey();

  void _goToStep2() {
    setState(() {
      _isTutorialEnabled = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const TutorialStep2Screen();
        },
      ),
    );
  }

  void _skipTutorial() {
    setState(() {
      _isTutorialEnabled = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      enabled: _isTutorialEnabled,
      targetKey: _photoTabKey,
      title: 'Start Reporting',
      description: 'Tap the Photo tab to begin',
      bulletPoints: const ['Tap Photo Icon Below to Start Reporting'],
      actionText: 'Tap Photo Tab',
      currentStep: 1,
      totalSteps: 5,
      cardTop: 150, // Lower on screen - not so high up
      isCardCompact: false, // Regular size for Step 1
      onComplete: _goToStep2,
      onSkip: _skipTutorial,
      child: Scaffold(
        backgroundColor: inputFill,
        body: const MockHomeScreen(withScaffold: false),
        bottomNavigationBar: TutorialNavigationWidget(
          currentIndex: 0, // Home tab is selected
          photoTabKey:
              _photoTabKey, // Pass the key for highlighting the Photo tab
          onTap: (index) {
            if (index == 1) {
              _goToStep2();
            }
          },
        ),
      ),
    );
  }
}
