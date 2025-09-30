import 'package:flutter/material.dart';
import 'package:roadfix/services/camera_angle_service.dart';
import 'package:roadfix/widgets/themes.dart';

class CameraAngleIndicator extends StatefulWidget {
  final CameraAngleService angleService;

  const CameraAngleIndicator({super.key, required this.angleService});

  @override
  State<CameraAngleIndicator> createState() => _CameraAngleIndicatorState();
}

class _CameraAngleIndicatorState extends State<CameraAngleIndicator> {
  @override
  void initState() {
    super.initState();
    // Update UI every frame to show real-time angle
    Future.delayed(const Duration(milliseconds: 100), _updateAngle);
  }

  void _updateAngle() {
    if (mounted) {
      setState(() {});
      Future.delayed(const Duration(milliseconds: 100), _updateAngle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiltAngle = widget.angleService.getCurrentTiltAngle();
    final description = widget.angleService.getOrientationDescription();
    final color = widget.angleService.getTiltColor();
    final isGood = tiltAngle <= 20;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: secondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level indicator visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGood ? Icons.check_circle : Icons.warning,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Tilt: ${tiltAngle.toStringAsFixed(1)}°',
                    style: const TextStyle(color: inputFill, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Visual level bar
          SizedBox(
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: altSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Level indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 8,
                  width: (tiltAngle.clamp(0, 45) / 45 * 200).clamp(0, 200),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Center marker
                Container(width: 2, height: 12, color: inputFill),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
