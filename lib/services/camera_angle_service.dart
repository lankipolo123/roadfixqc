import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraAngleService {
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  double _currentTiltAngle = 0.0;

  /// Start listening to accelerometer
  void startListening() {
    _accelSubscription = accelerometerEventStream().listen((event) {
      _calculateTiltAngle(event);
    });
  }

  /// Stop listening to accelerometer
  void stopListening() {
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }

  /// Calculate the tilt angle from camera-forward position (in degrees)
  void _calculateTiltAngle(AccelerometerEvent event) {
    // Calculate the magnitude of acceleration
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Calculate angle from vertical (z-axis)
    // When phone is vertical (camera forward), this should be ~90°
    final angleFromVertical = acos(event.z.abs() / magnitude) * (180 / pi);

    // We want phone upright (camera forward), which is ~90° from vertical
    // So we measure deviation from 90°
    _currentTiltAngle = (90 - angleFromVertical).abs();
  }

  /// Get current tilt angle (deviation from camera-forward position)
  double getCurrentTiltAngle() {
    return _currentTiltAngle;
  }

  /// Check if phone is held straight enough (within threshold)
  /// Default threshold: 25 degrees deviation from camera-forward
  bool isPhoneStraight({double maxTiltDegrees = 25.0}) {
    return _currentTiltAngle <= maxTiltDegrees;
  }

  /// Get a description of current phone orientation
  String getOrientationDescription() {
    if (_currentTiltAngle <= 15) {
      return 'Perfect - Phone is upright';
    } else if (_currentTiltAngle <= 25) {
      return 'Good - Slight tilt detected';
    } else if (_currentTiltAngle <= 40) {
      return 'Warning - Phone is tilted';
    } else {
      return 'Error - Phone is too tilted';
    }
  }

  /// Get color indicator based on tilt
  Color getTiltColor() {
    if (_currentTiltAngle <= 15) {
      return Colors.green;
    } else if (_currentTiltAngle <= 25) {
      return Colors.yellow;
    } else if (_currentTiltAngle <= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Validate if image can be used for pole detection
  CameraAngleValidation validateForPoleDetection() {
    if (_currentTiltAngle <= 25) {
      return CameraAngleValidation(
        isValid: true,
        tiltAngle: _currentTiltAngle,
        message: 'Camera angle is acceptable for detection',
      );
    } else {
      return CameraAngleValidation(
        isValid: false,
        tiltAngle: _currentTiltAngle,
        message:
            'Please hold your phone upright (deviation: ${_currentTiltAngle.toStringAsFixed(1)}°)',
      );
    }
  }

  void dispose() {
    stopListening();
  }
}

/// Result of camera angle validation
class CameraAngleValidation {
  final bool isValid;
  final double tiltAngle;
  final String message;

  CameraAngleValidation({
    required this.isValid,
    required this.tiltAngle,
    required this.message,
  });
}
