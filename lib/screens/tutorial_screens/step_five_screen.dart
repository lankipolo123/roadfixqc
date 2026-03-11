// lib/screens/tutorial_screens/tutorial_step5_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class TutorialStep5Screen extends StatelessWidget {
  const TutorialStep5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenHeight < 700 ? 80.0 : 120.0;
    final checkSize = screenHeight < 700 ? 40.0 : 60.0;

    return Scaffold(
      backgroundColor: inputFill,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        // Success Icon
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: statusSuccess,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusSuccess.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(Icons.check, size: checkSize, color: Colors.white),
                        ),

                        const SizedBox(height: 24),

                        // Congratulations Title
                        const Text(
                          'Congratulations!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        const Text(
                          'You\'ve completed the tutorial',
                          style: TextStyle(
                            fontSize: 18,
                            color: altSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // What you learned section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'What you learned:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildLearningItem(
                                Icons.home_outlined,
                                'Navigate the home screen',
                              ),
                              const SizedBox(height: 10),
                              _buildLearningItem(
                                Icons.camera_alt_outlined,
                                'Take photos of road issues',
                              ),
                              const SizedBox(height: 10),
                              _buildLearningItem(
                                Icons.location_on_outlined,
                                'Add location details',
                              ),
                              const SizedBox(height: 10),
                              _buildLearningItem(
                                Icons.send_outlined,
                                'Submit reports to help fix roads',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Motivational message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusSuccess.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusSuccess.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: statusSuccess,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You\'re now ready to help improve road safety in your community!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Buttons pinned at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: secondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Using RoadFix',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Continue to App',
                        style: TextStyle(
                          color: altSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: statusSuccess,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
