import 'package:flutter/material.dart';
import 'package:roadfix/screens/tutorial_screens/step_three_screen.dart';
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
  final GlobalKey _categoryButton1Key = GlobalKey();
  final GlobalKey _categoryButton2Key = GlobalKey();
  final GlobalKey _categoryButton3Key = GlobalKey();

  void _completeTutorial() {
    setState(() {
      _isTutorialEnabled = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TutorialStep3Screen()),
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
      targetKeys: [
        _categoryButton1Key,
        _categoryButton2Key,
        _categoryButton3Key,
      ],
      title: 'Choose Category',
      description: 'Select what type of road issue you found',
      bulletPoints: const [
        'Pick matching category',
        'Read descriptions carefully',
        'Tap any category to continue',
      ],
      actionText: 'Tap Category',
      currentStep: 2,
      totalSteps: 5,
      onComplete: _completeTutorial,
      onSkip: _skipTutorial,
      child: Scaffold(
        backgroundColor: inputFill,
        body: MockReportTypeScreenWithTutorial(
          categoryButtonKeys: [
            _categoryButton1Key,
            _categoryButton2Key,
            _categoryButton3Key,
          ],
          onCategoryTap: _completeTutorial,
        ),
        bottomNavigationBar: TutorialNavigationWidget(
          currentIndex: 1, // Photo tab is selected
          onTap: (index) {
            // No navigation during tutorial
          },
          // No keys needed for step 2 since nav isn't being highlighted
        ),
      ),
    );
  }
}

class MockReportTypeScreenWithTutorial extends StatelessWidget {
  final List<GlobalKey> categoryButtonKeys;
  final VoidCallback? onCategoryTap;

  const MockReportTypeScreenWithTutorial({
    super.key,
    required this.categoryButtonKeys,
    this.onCategoryTap,
  });

  // Mock data copying the structure from your report_categories.dart
  static const List<Map<String, dynamic>> _mockCategories = [
    {
      'label': 'Potholes',
      'description': 'A huge crack or hole in the road',
      'imagePath': 'assets/images/pothole_report.webp',
    },
    {
      'label': 'Utility Poles',
      'description': 'Leaning or fallen utility pole',
      'imagePath': 'assets/images/utility_pole_report.webp',
    },
    {
      'label': 'Road Concerns',
      'description': 'General road issues',
      'imagePath': 'assets/images/road_concerns.webp',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Logo
          Center(
            child: Image.asset(
              'assets/images/roadfix_logo_alt2.webp',
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
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

          const SizedBox(height: 24),

          // Report category list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _mockCategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final category = _mockCategories[index];
                return _buildReportCategoryButton(
                  category['label']!,
                  category['description']!,
                  category['imagePath']!,
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCategoryButton(
    String label,
    String description,
    String imagePath,
    int index,
  ) {
    // All category buttons get keys for targeting
    GlobalKey? buttonKey;
    if (index < categoryButtonKeys.length) {
      buttonKey = categoryButtonKeys[index];
    }

    return InkWell(
      key: buttonKey,
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: secondary, width: 1),
          boxShadow: [
            BoxShadow(
              color: secondary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: transparent, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: altSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Arrow icon with background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: inputFill,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
