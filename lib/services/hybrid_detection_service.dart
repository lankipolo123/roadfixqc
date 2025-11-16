import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// 🚀 SEQUENTIAL DETECTION SERVICE
/// Runs 3 models sequentially: Pothole → Roadblocks → Utility Pole
/// Uses LOAD → RUN → DISPOSE pattern for each model to ensure proper native loading
class HybridDetectionService {
  // Models are loaded on-demand during detection, not pre-loaded
  // This is because ultralytics_yolo only supports one model at a time at native level

  /// Classes to block from each model
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

  static const List<String> blockedFromRoadblocks = [
    'Pothole',
    'Road-Cracks',
    'Sewage-Manhole',
    'Stable',
    'Tires_with_rim',
    'Traffic_Cones',
    'Road_Barrier',
    'Compromised-Pole',
  ];

  static const List<String> blockedFromUtilityPole = [
    'Pothole',
    'Road-Cracks',
    'Sewage-Manhole',
    'Stable',
    'Tires_with_rim',
    'Traffic_Cones',
    'Road_Barrier',
    'Fallen-Barrier',
    'Fallen-Cone',
    'Tires',
  ];

  /// Initialize service (no pre-loading needed)
  /// Models are loaded on-demand during detection
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 SEQUENTIAL DETECTION SERVICE READY');
    debugPrint('   Models will load on-demand during detection');
    debugPrint('   Pattern: LOAD → RUN → DISPOSE (repeat for each model)');
    debugPrint('========================================\n');
  }

  /// Main detection method - runs 3 models SEQUENTIALLY
  /// Uses LOAD → RUN → DISPOSE pattern for each model
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 SEQUENTIAL DETECTION START (3 MODELS)');
    debugPrint('   Pattern: LOAD → RUN → DISPOSE (repeat 3x)');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final List<DetectionResult> allDetections = [];
    final stopwatch = Stopwatch()..start();

    // 🟢 MODEL 1: Pothole Detection (LOAD → RUN → DISPOSE)
    debugPrint('\n1️⃣ POTHOLE MODEL: Loading...');
    YOLO? potholeModel = YOLO(
      modelPath: 'pothole_model_float32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await potholeModel.loadModel();
    debugPrint('   ✅ Loaded pothole_model_float32.tflite');

    debugPrint('   🔄 Running inference...');
    final potholeResults = await _runModel(
      potholeModel,
      imageBytes,
      'Pothole Model',
      confidenceThreshold: 0.4,
      blockClasses: blockedFromPothole,
    );
    allDetections.addAll(potholeResults);
    debugPrint('   ✅ Found ${potholeResults.length} potholes/cracks');
    debugPrint('   🗑️ Disposing model...');
    potholeModel = null; // Dispose to free native memory

    // 🔵 MODEL 2: Roadblocks Detection (LOAD → RUN → DISPOSE)
    debugPrint('\n2️⃣ ROADBLOCKS MODEL: Loading...');
    YOLO? roadblocksModel = YOLO(
      modelPath: 'roadblocks_FP32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await roadblocksModel.loadModel();
    debugPrint('   ✅ Loaded roadblocks_FP32.tflite');

    debugPrint('   🔄 Running inference...');
    final roadblocksResults = await _runModel(
      roadblocksModel,
      imageBytes,
      'Roadblocks Model',
      confidenceThreshold: 0.3,
      blockClasses: blockedFromRoadblocks,
    );
    allDetections.addAll(roadblocksResults);
    debugPrint('   ✅ Found ${roadblocksResults.length} roadblocks');
    debugPrint('   🗑️ Disposing model...');
    roadblocksModel = null; // Dispose to free native memory

    // 🟡 MODEL 3: Utility Pole Detection (LOAD → RUN → DISPOSE)
    debugPrint('\n3️⃣ UTILITY POLE MODEL: Loading...');
    YOLO? utilityPoleModel = YOLO(
      modelPath: 'BEST_UtilityPole_98.1percent_FP32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await utilityPoleModel.loadModel();
    debugPrint('   ✅ Loaded BEST_UtilityPole_98.1percent_FP32.tflite');

    debugPrint('   🔄 Running inference...');
    final poleResults = await _runModel(
      utilityPoleModel,
      imageBytes,
      'Utility Pole Model',
      confidenceThreshold: 0.3,
      blockClasses: blockedFromUtilityPole,
    );
    allDetections.addAll(poleResults);
    debugPrint('   ✅ Found ${poleResults.length} utility poles');
    debugPrint('   🗑️ Disposing model...');
    utilityPoleModel = null; // Dispose to free native memory

    stopwatch.stop();

    // Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ SEQUENTIAL DETECTION COMPLETE');
    debugPrint('   Total time: ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('   Model 1 (Pothole): ${potholeResults.length}');
    debugPrint('   Model 2 (Roadblocks): ${roadblocksResults.length}');
    debugPrint('   Model 3 (Utility Pole): ${poleResults.length}');
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
