import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// Unified Detection Service - ONE model to detect ALL hazards
/// Detects: Potholes, Broken Utility Poles, Roadblocks, Fallen Cones, Fallen Barriers, Road Cracks
class UnifiedDetectionService {
  YOLO? _yolo;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Categories that the unified model can detect
  static const List<String> supportedCategories = [
    'Pothole',
    'Broken_Pole',
    'Fallen_Cone',
    'Fallen_Barrier',
    'Road_Crack',
    'Roadblock',
    // Add any other roadblock types from your training
    'Barricade',
    'Traffic_Cone',
    'Debris',
  ];

  /// Classes to filter out (ignore these detections)
  static const List<String> filteredClasses = ['Tires_with_rim', 'Stable_Tree'];

  /// Load the unified YOLO model
  Future<void> loadModel() async {
    // Dispose previous model if exists
    dispose();

    _yolo = YOLO(
      modelPath: 'roadfix-model_float32',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await _yolo!.loadModel();
    debugPrint('✅ Unified RoadFix YOLO model loaded (roadfix-model_float32)');
    _isModelLoaded = true;
  }

  /// Dispose the model
  void dispose() {
    if (_yolo != null) {
      debugPrint('🗑️ Unified detection service disposed');
      _yolo = null;
      _isModelLoaded = false;
    }
  }

  /// Pick image from gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  /// Pick image from specific source
  Future<File?> pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  /// Decode image to ui.Image
  Future<ui.Image> decodeImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Run detection on image
  /// Optional [filterCategory] to only return specific types (e.g., 'Pothole', 'Broken_Pole')
  Future<List<DetectionResult>> detectObjects(
    File imageFile, {
    String? filterCategory,
    double confidenceThreshold = 0.3,
  }) async {
    debugPrint('\n========================================');
    debugPrint('🚀 UNIFIED DETECTION START');
    debugPrint('   Model: roadfix-model_float32.tflite');
    if (filterCategory != null) {
      debugPrint('   Filter: $filterCategory only');
    }
    debugPrint('========================================');

    if (!_isModelLoaded || _yolo == null) {
      throw Exception('Unified model not loaded');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${bytes.length} bytes');

    final output = await _yolo!.predict(bytes);
    debugPrint('📦 Raw output keys: ${output.keys}');

    final rawBoxes = output['boxes'];
    debugPrint('📊 TOTAL BOXES DETECTED: ${rawBoxes?.length ?? 0}');

    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('⚠️ No objects detected');
      debugPrint('========================================\n');
      return [];
    }

    final List<DetectionResult> results = [];
    int boxNum = 0;

    for (var box in rawBoxes) {
      boxNum++;
      debugPrint('\n--- BOX #$boxNum ---');
      debugPrint('🔍 Raw box data: $box');

      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      debugPrint('   Class: "$className"');
      debugPrint('   Confidence: ${(conf * 100).toStringAsFixed(1)}%');

      final double xc = (x1Norm + x2Norm) / 2;
      final double yc = (y1Norm + y2Norm) / 2;
      final double w = x2Norm - x1Norm;
      final double h = y2Norm - y1Norm;

      // Skip low confidence detections
      if (conf < confidenceThreshold) {
        debugPrint('   ❌ SKIPPED: Confidence too low');
        continue;
      }

      // Skip filtered classes
      if (filteredClasses.contains(className)) {
        debugPrint('   ⏭️ SKIPPED: Filtered class: $className');
        continue;
      }

      // If filtering by category, only include that category
      if (filterCategory != null && className != filterCategory) {
        debugPrint('   ⏭️ SKIPPED: Not matching filter ($filterCategory)');
        continue;
      }

      results.add(
        DetectionResult(
          centerX: xc,
          centerY: yc,
          width: w,
          height: h,
          confidence: conf,
          className: className,
        ),
      );

      debugPrint('✅ $className detected: conf=${conf.toStringAsFixed(2)}');
    }

    debugPrint('\n========================================');
    debugPrint('📊 SUMMARY:');
    debugPrint('   Total detections: ${rawBoxes.length}');
    debugPrint('   Filtered detections: ${results.length}');
    if (filterCategory != null) {
      debugPrint('   Category filter: $filterCategory');
    }
    debugPrint('========================================\n');

    return results;
  }

  /// Detect specific category (convenience methods)
  Future<List<DetectionResult>> detectPotholes(File imageFile) async {
    return detectObjects(
      imageFile,
      filterCategory: 'Pothole',
      confidenceThreshold: 0.4,
    );
  }

  Future<List<DetectionResult>> detectBrokenPoles(File imageFile) async {
    return detectObjects(
      imageFile,
      filterCategory: 'Broken_Pole',
      confidenceThreshold: 0.3,
    );
  }

  Future<List<DetectionResult>> detectRoadblocks(File imageFile) async {
    // Roadblocks can be multiple types, so no specific filter
    return detectObjects(imageFile, confidenceThreshold: 0.3);
  }

  Future<List<DetectionResult>> detectFallenCones(File imageFile) async {
    return detectObjects(
      imageFile,
      filterCategory: 'Fallen_Cone',
      confidenceThreshold: 0.3,
    );
  }

  Future<List<DetectionResult>> detectFallenBarriers(File imageFile) async {
    return detectObjects(
      imageFile,
      filterCategory: 'Fallen_Barrier',
      confidenceThreshold: 0.3,
    );
  }

  Future<List<DetectionResult>> detectRoadCracks(File imageFile) async {
    return detectObjects(
      imageFile,
      filterCategory: 'Road_Crack',
      confidenceThreshold: 0.4,
    );
  }
}
