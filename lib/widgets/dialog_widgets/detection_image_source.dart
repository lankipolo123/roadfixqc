import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

enum ImageSourceOption {
  camera, // Normal camera
  gallery, // Gallery picker
  distanceCamera, // Distance detection camera (pothole only)
}

/// ✅ Detection dialog using YOUR beautiful bottom sheet design!
class DetectionImageSourceDialog {
  static Future<ImageSourceOption?> show(
    BuildContext context, {
    bool allowGallery = true,
    bool allowDistanceCamera = false,
  }) async {
    return showModalBottomSheet<ImageSourceOption>(
      context: context,
      backgroundColor: inputFill,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Select Detection Method',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how you want to capture the image',
                    style: TextStyle(color: altSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Camera option
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a new photo',
                    onTap: () =>
                        Navigator.pop(context, ImageSourceOption.camera),
                    isEnabled: true,
                  ),

                  const SizedBox(height: 16),

                  // Distance Camera option (POTHOLE ONLY)
                  if (allowDistanceCamera) ...[
                    _buildImageSourceOption(
                      context: context,
                      icon: Icons.zoom_out_map,
                      title: 'Distance Camera',
                      subtitle: 'Detect far potholes (hybrid zoom)',
                      onTap: () => Navigator.pop(
                        context,
                        ImageSourceOption.distanceCamera,
                      ),
                      isEnabled: true,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Gallery option
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: allowGallery
                        ? 'Choose from gallery'
                        : 'Not available - camera required',
                    onTap: allowGallery
                        ? () =>
                              Navigator.pop(context, ImageSourceOption.gallery)
                        : () {}, // Do nothing if disabled
                    isEnabled: allowGallery,
                  ),

                  const SizedBox(height: 20),

                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: statusDanger, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isEnabled,
    Color? color,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? Colors.grey[200]! : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isEnabled ? null : Colors.grey[50],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEnabled ? (color ?? primary) : Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? null : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isEnabled ? altSecondary : Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                const Icon(Icons.arrow_forward_ios, color: secondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
