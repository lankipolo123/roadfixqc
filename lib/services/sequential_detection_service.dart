import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// 🚀 SEQUENTIAL DETECTION SERVICE
/// Runs 3 specialized models sequentially on the same image for maximum accuracy
class SequentialDetectionService {
  YOLO? _potholeModel;
  YOLO? _utilityPoleModel;
  YOLO? _roadblockModel;

  bool _isPotholeModelLoaded = false;
  bool _isUtilityPoleModelLoaded = false;
  bool _isRoadblockModelLoaded = false;

  bool get allModelsLoaded =>
      _isPotholeModelLoaded &&
      _isUtilityPoleModelLoaded &&
      _isRoadblockModelLoaded;

  /// ⚠️ ALL FILTERS TEMPORARILY DISABLED FOR TESTING
  /// This will show ALL detections from all 3 models

  /// Load all 3 models
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING 3 SEQUENTIAL MODELS');
    debugPrint('⚠️ ALL FILTERS DISABLED - TESTING MODE');
    debugPrint('========================================');

    // MODEL 1: POTHOLE
    try {
      debugPrint('\n1️⃣ Loading Pothole Model...');
      debugPrint('   Path: pothole_model_float32');
      debugPrint(
        '   File: android/app/src/main/assets/pothole_model_float32.tflite',
      );

      _potholeModel = YOLO(
        modelPath: 'pothole_model_float32',
        task: YOLOTask.detect,
        useGpu: true,
      );

      debugPrint('   🔧 YOLO object created, loading...');
      await _potholeModel!.loadModel();
      _isPotholeModelLoaded = true;
      debugPrint('   ✅ Pothole model loaded successfully!');
    } catch (e, stack) {
      debugPrint('\n❌ POTHOLE MODEL FAILED:');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stack');
      rethrow;
    }

    // MODEL 2: UTILITY POLE
    try {
      debugPrint('\n2️⃣ Loading Utility Pole Model...');
      debugPrint('   Path: BEST_UtilityPole_98.1percent_FP32');
      debugPrint(
        '   File: android/app/src/main/assets/BEST_UtilityPole_98.1percent_FP32.tflite',
      );

      _utilityPoleModel = YOLO(
        modelPath: 'BEST_UtilityPole_98.1percent_FP32',
        task: YOLOTask.detect,
        useGpu: true,
      );

      debugPrint('   🔧 YOLO object created, loading...');
      await _utilityPoleModel!.loadModel();
      _isUtilityPoleModelLoaded = true;
      debugPrint('   ✅ Utility Pole model loaded successfully!');
    } catch (e, stack) {
      debugPrint('\n❌ UTILITY POLE MODEL FAILED:');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stack');
      rethrow;
    }

    // MODEL 3: ROADBLOCK
    try {
      debugPrint('\n3️⃣ Loading Roadblock Model...');
      debugPrint('   Path: roadblocks_FP32-fallen');
      debugPrint(
        '   File: android/app/src/main/assets/roadblocks_FP32-fallen.tflite',
      );

      _roadblockModel = YOLO(
        modelPath: 'roadblocks_FP32-fallen',
        task: YOLOTask.detect,
        useGpu: true,
      );

      debugPrint('   🔧 YOLO object created, loading...');
      await _roadblockModel!.loadModel();
      _isRoadblockModelLoaded = true;
      debugPrint('   ✅ Roadblock model loaded successfully!');
    } catch (e, stack) {
      debugPrint('\n❌ ROADBLOCK MODEL FAILED:');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stack');
      rethrow;
    }

