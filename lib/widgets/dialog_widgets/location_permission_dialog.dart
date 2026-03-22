import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadfix/utils/location_permission_manager.dart';
import 'package:roadfix/widgets/themes.dart';

class LocationPermissionDialog extends StatefulWidget {
  const LocationPermissionDialog({super.key});

  @override
  State<LocationPermissionDialog> createState() =>
      _LocationPermissionDialogState();

  /// Shows the location permission dialog if it hasn't been shown before.
  /// Call this after navigating to the main app screen.
  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPermission =
        prefs.getBool('location_permission_shown') ?? false;

    if (!hasSeenPermission && context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LocationPermissionDialog(),
      );
    }
  }
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    await LocationPermissionManager.checkLocationPermission(
      openSettings: false,
    );

    if (mounted) {
      setState(() => _isRequesting = false);
      await _dismiss();
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_permission_shown', true);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, size: 48, color: primary),
            ),

            const SizedBox(height: 20),

            const Text(
              'Enable Location Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'RoadFix uses your location to accurately map road issues in your area. This helps us pinpoint problems and get them fixed faster.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isRequesting ? null : _dismiss,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRequesting ? null : _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isRequesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(inputFill),
                            ),
                          )
                        : const Text(
                            'Enable',
                            style: TextStyle(
                              color: inputFill,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
