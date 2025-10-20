import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

class PotholeDetectionService {
  YOLO? _yolo; // ✅ Made nullable
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Load the YOLO model
  Future<void> loadModel() async {
    // ✅ Dispose previous model if exists
    dispose();

    _yolo = YOLO(
      modelPath: 'pothole_model_float32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await _yolo!.loadModel();
    debugPrint('✅ Pothole YOLO model loaded (pothole_model_float32.tflite)');
    _isModelLoaded = true;
  }

  /// ✅ ADDED: Properly dispose the model
  void dispose() {
    if (_yolo != null) {
      debugPrint('🗑️ Pothole model service disposed');
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
  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    debugPrint('\n========================================');
    debugPrint('🚀 POTHOLE DETECTION START');
    debugPrint('   Model: pothole_model_float32.tflite');
    debugPrint('========================================');

    if (!_isModelLoaded || _yolo == null) {
      throw Exception('Pothole model not loaded');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    debugPrint('📸 Image size: ${bytes.length} bytes');

    final output = await _yolo!.predict(bytes);
    debugPrint('📦 Raw output keys: ${output.keys}');

    final rawBoxes = output['boxes'];
    debugPrint('📊 TOTAL BOXES DETECTED: ${rawBoxes?.length ?? 0}');

    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('⚠️ No potholes detected');
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

      if (conf < 0.4) {
        debugPrint('   ❌ SKIPPED: Confidence too low');
        continue;
      }

      if (className != 'Pothole') {
        debugPrint('⏭️ Skipping non-Pothole detection: $className');
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

      debugPrint('✅ Pothole detected: conf=${conf.toStringAsFixed(2)}');
    }

    debugPrint('\n========================================');
    debugPrint('📊 SUMMARY:');
    debugPrint('   Total detections: ${rawBoxes.length}');
    debugPrint('   Pothole detections: ${results.length}');
    debugPrint('========================================\n');

    return results;
  }
}
