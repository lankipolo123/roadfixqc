import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/services/sequential_detection_service.dart'; // ✅ CHANGED
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

/// 🚀 SEQUENTIAL DETECTION SERVICE
/// Runs 3 models sequentially: Pothole → Roadblocks → Utility Pole
class HybridDetectionService {
  YOLO? _potholeModel;
  YOLO? _roadblocksModel;
  YOLO? _utilityPoleModel;

  bool _isPotholeModelLoaded = false;
  bool _isRoadblocksModelLoaded = false;
  bool _isUtilityPoleModelLoaded = false;

  bool get allModelsLoaded =>
      _isPotholeModelLoaded &&
      _isRoadblocksModelLoaded &&
      _isUtilityPoleModelLoaded;

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

  /// Load all 3 models
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING SEQUENTIAL DETECTION (3 MODELS)');
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

      // Model 2: Roadblocks Detection
      debugPrint('\n2️⃣ Loading Roadblocks Model...');
      _roadblocksModel = YOLO(
        modelPath: 'roadblocks_FP32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _roadblocksModel!.loadModel();
      _isRoadblocksModelLoaded = true;
      debugPrint('   ✅ Roadblocks model loaded');

      // Model 3: Utility Pole Detection
      debugPrint('\n3️⃣ Loading Utility Pole Model...');
      _utilityPoleModel = YOLO(
        modelPath: 'BEST_UtilityPole_98.1percent_FP32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _utilityPoleModel!.loadModel();
      _isUtilityPoleModelLoaded = true;
      debugPrint('   ✅ Utility Pole model loaded');

      debugPrint('\n✅ SEQUENTIAL DETECTION READY!');
      debugPrint('   Model 1: Potholes & Road-Cracks');
      debugPrint('   Model 2: Roadblocks (Barriers, Cones, Tires)');
      debugPrint('   Model 3: Utility Poles');
      debugPrint('========================================\n');
    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      rethrow;
    }
  }

  /// Main detection method - runs 3 models SEQUENTIALLY
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    if (!allModelsLoaded) {
      throw Exception('Not all models are loaded');
    }

    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 SEQUENTIAL DETECTION START (3 MODELS)');
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

    // 🔵 MODEL 2: Roadblocks Detection (runs SECOND)
    debugPrint('\n2️⃣ Running ROADBLOCKS MODEL...');
    final roadblocksResults = await _runModel(
      _roadblocksModel!,
      imageBytes,
      'Roadblocks Model',
      confidenceThreshold: 0.3,
      blockClasses: blockedFromRoadblocks,
    );
    allDetections.addAll(roadblocksResults);
    debugPrint('   ✅ Found ${roadblocksResults.length} roadblocks');

    // 🟡 MODEL 3: Utility Pole Detection (runs THIRD)
    debugPrint('\n3️⃣ Running UTILITY POLE MODEL...');
    final poleResults = await _runModel(
      _utilityPoleModel!,
      imageBytes,
      'Utility Pole Model',
      confidenceThreshold: 0.3,
      blockClasses: blockedFromUtilityPole,
    );
    allDetections.addAll(poleResults);
    debugPrint('   ✅ Found ${poleResults.length} utility poles');

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
