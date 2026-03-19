// lib/widgets/dialog_widgets/location_required_dialog.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as perm;
import 'package:roadfix/widgets/themes.dart';

/// Modal dialog that enforces location permission.
/// Location is mandatory — the user cannot proceed without granting it.
/// Returns `true` when permission is granted, `false` if user goes back.
class LocationRequiredDialog extends StatefulWidget {
  const LocationRequiredDialog({super.key});

  @override
  State<LocationRequiredDialog> createState() => _LocationRequiredDialogState();

  /// Show the mandatory location dialog.
  /// Returns true if permission granted, false if user chose to go back.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LocationRequiredDialog(),
    );
    return result ?? false;
  }
}

class _LocationRequiredDialogState extends State<LocationRequiredDialog>
    with WidgetsBindingObserver {
  bool _deniedForever = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCurrentStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check permission when user returns from app settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _deniedForever) {
      _checkCurrentStatus();
    }
  }

  Future<void> _checkCurrentStatus() async {
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _deniedForever = permission == LocationPermission.deniedForever;
    });
  }

  Future<void> _requestPermission() async {
    setState(() => _checking = true);

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _deniedForever = true;
        _checking = false;
      });
      return;
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    // Request permission (shows native dialog)
    final result = await Geolocator.requestPermission();

    if (!mounted) return;

    if (result == LocationPermission.always ||
        result == LocationPermission.whileInUse) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _deniedForever = result == LocationPermission.deniedForever;
      _checking = false;
    });
  }

  Future<void> _openSettings() async {
    await perm.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.location_on, size: 48, color: primary),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Location Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: secondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                _deniedForever
                    ? 'Location permission was denied. Please enable it in your device settings to continue. RoadFix uses your GPS coordinates to map road issues accurately.'
                    : 'RoadFix requires your location to accurately map road issues using GPS coordinates. This is essential for the detection system.',
                style: const TextStyle(
                    fontSize: 14, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Action buttons
              Column(
                children: [
                  // Primary action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checking
                          ? null
                          : (_deniedForever
                              ? _openSettings
                              : _requestPermission),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        disabledBackgroundColor: primary.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _checking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: secondary,
                              ),
                            )
                          : Text(
                              _deniedForever
                                  ? 'Open Settings'
                                  : 'Enable Location',
                              style: const TextStyle(
                                color: secondary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Go back (not cancel — just navigates back)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
