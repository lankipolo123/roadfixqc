import 'dart:io';
import 'dart:ui' as ui;
import 'package:bounding_box_annotation/bounding_box_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class AnnotationService {
  final AnnotationController _controller = AnnotationController();
  final ImagePicker _picker = ImagePicker();

  AnnotationController get controller => _controller;

  // Pick image from source and convert to bytes with dimensions
  Future<AnnotationImageData?> pickImageFromSource(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();

    // Get image dimensions properly
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // IMPORTANT: Dispose the image to free memory
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    image.dispose();

    // Use debugPrint instead of print for better logging
    debugPrint('Image dimensions: ${width}x$height');

    return AnnotationImageData(
      file: file,
      bytes: bytes,
      width: width,
      height: height,
    );
  }

  // Alternative method - try this if above still causes zoom
  Future<AnnotationImageData?> pickImageFromSourceSimple(
    ImageSource source,
  ) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();

    // Use a simpler approach - let the annotation widget handle dimensions
    return AnnotationImageData(
      file: file,
      bytes: bytes,
      width: 1.0, // Let widget auto-scale
      height: 1.0, // Let widget auto-scale
    );
  }

  // Get current annotations
  Future<List<AnnotationDetails>> getAnnotations() async {
    return await _controller.getData();
  }

  // Clear all annotations
  void clearAnnotations() {
    _controller.clear();
  }

  // Add annotation manually
  void addAnnotation(
    double x,
    double y,
    double width,
    double height,
    String label,
  ) {
    _controller.addAnnotation(x, y, width, height, label);
  }

  // Convert annotations to detection tags
  List<String> convertToDetectionTags(List<AnnotationDetails> annotations) {
    return annotations
        .map(
          (annotation) =>
              'Road Concern: ${annotation.label.isNotEmpty ? annotation.label : "Unlabeled"}',
        )
        .toList();
  }
}

class AnnotationImageData {
  final File file;
  final Uint8List bytes;
  final double width;
  final double height;

  AnnotationImageData({
    required this.file,
    required this.bytes,
    required this.width,
    required this.height,
  });
}
