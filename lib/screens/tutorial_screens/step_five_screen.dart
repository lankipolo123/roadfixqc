// lib/screens/tutorial_screens/tutorial_step5_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class TutorialStep5Screen extends StatelessWidget {
  const TutorialStep5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
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
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),

              const SizedBox(height: 32),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 40),

              // What you learned section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 16),
                    _buildLearningItem(
                      Icons.home_outlined,
                      'Navigate the home screen',
                    ),
                    const SizedBox(height: 12),
                    _buildLearningItem(
                      Icons.camera_alt_outlined,
                      'Take photos of road issues',
                    ),
                    const SizedBox(height: 12),
                    _buildLearningItem(
                      Icons.location_on_outlined,
                      'Add location details',
                    ),
                    const SizedBox(height: 12),
                    _buildLearningItem(
                      Icons.send_outlined,
                      'Submit reports to help fix roads',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

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

              const Spacer(),

              // Start using app button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to main app - replace with your main screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home', // Replace with your main route
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

              const SizedBox(height: 16),

              // Skip to main app text button
              TextButton(
                onPressed: () {
                  // Same navigation as above - backup option
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home', // Replace with your main route
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
