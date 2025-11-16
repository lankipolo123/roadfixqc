import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:ultralytics_yolo/yolo.dart';

/// 🚀 MULTI-INSTANCE DETECTION SERVICE
/// Runs 3 models together using useMultiInstance: true
/// Pre-loads all models, runs inference with Future.wait, then disposes
class HybridDetectionService {
  // Models pre-loaded with useMultiInstance enabled
  YOLO? _potholeModel;
  YOLO? _roadblocksModel;
  YOLO? _utilityPoleModel;

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
    'Stable_Tree',
    'Stable',
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

  /// Initialize all 3 models with useMultiInstance: true
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING 3 MODELS WITH MULTI-INSTANCE');
    debugPrint('========================================');

    // Initialize all 3 models with useMultiInstance: true
    _potholeModel = YOLO(
      modelPath: 'pothole_model_float32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
      useMultiInstance: true, // ✅ Enable multi-instance
    );

    _roadblocksModel = YOLO(
      modelPath: 'roadblocks_FP32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
      useMultiInstance: true, // ✅ Enable multi-instance
    );

    _utilityPoleModel = YOLO(
      modelPath: 'BEST_UtilityPole_98.1percent_FP32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
      useMultiInstance: true, // ✅ Enable multi-instance
    );

    // Load all models in parallel
    debugPrint('⏳ Loading all 3 models in parallel...');
    await Future.wait([
      _potholeModel!.loadModel(),
      _roadblocksModel!.loadModel(),
      _utilityPoleModel!.loadModel(),
    ]);

    debugPrint('✅ All 3 models loaded successfully!');
    debugPrint('========================================\n');
  }

  /// Main detection method - runs 3 models TOGETHER with Future.wait
  /// Uses pre-loaded models with useMultiInstance: true
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 MULTI-INSTANCE DETECTION START (3 MODELS)');
    debugPrint('   Running all 3 models with Future.wait');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final stopwatch = Stopwatch()..start();

    // ✅ Run all 3 models TOGETHER with Future.wait
    debugPrint('\n⚡ Running all 3 models in parallel...');
    final results = await Future.wait([
      _runModel(
        _potholeModel!,
        imageBytes,
        'Pothole Model',
        confidenceThreshold: 0.4,
        blockClasses: blockedFromPothole,
      ),
      _runModel(
        _roadblocksModel!,
        imageBytes,
        'Roadblocks Model',
        confidenceThreshold: 0.3,
        blockClasses: blockedFromRoadblocks,
      ),
      _runModel(
        _utilityPoleModel!,
        imageBytes,
        'Utility Pole Model',
        confidenceThreshold: 0.3,
        blockClasses: blockedFromUtilityPole,
      ),
    ]);

    stopwatch.stop();

    // Combine all results
    final List<DetectionResult> allDetections = [];
    final potholeResults = results[0];
    final roadblocksResults = results[1];
    final poleResults = results[2];

    allDetections.addAll(potholeResults);
    allDetections.addAll(roadblocksResults);
    allDetections.addAll(poleResults);

    // Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ MULTI-INSTANCE DETECTION COMPLETE');
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

  /// Dispose all 3 models
  Future<void> dispose() async {
    debugPrint('\n🗑️ ========================================');
    debugPrint('🗑️ DISPOSING ALL 3 MODELS');
    debugPrint('========================================');

    if (_potholeModel != null) {
      await _potholeModel!.dispose();
      _potholeModel = null;
      debugPrint('✅ Disposed Pothole model');
    }

    if (_roadblocksModel != null) {
      await _roadblocksModel!.dispose();
      _roadblocksModel = null;
      debugPrint('✅ Disposed Roadblocks model');
    }

    if (_utilityPoleModel != null) {
      await _utilityPoleModel!.dispose();
      _utilityPoleModel = null;
      debugPrint('✅ Disposed Utility Pole model');
    }

    debugPrint('✅ All models disposed successfully');
    debugPrint('========================================\n');
  }
}
