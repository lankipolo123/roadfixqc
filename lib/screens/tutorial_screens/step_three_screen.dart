import 'package:flutter/material.dart';
import 'package:roadfix/widgets/tutorial_widgets/tutorial_overlay.dart';
import 'package:roadfix/screens/tutorial_screens/step_four_screen.dart';

enum TutorialStep3State { takePhoto, acceptPhoto }

class TutorialStep3Screen extends StatefulWidget {
  const TutorialStep3Screen({super.key});

  @override
  State<TutorialStep3Screen> createState() => _TutorialStep3ScreenState();
}

class _TutorialStep3ScreenState extends State<TutorialStep3Screen> {
  TutorialStep3State _currentState = TutorialStep3State.takePhoto;
  bool _isTutorialEnabled = true;

  // Keys for different tutorial targets
  final GlobalKey _captureButtonKey = GlobalKey();
  final GlobalKey _acceptButtonKey = GlobalKey();

  void _onPhotoTaken() {
    // Transition to photo acceptance state
    setState(() {
      _currentState = TutorialStep3State.acceptPhoto;
      _isTutorialEnabled = true; // Keep tutorial enabled for new instructions
    });
  }

  void _acceptPhoto() {
    setState(() {
      _isTutorialEnabled = false;
    });

    // Navigate to next step
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TutorialStep4Screen()),
    );
  }

  void _rejectPhoto() {
    // Go back to camera state
    setState(() {
      _currentState = TutorialStep3State.takePhoto;
      _isTutorialEnabled = true;
    });
  }

  void _skipTutorial() {
    setState(() {
      _isTutorialEnabled = false;
    });
    Navigator.pop(context);
  }

  void _completeTutorial() {
    if (_currentState == TutorialStep3State.takePhoto) {
      _onPhotoTaken();
    } else if (_currentState == TutorialStep3State.acceptPhoto) {
      _acceptPhoto();
    }
  }

  // Get tutorial configuration based on current state
  Map<String, dynamic> _getTutorialConfig() {
    switch (_currentState) {
      case TutorialStep3State.takePhoto:
        return {
          'targetKey': _captureButtonKey,
          'title': 'Take Photo',
          'description': 'Capture the road issue',
          'bulletPoints': [
            'Position camera at issue',
            'Tap white circle to capture',
            'Make sure issue is visible',
          ],
          'actionText': 'Tap to Capture',
          'cardTop': 80.0,
        };
      case TutorialStep3State.acceptPhoto:
        return {
          'targetKey': _acceptButtonKey,
          'title': 'Accept Photo',
          'description': 'Tap green button',
          'bulletPoints': null,
          'actionText': 'Accept the Image',
          'cardTop': 90.0,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorialConfig = _getTutorialConfig();

    return TutorialOverlay(
      key: ValueKey(_currentState), // Force rebuild when state changes
      enabled: _isTutorialEnabled,
      targetKey: tutorialConfig['targetKey'],
      title: tutorialConfig['title'],
      description: tutorialConfig['description'],
      bulletPoints: tutorialConfig['bulletPoints'],
      actionText: tutorialConfig['actionText'],
      currentStep: 3,
      totalSteps: 5,
      cardTop: tutorialConfig['cardTop'],
      onComplete: _completeTutorial,
      onSkip: _skipTutorial,
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentState) {
      case TutorialStep3State.takePhoto:
        return _buildCameraScreen();
      case TutorialStep3State.acceptPhoto:
        return _buildPhotoAcceptanceScreen();
    }
  }

  Widget _buildCameraScreen() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera viewfinder - full screen like real camera
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[800]!, Colors.grey[900]!],
                ),
              ),
              child: _buildCameraView(),
            ),
          ),

          // Top status bar area with camera controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Camera controls
                      Row(
                        children: [
                          _buildTopIcon(Icons.flash_auto),
                          const SizedBox(width: 16),
                          _buildTopIcon(Icons.exposure),
                          const SizedBox(width: 16),
                          _buildTopIcon(Icons.crop_3_2),
                        ],
                      ),
                      // Right side controls
                      _buildTopIcon(Icons.settings),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom camera controls area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera modes
                    SizedBox(height: 40, child: _buildCameraModes()),
                    // Main controls - only camera controls
                    SizedBox(height: 80, child: _buildCameraControls()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoAcceptanceScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo - positioned below the instruction card
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 550,
              color: Colors.grey[600],
              child: const Center(
                child: Icon(Icons.image, size: 100, color: Colors.white54),
              ),
            ),
          ),

          // Buttons at bottom
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // X (Reject)
                GestureDetector(
                  onTap: _rejectPhoto,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                // Check (Accept)
                GestureDetector(
                  key: _acceptButtonKey,
                  onTap: _acceptPhoto,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Simulated camera feed
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[700]!, Colors.grey[900]!],
            ),
          ),
        ),
        // Focus indicators
        const Center(
          child: Icon(Icons.camera_alt, size: 60, color: Colors.white24),
        ),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildCameraModes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeTab('VIDEO', false),
        _buildModeTab('PHOTO', true),
        _buildModeTab('AI CAM', false),
        _buildModeTab('BEAUTY', false),
        _buildModeTab('PORTRAIT', false),
      ],
    );
  }

  Widget _buildModeTab(String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.green : Colors.white.withValues(alpha: 0.6),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery thumbnail
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.image, color: Colors.white, size: 20),
          ),
          // Capture button
          GestureDetector(
            key: _captureButtonKey,
            onTap: _onPhotoTaken,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Switch camera
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flip_camera_android,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
