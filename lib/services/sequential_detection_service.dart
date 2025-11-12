import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

/// 🚀 SEQUENTIAL DETECTION SERVICE
/// Runs 3 specialized models sequentially on the same image for maximum accuracy
/// Model 1: Potholes + Road Cracks (98%+ accuracy)
/// Model 2: Utility Poles (98.1% accuracy)
/// Model 3: Roadblocks + Fallen Objects (95%+ accuracy)
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

  /// REAL CLASSES from unified model training (user-confirmed):
  /// Model 1: Pothole Detection
  static const List<String> potholeClasses = [
    'Pothole',
    'Sewage-Manhole',
  ];

  /// Model 2: Utility Pole Detection
  static const List<String> utilityPoleClasses = [
    'Stable', // Stable pole/tree
    'Compromised-Pole',
  ];

  /// Model 3: Roadblock Detection (everything else)
  static const List<String> roadblockClasses = [
    'Fallen-Barrier',
    'Fallen-Cone',
    'Road-Cracks',
    'Road_Barrier',
    'Traffic_Cones',
    'Tires',
    'Tires_with_rim',
  ];

  /// Classes to filter out (not hazards for reporting)
  static const List<String> filteredClasses = [
    'Stable', // Not a hazard - stable pole/tree
    'Sewage-Manhole', // Not a road hazard
    'Tires_with_rim', // From unified model - filtered
  ];

  /// Load all 3 models
  Future<void> loadAllModels() async {
    debugPrint('\n🔄 ========================================');
    debugPrint('📦 LOADING ALL 3 MODELS SEQUENTIALLY');
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
      debugPrint('   ✅ Pothole model loaded (pothole_model_float32.tflite)');

      // Model 2: Utility Pole Detection
      debugPrint('\n2️⃣ Loading Utility Pole Model...');
      _utilityPoleModel = YOLO(
        modelPath: 'BEST_UtilityPole_98.1percent_FP32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _utilityPoleModel!.loadModel();
      _isUtilityPoleModelLoaded = true;
      debugPrint('   ✅ Utility Pole model loaded (BEST_UtilityPole_98.1percent_FP32.tflite)');

      // Model 3: Roadblock Detection
      debugPrint('\n3️⃣ Loading Roadblock Model...');
      _roadblockModel = YOLO(
        modelPath: 'roadblocks_FP32.tflite',
        task: YOLOTask.detect,
        useGpu: true,
      );
      await _roadblockModel!.loadModel();
      _isRoadblockModelLoaded = true;
      debugPrint('   ✅ Roadblock model loaded (roadblocks_FP32.tflite)');

      debugPrint('\n✅ ALL 3 MODELS LOADED SUCCESSFULLY!');
      debugPrint('========================================\n');
    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      rethrow;
    }
  }

  /// Dispose all models
  void dispose() {
    debugPrint('🗑️ Disposing all models...');
    _potholeModel = null;
    _utilityPoleModel = null;
    _roadblockModel = null;
    _isPotholeModelLoaded = false;
    _isUtilityPoleModelLoaded = false;
    _isRoadblockModelLoaded = false;
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

  /// 🎯 MAIN DETECTION METHOD - Runs all 3 models sequentially
  Future<List<DetectionResult>> detectAllHazards(
    File imageFile, {
    double confidenceThreshold = 0.3,
  }) async {
    if (!allModelsLoaded) {
      throw Exception('Not all models are loaded');
    }

    debugPrint('\n🚀 ========================================');
    debugPrint('🔥 SEQUENTIAL DETECTION START - 3 MODELS');
    debugPrint('========================================');

    final Uint8List imageBytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${imageBytes.length} bytes');

    final List<DetectionResult> allDetections = [];
    final stopwatch = Stopwatch()..start();

    // 🟢 MODEL 1: Pothole Detection
    debugPrint('\n1️⃣ Running Model 1: POTHOLE DETECTION...');
    final potholeResults = await _runModel(
      _potholeModel!,
      imageBytes,
      'Pothole Model',
      confidenceThreshold: 0.4, // Higher threshold for potholes
    );
    allDetections.addAll(potholeResults);
    debugPrint('   ✅ Model 1 found ${potholeResults.length} detections');

    // 🔵 MODEL 2: Utility Pole Detection
    debugPrint('\n2️⃣ Running Model 2: UTILITY POLE DETECTION...');
    final poleResults = await _runModel(
      _utilityPoleModel!,
      imageBytes,
      'Utility Pole Model',
      confidenceThreshold: 0.3,
    );
    allDetections.addAll(poleResults);
    debugPrint('   ✅ Model 2 found ${poleResults.length} detections');

    // 🟠 MODEL 3: Roadblock Detection
    debugPrint('\n3️⃣ Running Model 3: ROADBLOCK DETECTION...');
    final roadblockResults = await _runModel(
      _roadblockModel!,
      imageBytes,
      'Roadblock Model',
      confidenceThreshold: 0.3,
    );
    allDetections.addAll(roadblockResults);
    debugPrint('   ✅ Model 3 found ${roadblockResults.length} detections');

    stopwatch.stop();

    // 📊 Summary
    debugPrint('\n📊 ========================================');
    debugPrint('✅ SEQUENTIAL DETECTION COMPLETE');
    debugPrint('   Total inference time: ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('   Model 1 (Potholes): ${potholeResults.length}');
    debugPrint('   Model 2 (Poles): ${poleResults.length}');
    debugPrint('   Model 3 (Roadblocks): ${roadblockResults.length}');
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
  }) async {
    final output = await model.predict(imageBytes);
    final rawBoxes = output['boxes'];

    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('   ⚠️ No detections from $modelName');
      return [];
    }

    final List<DetectionResult> results = [];

    for (var box in rawBoxes) {
      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      // Skip low confidence
      if (conf < confidenceThreshold) continue;

      // Skip filtered classes
      if (filteredClasses.contains(className)) {
        debugPrint('   ⏭️ Filtered out: $className');
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

    return results;
  }

  /// Convenience methods for specific detections

  Future<List<DetectionResult>> detectPotholes(File imageFile) async {
    if (!_isPotholeModelLoaded) {
      throw Exception('Pothole model not loaded');
    }
    final imageBytes = await imageFile.readAsBytes();
    return _runModel(_potholeModel!, imageBytes, 'Pothole Model',
        confidenceThreshold: 0.4);
  }

  Future<List<DetectionResult>> detectUtilityPoles(File imageFile) async {
    if (!_isUtilityPoleModelLoaded) {
      throw Exception('Utility Pole model not loaded');
    }
    final imageBytes = await imageFile.readAsBytes();
    return _runModel(_utilityPoleModel!, imageBytes, 'Utility Pole Model',
        confidenceThreshold: 0.3);
  }

  Future<List<DetectionResult>> detectRoadblocks(File imageFile) async {
    if (!_isRoadblockModelLoaded) {
      throw Exception('Roadblock model not loaded');
    }
    final imageBytes = await imageFile.readAsBytes();
    return _runModel(_roadblockModel!, imageBytes, 'Roadblock Model',
        confidenceThreshold: 0.3);
  }
}
