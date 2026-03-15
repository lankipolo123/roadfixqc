import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadfix/widgets/themes.dart';

enum LocationGuidanceType { serviceOff, permanentlyDenied }

class LocationGuidanceDialog extends StatelessWidget {
  final LocationGuidanceType type;

  const LocationGuidanceDialog({super.key, required this.type});

  IconData get _icon =>
      type == LocationGuidanceType.serviceOff
          ? Icons.gps_off
          : Icons.location_disabled;

  String get _title =>
      type == LocationGuidanceType.serviceOff
          ? 'GPS is Turned Off'
          : 'Location Access Blocked';

  String get _description =>
      type == LocationGuidanceType.serviceOff
          ? 'RoadFix needs GPS to locate road issues. Please enable location services.'
          : 'Location permission was permanently denied. Please enable it in app settings.';

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
              child: Icon(_icon, size: 48, color: primary),
            ),

            const SizedBox(height: 20),

            Text(
              _title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              _description,
              style: const TextStyle(
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
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Not Now',
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
                    onPressed: () async {
                      if (type == LocationGuidanceType.serviceOff) {
                        await Geolocator.openLocationSettings();
                      } else {
                        await openAppSettings();
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Open Settings',
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

  static Future<bool> show(BuildContext context, LocationGuidanceType type) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationGuidanceDialog(type: type),
    );
    return result ?? false;
  }
}
