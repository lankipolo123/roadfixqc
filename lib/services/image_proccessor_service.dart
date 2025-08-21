import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/detection_result.dart';
import '../widgets/detection_widgets/bounding_box.dart';

class ImageProcessorService {
  static Future<String?> createProcessedImage(
    File originalImage,
    ui.Image decodedImage,
    List<DetectionResult> detections,
  ) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      // Draw original image
      final paint = Paint();
      canvas.drawImageRect(
        decodedImage,
        Rect.fromLTWH(
          0,
          0,
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
        paint,
      );

      // Draw bounding boxes
      final boundingBoxPainter = BoundingBoxPainter(detections: detections);
      boundingBoxPainter.paint(canvas, imageSize);

      // Convert to image and save
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        decodedImage.width,
        decodedImage.height,
      );

      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final processedFile = File(
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await processedFile.writeAsBytes(buffer);
        return processedFile.path;
      }
    } catch (e) {
      debugPrint('Error creating processed image: $e');
    }

    return originalImage.path; // Fallback
  }
}
