import 'package:flutter/material.dart';

class MockCameraScreen extends StatefulWidget {
  final GlobalKey? captureButtonKey;
  final VoidCallback? onPhotoTaken;

  const MockCameraScreen({super.key, this.captureButtonKey, this.onPhotoTaken});

  @override
  State<MockCameraScreen> createState() => _MockCameraScreenState();
}

class _MockCameraScreenState extends State<MockCameraScreen> {
  void _takePhoto() {
    // Just immediately call the callback to go to step 3.5
    if (widget.onPhotoTaken != null) {
      widget.onPhotoTaken!();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            key: widget.captureButtonKey,
            onTap: _takePhoto,
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
