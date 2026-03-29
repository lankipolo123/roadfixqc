import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../models/detection_result.dart';

class DetectionService {
  YOLO? _yolo;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  static const String _modelPath = 'roadfix-detector.tflite';

  Future<void> loadModel() async {
    await dispose();

    try {
      _yolo = YOLO(modelPath: _modelPath, task: YOLOTask.detect, useGpu: true);
      await _yolo!.loadModel();
      debugPrint('DetectionService: model loaded (GPU)');
    } catch (e) {
      debugPrint('DetectionService: GPU failed, falling back to CPU: $e');
      _yolo = YOLO(modelPath: _modelPath, task: YOLOTask.detect, useGpu: false);
      await _yolo!.loadModel();
      debugPrint('DetectionService: model loaded (CPU)');
    }

    _isModelLoaded = true;
  }

  Future<void> dispose() async {
    if (_yolo != null) {
      await _yolo!.dispose();
      _yolo = null;
      _isModelLoaded = false;
    }
  }

  Future<File?> pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  Future<DetectionOutput> detectObjects(
    File imageFile, {
    double confidenceThreshold = 0.25,
    double iouThreshold = 0.45,
  }) async {
    if (!_isModelLoaded || _yolo == null) {
      throw Exception('Model not loaded');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final output = await _yolo!.predict(
      bytes,
      confidenceThreshold: confidenceThreshold,
      iouThreshold: iouThreshold,
    );

    final Uint8List? annotatedImage = output['annotatedImage'] as Uint8List?;
    final rawBoxes = output['boxes'];

    if (rawBoxes == null || rawBoxes is! List || rawBoxes.isEmpty) {
      return DetectionOutput(detections: [], annotatedImage: annotatedImage);
    }

    final List<DetectionResult> results = [];

    for (var box in rawBoxes) {
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? 'Unknown';

      if (conf < confidenceThreshold) continue;

      final double x1Norm = (box['x1_norm'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? 0).toDouble();

      results.add(
        DetectionResult(
          centerX: (x1Norm + x2Norm) / 2,
          centerY: (y1Norm + y2Norm) / 2,
          width: x2Norm - x1Norm,
          height: y2Norm - y1Norm,
          confidence: conf,
          className: className,
        ),
      );
    }

    return DetectionOutput(detections: results, annotatedImage: annotatedImage);
  }

  static Future<String?> saveAnnotatedImage(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving annotated image: $e');
      return null;
    }
  }
}

class DetectionOutput {
  final List<DetectionResult> detections;
  final Uint8List? annotatedImage;

  DetectionOutput({required this.detections, this.annotatedImage});
}
