import 'package:flutter/material.dart';
import 'package:roadfix/screens/tutorial_screens/step_five_screen.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/tutorial_widgets/tutorial_overlay.dart';

// Tutorial Step 4: Send Report Flow
class TutorialStep4Screen extends StatefulWidget {
  const TutorialStep4Screen({super.key});

  @override
  State<TutorialStep4Screen> createState() => _TutorialStep4ScreenState();
}

class _TutorialStep4ScreenState extends State<TutorialStep4Screen> {
  final bool _isTutorialEnabled = true;
  int _currentStep = 0;

  // Keys for different tutorial targets
  final GlobalKey _imagePreviewKey = GlobalKey();
  final GlobalKey _locationFieldKey = GlobalKey();
  final GlobalKey _descriptionFieldKey = GlobalKey();
  final GlobalKey _submitButtonKey = GlobalKey();

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'targetKey': null, // Will be set to _imagePreviewKey
      'title': 'Review Image',
      'description': 'This is your captured photo',
      'actionText': 'Click the Image ',
      'cardBottom': 80.0, // Position card at bottom
      'cardTop': null,
      'gesturePosition': 'bottom', // Gesture icons above target
      'gestureOffset': 20.0,
    },
    {
      'targetKey': null, // Will be set to _locationFieldKey
      'title': 'Add Location',
      'description': 'Tap the GPS button for your location',
      'actionText': 'Tap GPS',
      'cardTop': 250.0, // Keep same position
      'cardBottom': null,
      'gesturePosition': 'bottom', // Gesture icons to the right
      'gestureOffset': 20.00,
    },
    {
      'targetKey': null, // Will be st to _descriptionFieldKey
      'title': 'Describe Issue',
      'description': 'Add details about the road problem',
      'actionText': 'Tap to Type',
      'cardTop': 100.0, // Position card on top
      'cardBottom': null,
      'gesturePosition': 'top', // Default - above the highlight
      'gestureOffset': 40.0,
    },
    {
      'targetKey': null, // Will be set to _submitButtonKey
      'title': 'Submit Report',
      'description': 'Send your report to help fix the road',
      'actionText': 'Submit Now',
      'cardBottom': 80.0, // Position card at bottom
      'cardTop': null,
      'gesturePosition': 'top', // Default gesture position
      'gestureOffset': 45.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set the target keys after widget creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _tutorialSteps[0]['targetKey'] = _imagePreviewKey;
        _tutorialSteps[1]['targetKey'] = _locationFieldKey;
        _tutorialSteps[2]['targetKey'] = _descriptionFieldKey;
        _tutorialSteps[3]['targetKey'] = _submitButtonKey;
      });
    });
  }

  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Tutorial complete - navigate to congratulations screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TutorialStep5Screen()),
      );
    }
  }

  void _skipTutorial() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TutorialStep5Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTutorial = _tutorialSteps[_currentStep];

    return TutorialOverlay(
      key: ValueKey(_currentStep),
      enabled: _isTutorialEnabled,
      targetKey: currentTutorial['targetKey'],
      title: currentTutorial['title'],
      description: currentTutorial['description'],
      actionText: currentTutorial['actionText'],
      currentStep: 4,
      totalSteps: 5,
      cardTop: currentTutorial['cardTop'],
      cardBottom: currentTutorial['cardBottom'],
      gesturePosition: currentTutorial['gesturePosition'],
      gestureOffset: currentTutorial['gestureOffset'],
      onComplete: _nextStep,
      onSkip: _skipTutorial,
      child: _buildSendReportScreen(),
    );
  }

  Widget _buildSendReportScreen() {
    return Scaffold(
      backgroundColor: inputFill,
      appBar: AppBar(
        title: const Text(
          "Submit a Report",
          style: TextStyle(color: inputFill),
        ),
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: inputFill),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            Center(
              child: Container(
                key: _imagePreviewKey,
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: altSecondary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: altSecondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Icon(Icons.image, size: 60, color: inputFill),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location field
            _buildLocationField(),
            const SizedBox(height: 16),

            // Description field
            _buildDescriptionField(),
            const SizedBox(height: 32),

            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: altSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(fontSize: 16, color: secondary),
          decoration: InputDecoration(
            hintText: 'Enter location or tap GPS button',
            hintStyle: const TextStyle(color: altSecondary, fontSize: 16),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: altSecondary,
            ),
            suffixIcon: IconButton(
              key: _locationFieldKey,
              icon: const Icon(Icons.gps_fixed, color: altSecondary),
              onPressed: () {}, // Mock - no functionality needed
              tooltip: 'Get current location',
            ),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 2,
          minLines: 1,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: altSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: _descriptionFieldKey,
          style: const TextStyle(fontSize: 16, color: secondary),
          decoration: InputDecoration(
            hintText: 'Describe the road issue in detail...',
            hintStyle: const TextStyle(color: altSecondary, fontSize: 16),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 4,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        key: _submitButtonKey,
        onPressed: () {}, // Mock - no functionality needed
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: inputFill,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Submit Report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
