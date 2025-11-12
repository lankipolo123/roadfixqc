import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// 🚀 HYBRID DETECTION SERVICE
/// Runs 2 models: Specialized Pothole Model + Unified Model (filtered)
/// Model 1: Pothole Detection (98%+ accuracy for potholes/cracks)
/// Model 2: Unified Model (all other categories, blocks pothole/cracks)
class HybridDetectionService {
  YOLO? _potholeModel;
  YOLO? _unifiedModel;

  bool _isPotholeModelLoaded = false;
  bool _isUnifiedModelLoaded = false;

  bool get allModelsLoaded => _isPotholeModelLoaded && _isUnifiedModelLoaded;

  /// Classes from specialized pothole model
  static const List<String> potholeModelClasses = [
    'Pothole',
    'Road-Cracks',
  ];

  /// Classes from unified model (will be filtered to exclude pothole/cracks)
  static const List<String> unifiedModelClasses = [
    'Compromised-Pole',
    'Fallen-Barrier',
    'Fallen-Cone',
    'Road_Barrier',
    'Traffic_Cones',
    'Tires',
    'Stable',
    'Sewage-Manhole',
    'Tires_with_rim',
  ];

  /// Classes to completely filter out (not hazards)
  static const List<String> filteredClasses = [
    'Stable', // Not a hazard
    'Sewage-Manhole', // Not a road hazard
    'Tires_with_rim', // Filtered
  ];

  /// IMPORTANT: Block these from unified model (handled by pothole model)
  static const List<String> blockedFromUnified = [
    'Pothole',
    'Road-Cracks',
  ];

  /// Load both models
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING HYBRID DETECTION (2 MODELS)');
    debugPrint('========================================');

    try {
      // Model 1: Specialized Pothole Detection
      debugPrint('\n1️⃣ Loading Specialized Pothole Model...');
      _potholeModel = YOLO(
        modelPath: 'pothole_model_float32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _potholeModel!.loadModel();
      _isPotholeModelLoaded = true;
      debugPrint('   ✅ Pothole model loaded (pothole_model_float32.tflite)');
      debugPrint('   📋 Handles: Pothole, Road-Cracks (98%+ accuracy)');

      // Model 2: Unified Model (filtered)
      debugPrint('\n2️⃣ Loading Unified Model (filtered)...');
      _unifiedModel = YOLO(
        modelPath: 'lanki_capstone_FP32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _unifiedModel!.loadModel();
      _isUnifiedModelLoaded = true;
      debugPrint('   ✅ Unified model loaded (lanki_capstone_FP32.tflite)');
      debugPrint('   📋 Handles: All other categories');
      debugPrint('   🚫 Blocks: Pothole, Road-Cracks (handled by specialized model)');

      debugPrint('\n✅ HYBRID DETECTION READY!');
      debugPrint('   Strategy: Specialized pothole model + Unified (filtered)');
      debugPrint('========================================\n');
    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      rethrow;
    }
  }

  /// Dispose all models
  void dispose() {
    debugPrint('🗑️ Disposing hybrid detection models...');
    _potholeModel = null;
    _unifiedModel = null;
    _isPotholeModelLoaded = false;
    _isUnifiedModelLoaded = false;
  }

  /// Pick image from source
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

  /// 🎯 MAIN DETECTION METHOD - Runs 2 models (pothole + unified filtered)
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    if (!allModelsLoaded) {
      throw Exception('Not all models are loaded');
    }

    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 HYBRID DETECTION START - 2 MODELS');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final List<DetectionResult> allDetections = [];
    final stopwatch = Stopwatch()..start();

    // 🟢 MODEL 1: Specialized Pothole Detection
    debugPrint('\n1️⃣ Running Specialized POTHOLE MODEL...');
    final potholeResults = await _runModel(
      _potholeModel!,
      imageBytes,
      'Pothole Model',
      confidenceThreshold: 0.4, // Higher threshold for potholes
      blockClasses: [], // No blocking for pothole model
    );
    allDetections.addAll(potholeResults);
    debugPrint('   ✅ Pothole model found ${potholeResults.length} detections');

    // 🔵 MODEL 2: Unified Model (FILTERED - blocks pothole/cracks)
    debugPrint('\n2️⃣ Running UNIFIED MODEL (filtered)...');
    final unifiedResults = await _runModel(
      _unifiedModel!,
      imageBytes,
      'Unified Model',
      confidenceThreshold: 0.3,
      blockClasses: blockedFromUnified, // 🚫 Block Pothole & Road-Cracks
    );
    allDetections.addAll(unifiedResults);
    debugPrint('   ✅ Unified model found ${unifiedResults.length} detections');

    stopwatch.stop();

    // 📊 Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ HYBRID DETECTION COMPLETE');
    debugPrint('   Total inference time: ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('   Pothole Model: ${potholeResults.length}');
    debugPrint('   Unified Model (filtered): ${unifiedResults.length}');
    debugPrint('   TOTAL DETECTIONS: ${allDetections.length}');

    // Group by type
    final Map<String, int> counts = {};
    for (var d in allDetections) {
      counts[d.className] = (counts[d.className] ?? 0) + 1;
    }

    if (counts.isNotEmpty) {
      debugPrint('\n   Detected by class:');
      for (var entry in counts.entries) {
        debugPrint('      • ${entry.key}: ${entry.value}');
      }
    }
    debugPrint('========================================\n');

    return allDetections;
  }

  /// Helper: Run a single model and parse results
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
    int filteredCount = 0;

    for (var box in rawBoxes) {
      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      // Skip low confidence
      if (conf < confidenceThreshold) continue;

      // 🚫 BLOCK classes (e.g., pothole/cracks from unified model)
      if (blockClasses.contains(className)) {
        blockedCount++;
        debugPrint('   🚫 BLOCKED: $className (handled by specialized model)');
        continue;
      }

      // Skip filtered classes (non-hazards)
      if (filteredClasses.contains(className)) {
        filteredCount++;
        debugPrint('   ⏭️ FILTERED: $className (not a hazard)');
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
      debugPrint('   📊 Blocked $blockedCount detections (duplicate categories)');
    }
    if (filteredCount > 0) {
      debugPrint('   📊 Filtered $filteredCount non-hazards');
    }

    return results;
  }
}
