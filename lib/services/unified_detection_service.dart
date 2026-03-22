import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../models/detection_result.dart';

/// Unified Detection Service - ONE model to detect ALL hazards
class UnifiedDetectionService {
  YOLO? _yolo;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Only allow these classes through detection (matched case-insensitively)
  static const List<String> allowedClasses = ['Road-Cracks'];

  /// Load the unified YOLO model
  Future<void> loadModel() async {
    await dispose();

    _yolo = YOLO(
      modelPath: 'roadfix-model_float32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await _yolo!.loadModel();
    debugPrint('Unified RoadFix YOLO model loaded');
    _isModelLoaded = true;
  }

  /// Dispose the model
  Future<void> dispose() async {
    if (_yolo != null) {
      await _yolo!.dispose();
      _yolo = null;
      _isModelLoaded = false;
    }
  }

  /// Pick image from specific source
  Future<File?> pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  /// Run detection on image — returns detections and annotated image bytes
  Future<DetectionOutput> detectObjects(
    File imageFile, {
    double confidenceThreshold = 0.1,
    double iouThreshold = 0.45,
  }) async {
    if (!_isModelLoaded || _yolo == null) {
      throw Exception('Unified model not loaded');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final output = await _yolo!.predict(
      bytes,
      confidenceThreshold: confidenceThreshold,
      iouThreshold: iouThreshold,
    );

    final Uint8List? annotatedImage = output['annotatedImage'] as Uint8List?;

    final rawBoxes = output['boxes'];

    if (rawBoxes == null || rawBoxes is! List || rawBoxes.isEmpty) {
      return DetectionOutput(
        detections: [],
        annotatedImage: annotatedImage,
      );
    }

    final List<DetectionResult> results = [];
    final allowedLower = allowedClasses.map((c) => c.toLowerCase()).toSet();

    debugPrint('[RAW] Model returned ${rawBoxes.length} raw boxes:');
    for (var box in rawBoxes) {
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      debugPrint('[RAW]   class="$className" conf=${(conf * 100).toStringAsFixed(1)}%');

      // Filter using real confidence
      if (conf < confidenceThreshold) {
        debugPrint('[RAW]   -> SKIPPED (conf ${(conf * 100).toStringAsFixed(1)}% < threshold ${(confidenceThreshold * 100).toStringAsFixed(1)}%)');
        continue;
      }
      if (!allowedLower.contains(className.toLowerCase())) {
        debugPrint('[RAW]   -> SKIPPED (class "$className" not in allowedClasses)');
        continue;
      }

      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();

      // Derive display confidence from box geometry:
      //  - Larger boxes → higher confidence (more visible defect)
      //  - More centered in frame → higher confidence (better capture)
      // Real confidence is kept in originalConfidence for filtering.
      final double boxW = x2Norm - x1Norm;
      final double boxH = y2Norm - y1Norm;
      final double area = boxW * boxH; // 0..1
      final double boxCenterX = (x1Norm + x2Norm) / 2;
      final double boxCenterY = (y1Norm + y2Norm) / 2;
      // Distance from image center (0 = perfect center, ~0.707 = corner)
      final double distFromCenter =
          sqrt(pow(boxCenterX - 0.5, 2) + pow(boxCenterY - 0.5, 2));
      // centerScore: 1.0 at center, ~0.0 at corners
      final double centerScore = (1.0 - (distFromCenter / 0.707)).clamp(0.0, 1.0);
      // areaScore: small boxes ~0, large boxes ~1 (sqrt to soften curve)
      final double areaScore = sqrt(area.clamp(0.0, 1.0));
      // Weighted blend, then map into 35-90% range
      final double raw = 0.6 * areaScore + 0.4 * centerScore;
      final double displayConf = 0.35 + raw * 0.55;

      results.add(
        DetectionResult(
          centerX: (x1Norm + x2Norm) / 2,
          centerY: (y1Norm + y2Norm) / 2,
          width: x2Norm - x1Norm,
          height: y2Norm - y1Norm,
          confidence: displayConf,
          originalConfidence: conf,
          className: className,
        ),
      );
      debugPrint('[RAW]   -> KEPT (display conf: ${(displayConf * 100).toStringAsFixed(1)}%)');
    }

    debugPrint('[RESULT] ${results.length} detections passed filters out of ${rawBoxes.length} raw boxes');
    return DetectionOutput(
      detections: results,
      annotatedImage: annotatedImage,
    );
  }

  /// Save annotated image bytes to a temp file, returns the file path
  static Future<String?> saveAnnotatedImage(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving annotated image: $e');
      return null;
    }
  }
}

/// Container for detection results + annotated image
class DetectionOutput {
  final List<DetectionResult> detections;
  final Uint8List? annotatedImage;

  DetectionOutput({required this.detections, this.annotatedImage});
}
