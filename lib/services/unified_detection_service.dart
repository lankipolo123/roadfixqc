import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../models/detection_result.dart';

/// Review scope controls how confidence values are presented.
enum ReviewScope {
  /// Confidence is masked to a low value — all detections pass through.
  review,

  /// Real confidence is restored — proper filtering applies.
  production,
}

/// Unified Detection Service - ONE model to detect ALL hazards
class UnifiedDetectionService {
  YOLO? _yolo;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Current review scope — controls whether confidence is masked or real.
  ReviewScope _reviewScope = ReviewScope.production;
  ReviewScope get reviewScope => _reviewScope;

  /// Random generator for fake confidence values.
  static final _rng = Random();

  /// Generate a random fake confidence between 10% and 30%.
  static double _randomMaskedConfidence() =>
      0.10 + _rng.nextDouble() * 0.20;

  /// Only allow these classes through detection
  static const List<String> allowedClasses = ['Road_Crack'];

  /// Load the unified YOLO model
  Future<void> loadModel() async {
    await dispose();

    _yolo = YOLO(
      modelPath: 'unifiedmodle_float32.tflite',
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

    // Extract annotated image from the model output
    final Uint8List? annotatedImage = output['annotatedImage'] as Uint8List?;

    // Parse detection boxes
    final rawBoxes = output['boxes'];
    debugPrint('YOLO raw output keys: ${output.keys.toList()}');
    debugPrint('YOLO rawBoxes type: ${rawBoxes.runtimeType}, value: $rawBoxes');

    if (rawBoxes == null || rawBoxes is! List || rawBoxes.isEmpty) {
      debugPrint('No objects detected — rawBoxes is null/empty');
      return DetectionOutput(
        detections: [],
        annotatedImage: annotatedImage,
      );
    }

    debugPrint('YOLO returned ${rawBoxes.length} raw boxes');

    final List<DetectionResult> results = [];

    for (var box in rawBoxes) {
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      debugPrint('  Box: class=$className, conf=${(conf * 100).toStringAsFixed(1)}%');

      if (conf < confidenceThreshold) continue;
      if (!allowedClasses.contains(className)) continue;

      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();

      results.add(
        DetectionResult(
          centerX: (x1Norm + x2Norm) / 2,
          centerY: (y1Norm + y2Norm) / 2,
          width: x2Norm - x1Norm,
          height: y2Norm - y1Norm,
          confidence: _reviewScope == ReviewScope.review
              ? _randomMaskedConfidence()
              : conf,
          className: className,
          originalConfidence: conf,
        ),
      );
    }

    debugPrint('Detected ${results.length} of ${rawBoxes.length} objects');
    return DetectionOutput(
      detections: results,
      annotatedImage: annotatedImage,
    );
  }

  /// Switch the review scope. When changing to production, all detections
  /// in [currentDetections] get their real confidence restored so you can
  /// filter them properly. When changing to review, confidence is masked.
  void setReviewScope(
    ReviewScope scope, {
    List<DetectionResult>? currentDetections,
  }) {
    _reviewScope = scope;
    if (currentDetections != null) {
      for (final det in currentDetections) {
        if (scope == ReviewScope.production) {
          det.restoreConfidence();
        } else {
          det.maskConfidence(_randomMaskedConfidence());
        }
      }
    }
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
