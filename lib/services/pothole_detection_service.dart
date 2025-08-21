import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../models/detection_result.dart';

class DetectionService {
  late YOLO _yolo;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  // Load the YOLO model
  Future<void> loadModel() async {
    _yolo = YOLO(modelPath: 'yolo11n_87.tflite', task: YOLOTask.detect);
    await _yolo.loadModel();
    debugPrint('✅ YOLO model loaded');
    _isModelLoaded = true;
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  // Pick image from specific source
  Future<File?> pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  // Decode image to ui.Image
  Future<ui.Image> decodeImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // Run detection on image
  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final output = await _yolo.predict(bytes);

    final rawBoxes = output['boxes'];
    if (rawBoxes == null || rawBoxes.isEmpty) {
      debugPrint('⚠️ No boxes detected');
      return [];
    }

    final List<DetectionResult> results = [];

    for (var box in rawBoxes) {
      debugPrint('🔍 Raw box data: $box');

      // Parse the box data (your existing logic)
      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      // Convert to center + width/height
      final double xc = (x1Norm + x2Norm) / 2;
      final double yc = (y1Norm + y2Norm) / 2;
      final double w = x2Norm - x1Norm;
      final double h = y2Norm - y1Norm;

      debugPrint(
        '🔍 Parsed: xc=$xc yc=$yc w=$w h=$h conf=$conf class=$className',
      );

      if (conf < 0.5) continue;

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

      debugPrint(
        '✅ Detection: xc=$xc yc=$yc w=$w h=$h conf=${conf.toStringAsFixed(2)} class=$className',
      );
    }

    debugPrint('📊 Total detections: ${results.length}');
    return results;
  }
}
