import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// 🚀 SEQUENTIAL DETECTION SERVICE
/// Runs 2 models sequentially: Pothole Model → Unified Model
class HybridDetectionService {
  YOLO? _potholeModel;
  YOLO? _unifiedModel;

  bool _isPotholeModelLoaded = false;
  bool _isUnifiedModelLoaded = false;

  bool get allModelsLoaded => _isPotholeModelLoaded && _isUnifiedModelLoaded;

  /// Classes to block from POTHOLE model
  static const List<String> blockedFromPothole = [
    'Sewage-Manhole',
    'Stable',
    'Tires_with_rim',
    'Traffic_Cones',
    'Road_Barrier',
    'Compromised-Pole',
    'Fallen-Barrier',
    'Fallen-Cone',
    'Tires',
  ];

  /// Classes to block from UNIFIED model
  static const List<String> blockedFromUnified = [
    'Pothole', // Handled by pothole model
    'Road-Cracks', // Handled by pothole model
    'Sewage-Manhole',
    'Stable',
    'Tires_with_rim',
    'Traffic_Cones',
    'Road_Barrier',
  ];

  /// Load both models
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING SEQUENTIAL DETECTION (2 MODELS)');
    debugPrint('========================================');

    try {
      // Model 1: Pothole Detection
      debugPrint('\n1️⃣ Loading Pothole Model...');
      _potholeModel = YOLO(
        modelPath: 'pothole_model_float32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _potholeModel!.loadModel();
      _isPotholeModelLoaded = true;
      debugPrint('   ✅ Pothole model loaded');

      // Model 2: Unified Model
      debugPrint('\n2️⃣ Loading Unified Model...');
      _unifiedModel = YOLO(
        modelPath: 'roadfix-model_float32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _unifiedModel!.loadModel();
      _isUnifiedModelLoaded = true;
      debugPrint('   ✅ Unified model loaded');

      debugPrint('\n✅ SEQUENTIAL DETECTION READY!');
      debugPrint('   Model 1: Potholes & Road-Cracks');
      debugPrint('   Model 2: All other hazards');
      debugPrint('========================================\n');
    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      rethrow;
    }
  }

  /// Main detection method - runs models SEQUENTIALLY
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    if (!allModelsLoaded) {
      throw Exception('Not all models are loaded');
    }

    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 SEQUENTIAL DETECTION START (2 MODELS)');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final List<DetectionResult> allDetections = [];
    final stopwatch = Stopwatch()..start();

    // 🟢 MODEL 1: Pothole Detection (runs FIRST)
    debugPrint('\n1️⃣ Running POTHOLE MODEL...');
    final potholeResults = await _runModel(
      _potholeModel!,
      imageBytes,
      'Pothole Model',
      confidenceThreshold: 0.4,
      blockClasses: blockedFromPothole,
    );
    allDetections.addAll(potholeResults);
    debugPrint('   ✅ Found ${potholeResults.length} potholes/cracks');

    // 🔵 MODEL 2: Unified Model (runs SECOND, after pothole model)
    debugPrint('\n2️⃣ Running UNIFIED MODEL...');
    final unifiedResults = await _runModel(
      _unifiedModel!,
      imageBytes,
      'Unified Model',
      confidenceThreshold: 0.3,
      blockClasses: blockedFromUnified,
    );
    allDetections.addAll(unifiedResults);
    debugPrint('   ✅ Found ${unifiedResults.length} other hazards');

    stopwatch.stop();

    // Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ SEQUENTIAL DETECTION COMPLETE');
    debugPrint('   Total time: ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('   Model 1 (Pothole): ${potholeResults.length}');
    debugPrint('   Model 2 (Unified): ${unifiedResults.length}');
    debugPrint('   TOTAL: ${allDetections.length}');

    // Group by type
    final Map<String, int> counts = {};
    for (var d in allDetections) {
      counts[d.className] = (counts[d.className] ?? 0) + 1;
    }

    if (counts.isNotEmpty) {
      debugPrint('\n   Breakdown:');
      for (var entry in counts.entries) {
        debugPrint('      • ${entry.key}: ${entry.value}');
      }
    }
    debugPrint('========================================\n');

    return allDetections;
  }

  /// Helper: Run a single model
  Future<List<DetectionResult>> _runModel(
    YOLO model,
    Uint8List imageBytes,
    String modelName, {
    required double confidenceThreshold,
    required List<String> blockClasses,
  }) async {
    final output = await model.predict(imageBytes);
    final rawBoxes = output['boxes'];

    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('   ⚠️ No detections from $modelName');
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

      // Block classes
      if (blockClasses.contains(className)) {
        blockedCount++;
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
      debugPrint('   🚫 Blocked $blockedCount detections');
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
