import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../models/detection_result.dart';

/// Unified Detection Service - ONE model to detect ALL hazards
class UnifiedDetectionService {
  YOLO? _yolo;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Classes to filter out (ignore these detections)
  static const List<String> filteredClasses = [
    'Tires_with_rim',
    'Stable_Tree',
    'Tires',
    'Traffic_Cones',
    'Broken_Pole',
    'Fallen_Tree',
    'Road_Barrier',
  ];

  /// Load the unified YOLO model
  Future<void> loadModel() async {
    await dispose();

    _yolo = YOLO(
      modelPath: 'roadfix-model_float32.tflite',
      task: YOLOTask.detect,
      useGpu: true,
    );
    await _yolo!.loadModel();
    debugPrint('Unified RoadFix YOLO model loaded');
    _isModelLoaded = true;
  }

  /// Dispose the model
  Future<void> dispose() async {
    if (_yolo != null) {
      await _yolo!.dispose();
      _yolo = null;
      _isModelLoaded = false;
    }
  }

  /// Pick image from specific source
  Future<File?> pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  /// Run detection on image — returns detections and annotated image bytes
  Future<DetectionOutput> detectObjects(
    File imageFile, {
    double confidenceThreshold = 0.25,
    double iouThreshold = 0.45,
  }) async {
    if (!_isModelLoaded || _yolo == null) {
      throw Exception('Unified model not loaded');
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    debugPrint('[DEBUG] Image size: ${bytes.length} bytes');
    debugPrint('[DEBUG] Running YOLO predict with conf=$confidenceThreshold, iou=$iouThreshold');

    final output = await _yolo!.predict(
      bytes,
      confidenceThreshold: confidenceThreshold,
      iouThreshold: iouThreshold,
    );

    // Debug: log all top-level keys from model output
    debugPrint('[DEBUG] Model output keys: ${output.keys.toList()}');

    // Extract annotated image from the model output
    final Uint8List? annotatedImage = output['annotatedImage'] as Uint8List?;
    debugPrint('[DEBUG] Annotated image present: ${annotatedImage != null}');

    // Parse detection boxes
    final rawBoxes = output['boxes'];
    debugPrint('[DEBUG] rawBoxes type: ${rawBoxes.runtimeType}');
    debugPrint('[DEBUG] rawBoxes is null: ${rawBoxes == null}');
    debugPrint('[DEBUG] rawBoxes is List: ${rawBoxes is List}');

    if (rawBoxes == null || rawBoxes is! List || rawBoxes.isEmpty) {
      debugPrint('[DEBUG] No objects detected — rawBoxes empty or wrong type');
      return DetectionOutput(
        detections: [],
        annotatedImage: annotatedImage,
        debugInfo: 'No boxes returned. rawBoxes type: ${rawBoxes.runtimeType}, '
            'keys: ${output.keys.toList()}',
      );
    }

    debugPrint('[DEBUG] Total raw boxes from model: ${rawBoxes.length}');

    // Debug: log first raw box to see all available keys
    if (rawBoxes.isNotEmpty) {
      debugPrint('[DEBUG] First raw box keys: ${rawBoxes[0].keys.toList()}');
      debugPrint('[DEBUG] First raw box values: ${rawBoxes[0]}');
    }

    final List<DetectionResult> results = [];
    final List<String> debugLines = [];
    int filteredByConf = 0;
    int filteredByClass = 0;

    for (var box in rawBoxes) {
      final double conf = (box['confidence'] ?? 0).toDouble();
      final String className = box['className'] ?? box['class'] ?? 'Unknown';

      debugPrint('[DEBUG] Box: class=$className, conf=${(conf * 100).toStringAsFixed(1)}%');

      if (conf < confidenceThreshold) {
        filteredByConf++;
        debugLines.add('SKIP (low conf ${(conf * 100).toStringAsFixed(1)}%): $className');
        continue;
      }
      if (filteredClasses.contains(className)) {
        filteredByClass++;
        debugLines.add('SKIP (filtered class): $className');
        continue;
      }

      // Try multiple possible coordinate key formats from YOLO output
      final double x1Norm = (box['x1_norm'] ?? box['x1'] ?? 0).toDouble();
      final double y1Norm = (box['y1_norm'] ?? box['y1'] ?? 0).toDouble();
      final double x2Norm = (box['x2_norm'] ?? box['x2'] ?? 0).toDouble();
      final double y2Norm = (box['y2_norm'] ?? box['y2'] ?? 0).toDouble();

      debugPrint('[DEBUG] Coords: x1=$x1Norm, y1=$y1Norm, x2=$x2Norm, y2=$y2Norm');

      // Validate coordinates are in normalized range [0, 1]
      if (x1Norm == 0 && y1Norm == 0 && x2Norm == 0 && y2Norm == 0) {
        debugPrint('[DEBUG] WARNING: All coordinates are 0 for $className — check box key names!');
        debugPrint('[DEBUG] Available keys in box: ${box.keys.toList()}');
      }

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
      debugLines.add('KEPT: $className (${(conf * 100).toStringAsFixed(1)}%)');
    }

    final summary = 'Total: ${rawBoxes.length}, Kept: ${results.length}, '
        'Filtered(conf): $filteredByConf, Filtered(class): $filteredByClass';
    debugPrint('[DEBUG] $summary');

    return DetectionOutput(
      detections: results,
      annotatedImage: annotatedImage,
      debugInfo: '$summary\n${debugLines.join('\n')}',
    );
  }

  /// Save annotated image bytes to a temp file, returns the file path
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

/// Container for detection results + annotated image
class DetectionOutput {
  final List<DetectionResult> detections;
  final Uint8List? annotatedImage;
  final String? debugInfo;

  DetectionOutput({required this.detections, this.annotatedImage, this.debugInfo});
}
