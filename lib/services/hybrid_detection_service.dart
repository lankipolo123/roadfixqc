import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// 🚀 UNIFIED DETECTION SERVICE
/// Single model for all hazard detection
class HybridDetectionService {
  YOLO? _model;
  bool _isModelLoaded = false;

  bool get allModelsLoaded => _isModelLoaded;

  /// Classes to block (non-hazards)
  static const List<String> blockedClasses = [
    'Sewage-Manhole', // Not a road hazard
    'Stable', // Not a hazard
    'Tires_with_rim', // Use "Tires" instead
    'Traffic_Cones', // Block
    'Road_Barrier', // Block
  ];

  /// Detectable hazard classes
  static const List<String> hazardClasses = [
    'Pothole',
    'Road-Cracks',
    'Compromised-Pole',
    'Fallen-Barrier',
    'Fallen-Cone',
    'Tires',
  ];

  /// Load model
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING UNIFIED MODEL');
    debugPrint('========================================');

    try {
      debugPrint('\n🎯 Loading RoadFix Unified Model (FP32)...');
      _model = YOLO(
        modelPath: 'roadfix-model_float32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _model!.loadModel();
      _isModelLoaded = true;
      debugPrint('   ✅ Model loaded (roadfix-model_float32.tflite)');
      debugPrint('   📋 Detects: ${hazardClasses.join(", ")}');
      debugPrint('   🚫 Blocks: ${blockedClasses.join(", ")}');

      debugPrint('\n✅ UNIFIED DETECTION READY!');
      debugPrint('========================================\n');
    } catch (e) {
      debugPrint('❌ Error loading model: $e');
      rethrow;
    }
  }

  /// Main detection method
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    if (!allModelsLoaded) {
      throw Exception('Model not loaded');
    }

    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 UNIFIED DETECTION START');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final stopwatch = Stopwatch()..start();

    // Run model
    debugPrint('\n🎯 Running Unified Model...');
    final detections = await _runModel(
      _model!,
      imageBytes,
      confidenceThreshold: confidenceThreshold,
    );

    stopwatch.stop();

    // Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ DETECTION COMPLETE');
    debugPrint('   Total inference time: ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('   Total detections: ${detections.length}');

    // Group by type
    final Map<String, int> counts = {};
    for (var d in detections) {
      counts[d.className] = (counts[d.className] ?? 0) + 1;
    }

    if (counts.isNotEmpty) {
      debugPrint('\n   Detected by class:');
      for (var entry in counts.entries) {
        debugPrint('      • ${entry.key}: ${entry.value}');
      }
    }
    debugPrint('========================================\n');

    return detections;
  }

  /// Helper: Run model and parse results
  Future<List<DetectionResult>> _runModel(
    YOLO model,
    Uint8List imageBytes, {
    required double confidenceThreshold,
  }) async {
    final output = await model.predict(imageBytes);
    final rawBoxes = output['boxes'];

    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('   ⚠️ No detections');
      return [];
    }

    final List<DetectionResult> results = [];
    int blockedCount = 0;

    for (var box in rawBoxes) {
      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      // Skip low confidence
      if (conf < confidenceThreshold) continue;

      // 🚫 BLOCK non-hazard classes
      if (blockedClasses.contains(className)) {
        blockedCount++;
        debugPrint('   🚫 BLOCKED: $className');
        continue;
      }

      // Calculate center and size
      final double xc = (x1Norm + x2Norm) / 2;
      final double yc = (y1Norm + y2Norm) / 2;
      final double w = x2Norm - x1Norm;
      final double h = y2Norm - y1Norm;

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

      debugPrint('   ✅ $className: ${(conf * 100).toStringAsFixed(1)}%');
    }

    if (blockedCount > 0) {
      debugPrint('   📊 Blocked $blockedCount detections');
    }

    return results;
  }

  /// Pick image
  Future<File?> pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return null;
    }

    return File(pickedFile.path);
  }

  /// Decode image
  Future<ui.Image> decodeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Dispose
  void dispose() {
    debugPrint('🗑️ Disposing detection service');
  }
}