    debugPrint('\n✅ ========================================');
    debugPrint('🎉 ALL 3 MODELS LOADED SUCCESSFULLY!');
    debugPrint('⚠️ TESTING MODE: All detections will be shown');
    debugPrint('========================================\n');
  }

  /// Dispose all models
  void dispose() {
    debugPrint('🗑️ Disposing all 3 models...');
    _potholeModel = null;
    _utilityPoleModel = null;
    _roadblockModel = null;
    _isPotholeModelLoaded = false;
    _isUtilityPoleModelLoaded = false;
    _isRoadblockModelLoaded = false;
  }

  /// Pick image from source
  Future<File?> pickImageFromSource(ImageSource source) async {
    debugPrint('📸 ImagePicker called: $source');
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) {
      debugPrint('   ❌ User cancelled');
      return null;
    }
    debugPrint('   ✅ Image picked: ${image.path}');
    return File(image.path);
  }

  /// Decode image to ui.Image
  Future<ui.Image> decodeImage(File file) async {
    debugPrint('🖼️ Decoding image...');
    final Uint8List bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    debugPrint('   ✅ Decoded: ${frame.image.width}x${frame.image.height}');
    return frame.image;
  }

  /// 🎯 MAIN DETECTION METHOD - Runs all 3 models sequentially
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    // Check model status
    debugPrint('\n🔍 PRE-DETECTION MODEL CHECK:');
    debugPrint('   Pothole loaded: $_isPotholeModelLoaded');
    debugPrint('   Utility Pole loaded: $_isUtilityPoleModelLoaded');
    debugPrint('   Roadblock loaded: $_isRoadblockModelLoaded');
    debugPrint('   All models loaded: $allModelsLoaded');

    if (!allModelsLoaded) {
      throw Exception('Not all models are loaded');
    }

    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 SEQUENTIAL DETECTION - 3 MODELS');
    debugPrint('⚠️ ALL FILTERS DISABLED - TESTING MODE');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final List<DetectionResult> allDetections = [];
    final stopwatch = Stopwatch()..start();

    // 🟢 MODEL 1: Pothole Detection
    try {
      debugPrint('\n1️⃣ Running POTHOLE MODEL...');
      final potholeResults = await _runModel(
        _potholeModel!,
        imageBytes,
        'Pothole',
        confidenceThreshold: 0.15, // Lowered for testing
      );
      allDetections.addAll(potholeResults);
      debugPrint('   ✅ Pothole model: ${potholeResults.length} detections');
      if (potholeResults.isEmpty) {
        debugPrint('   ⚠️ NO POTHOLE DETECTIONS');
      }
    } catch (e) {
      debugPrint('   ❌ Pothole model failed: $e');
    }

    // 🔵 MODEL 2: Utility Pole Detection
    try {
      debugPrint('\n2️⃣ Running UTILITY POLE MODEL...');
      final poleResults = await _runModel(
        _utilityPoleModel!,
        imageBytes,
        'Utility Pole',
        confidenceThreshold: 0.15, // Lowered for testing
      );
      allDetections.addAll(poleResults);
      debugPrint('   ✅ Utility Pole model: ${poleResults.length} detections');
      if (poleResults.isEmpty) {
        debugPrint('   ⚠️ NO UTILITY POLE DETECTIONS');
      }
    } catch (e) {
      debugPrint('   ❌ Utility Pole model failed: $e');
    }

    // 🟠 MODEL 3: Roadblock Detection
    try {
      debugPrint('\n3️⃣ Running ROADBLOCK MODEL...');
      final roadblockResults = await _runModel(
        _roadblockModel!,
        imageBytes,
        'Roadblock',
        confidenceThreshold: 0.15, // Lowered for testing
      );
      allDetections.addAll(roadblockResults);
      debugPrint('   ✅ Roadblock model: ${roadblockResults.length} detections');
      if (roadblockResults.isEmpty) {
        debugPrint('   ⚠️ NO ROADBLOCK DETECTIONS');
      }
    } catch (e) {
      debugPrint('   ❌ Roadblock model failed: $e');
    }

    stopwatch.stop();

    // ✅ DEDUPLICATION: Keep only the HIGHEST confidence detection per class
    final Map<String, DetectionResult> uniqueDetections = {};
    for (var detection in allDetections) {
      final className = detection.className;

      if (!uniqueDetections.containsKey(className)) {
        uniqueDetections[className] = detection;
      } else {
        // Keep the one with higher confidence
        if (detection.confidence > uniqueDetections[className]!.confidence) {
          uniqueDetections[className] = detection;
        }
      }
    }

    final finalDetections = uniqueDetections.values.toList();

    // 📊 Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ SEQUENTIAL DETECTION COMPLETE');
    debugPrint('   Total time: ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('   Raw detections: ${allDetections.length}');
    debugPrint('   After deduplication: ${finalDetections.length}');

    // Group by type
    final Map<String, int> counts = {};
    for (var d in finalDetections) {
      counts[d.className] = (counts[d.className] ?? 0) + 1;
    }

    if (counts.isNotEmpty) {
      debugPrint('\n   Final breakdown:');
      for (var entry in counts.entries) {
        debugPrint('      • ${entry.key}: ${entry.value}');
      }
    } else {
      debugPrint('   ⚠️ No detections across all 3 models');
    }
    debugPrint('========================================\n');

    return finalDetections;
  }

  /// Helper: Run a single model and parse results
  /// ⚠️ NO FILTERING - ALL DETECTIONS RETURNED
  Future<List<DetectionResult>> _runModel(
    YOLO model,
    Uint8List imageBytes,
    String modelName, {
    required double confidenceThreshold,
  }) async {
    debugPrint('   🔄 Running $modelName model...');

    final output = await model.predict(imageBytes);
    final rawBoxes = output['boxes'];

    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('   ⚠️ No raw detections from model');
      return [];
    }

    debugPrint('   📦 Raw detections: ${rawBoxes.length}');

    final List<DetectionResult> results = [];
    int lowConfCount = 0;

    for (var box in rawBoxes) {
      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      // 🔍 DEBUG: Show every detection
      debugPrint(
        '      🔍 DETECTED: "$className" at ${(conf * 100).toStringAsFixed(1)}%',
      );

      // Only skip if confidence is too low
      if (conf < confidenceThreshold) {
        lowConfCount++;
        debugPrint(
          '         ↳ ❌ Low confidence (threshold: ${(confidenceThreshold * 100).toStringAsFixed(1)}%)',
        );
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

      debugPrint('         ↳ ✅ KEPT!');
    }

    debugPrint(
      '   📊 Results: ${results.length} kept, $lowConfCount below threshold',
    );

    return results;
  }
}
