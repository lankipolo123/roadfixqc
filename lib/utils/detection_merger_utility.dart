import 'package:flutter/material.dart';
import 'package:roadfix/models/detection_result.dart';

class DetectionMergerUtility {
  /// Merge detections from full and cropped images using NMS
  static List<DetectionResult> mergeDetections({
    required List<DetectionResult> fullDetections,
    required List<DetectionResult> croppedDetections,
    double iouThreshold = 0.5,
  }) {
    debugPrint('\n🔀 MERGING DETECTIONS:');
    debugPrint('   Full image detections: ${fullDetections.length}');
    debugPrint('   Cropped image detections: ${croppedDetections.length}');

    // Combine all detections
    final allDetections = [...fullDetections, ...croppedDetections];

    if (allDetections.isEmpty) {
      debugPrint('   No detections to merge');
      return [];
    }

    // Apply NMS (Non-Maximum Suppression)
    final mergedDetections = _nonMaxSuppression(
      allDetections,
      iouThreshold: iouThreshold,
    );

    debugPrint('   Merged result: ${mergedDetections.length} detections');
    debugPrint(
      '   Duplicates removed: ${allDetections.length - mergedDetections.length}',
    );

    return mergedDetections;
  }

  /// Non-Maximum Suppression to remove duplicate detections
  static List<DetectionResult> _nonMaxSuppression(
    List<DetectionResult> detections, {
    double iouThreshold = 0.5,
  }) {
    if (detections.isEmpty) return [];

    // Sort by confidence (highest first)
    final sorted = List<DetectionResult>.from(detections)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final kept = <DetectionResult>[];
    final suppressed = <bool>[];

    for (int i = 0; i < sorted.length; i++) {
      suppressed.add(false);
    }

    for (int i = 0; i < sorted.length; i++) {
      if (suppressed[i]) continue;

      kept.add(sorted[i]);

      for (int j = i + 1; j < sorted.length; j++) {
        if (suppressed[j]) continue;

        // Calculate IoU between boxes
        final iou = _calculateIoU(sorted[i], sorted[j]);

        if (iou > iouThreshold) {
          suppressed[j] = true; // Suppress lower confidence detection
        }
      }
    }

    return kept;
  }

  /// Calculate Intersection over Union between two bounding boxes
  static double _calculateIoU(DetectionResult a, DetectionResult b) {
    // Convert from center coords to top-left coords
    final x1 = a.centerX - (a.width / 2);
    final y1 = a.centerY - (a.height / 2);
    final w1 = a.width;
    final h1 = a.height;

    final x2 = b.centerX - (b.width / 2);
    final y2 = b.centerY - (b.height / 2);
    final w2 = b.width;
    final h2 = b.height;

    // Calculate intersection area
    final intersectX = (x1 < x2) ? x2 : x1;
    final intersectY = (y1 < y2) ? y2 : y1;
    final intersectW =
        ((x1 + w1) < (x2 + w2) ? (x1 + w1) : (x2 + w2)) - intersectX;
    final intersectH =
        ((y1 + h1) < (y2 + h2) ? (y1 + h1) : (y2 + h2)) - intersectY;

    if (intersectW <= 0 || intersectH <= 0) {
      return 0.0;
    }

    final intersectionArea = intersectW * intersectH;

    // Calculate union area
    final area1 = w1 * h1;
    final area2 = w2 * h2;
    final unionArea = area1 + area2 - intersectionArea;

    return intersectionArea / unionArea;
  }
}
