import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:roadfix/utils/custom_annotation_controller.dart';

class AnnotationService {
  final CustomAnnotationController _controller = CustomAnnotationController();
  final ImagePicker _picker = ImagePicker();

  CustomAnnotationController get controller => _controller;

  Future<AnnotationImageData?> pickImageFromSource(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();

    return AnnotationImageData(file: file, bytes: bytes);
  }

  List<Map<String, dynamic>> getAnnotations() {
    return _controller.getAnnotationData();
  }

  void clearAnnotations() {
    _controller.clear();
  }

  List<String> convertToDetectionTags(List<Map<String, dynamic>> annotations) {
    return annotations.map<String>((annotation) {
      final label = annotation['label'] ?? 'Road Concern';
      return label;
    }).toList();
  }

  // Optimized: Draw annotations on full-res image using normalized coordinates
  Future<String?> createAnnotatedImage(
    File originalImage,
    Uint8List imageBytes,
    Color boxColor,
  ) async {
    try {
      // Decode image
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      // Create canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw original image
      canvas.drawImage(image, Offset.zero, Paint());

      // Draw annotations using normalized coordinates
      final paint = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0;

      for (final annotation in _controller.annotations) {
        final rect = annotation.rect(imageSize);

        canvas.drawRect(rect, paint);

        // Draw label
        final textSpan = TextSpan(
          text: annotation.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        final labelX = rect.left;
        final labelY = (rect.top - textPainter.height - 8).clamp(
          0.0,
          imageSize.height,
        );

        final labelBgRect = Rect.fromLTWH(
          labelX,
          labelY,
          textPainter.width + 16,
          textPainter.height + 8,
        );

        canvas.drawRect(
          labelBgRect,
          Paint()..color = boxColor.withValues(alpha: 0.9),
        );

        textPainter.paint(canvas, Offset(labelX + 8, labelY + 4));
      }

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);

      // Use PNG with compression for faster encoding
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final annotatedFile = File(
          '${directory.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await annotatedFile.writeAsBytes(buffer);

        image.dispose();
        img.dispose();
        return annotatedFile.path;
      }

      image.dispose();
      img.dispose();
    } catch (e) {
      debugPrint('Error creating annotated image: $e');
    }

    return originalImage.path;
  }
}

class AnnotationImageData {
  final File file;
  final Uint8List bytes;

  AnnotationImageData({required this.file, required this.bytes});
}
