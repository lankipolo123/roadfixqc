import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageCroppingUtility {
  /// Crop the bottom portion of an image (road region)
  /// Returns both original and cropped image
  static Future<CroppedImageResult> cropRoadRegion(
    File imageFile, {
    double cropRatio = 0.4, // Bottom 40% by default
  }) async {
    try {
      debugPrint('📐 Cropping road region from image...');

      // Load original image
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      final width = originalImage.width;
      final height = originalImage.height;

      // Calculate crop region (bottom portion)
      final cropHeight = (height * cropRatio).round();
      final cropY = height - cropHeight;

      debugPrint('   Original: ${width}x$height');
      debugPrint('   Crop region: ${width}x$cropHeight (bottom $cropRatio)');

      // Crop the bottom portion
      final croppedImage = img.copyCrop(
        originalImage,
        x: 0,
        y: cropY,
        width: width,
        height: cropHeight,
      );

      // Upscale cropped region back to original height (for YOLO input)
      final upscaledCropped = img.copyResize(
        croppedImage,
        width: width,
        height: height,
        interpolation: img.Interpolation.cubic, // Better quality
      );

      debugPrint(
        '   Upscaled cropped to: ${upscaledCropped.width}x${upscaledCropped.height}',
      );

      // Save upscaled cropped image to temp file
      final tempDir = imageFile.parent;
      final croppedPath =
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(
        img.encodeJpg(upscaledCropped, quality: 95),
      );

      debugPrint('✅ Cropped image saved: $croppedPath');

      return CroppedImageResult(
        originalFile: imageFile,
        croppedFile: croppedFile,
        cropStartY: cropY,
        cropHeight: cropHeight,
        originalHeight: height,
        cropRatio: cropRatio,
      );
    } catch (e) {
      debugPrint('❌ Cropping error: $e');
      rethrow;
    }
  }

  /// Remap detection coordinates from cropped image to original image
  static List<RemappedDetection> remapDetections({
    required List<dynamic> croppedDetections,
    required int cropStartY,
    required int originalHeight,
    required int cropHeight,
  }) {
    final remapped = <RemappedDetection>[];

    for (var detection in croppedDetections) {
      // Detection bbox is in normalized coords (0-1) relative to cropped image
      final x = detection.boundingBox.x;
      final y = detection.boundingBox.y;
      final width = detection.boundingBox.width;
      final height = detection.boundingBox.height;

      // Remap Y coordinates from cropped space to original space
      // Cropped image was bottom portion, then upscaled
      // So we need to:
      // 1. Scale Y back down to actual crop size
      // 2. Offset by cropStartY
      // 3. Normalize to original height

      final actualCropY = y * (cropHeight / originalHeight);
      final remappedY = (cropStartY / originalHeight) + actualCropY;
      final remappedHeight = height * (cropHeight / originalHeight);

      remapped.add(
        RemappedDetection(
          className: detection.className,
          confidence: detection.confidence,
          x: x, // X stays same (no horizontal crop)
          y: remappedY,
          width: width,
          height: remappedHeight,
          source: 'cropped',
        ),
      );
    }

    return remapped;
  }
}

class CroppedImageResult {
  final File originalFile;
  final File croppedFile;
  final int cropStartY;
  final int cropHeight;
  final int originalHeight;
  final double cropRatio;

  CroppedImageResult({
    required this.originalFile,
    required this.croppedFile,
    required this.cropStartY,
    required this.cropHeight,
    required this.originalHeight,
    required this.cropRatio,
  });
}

class RemappedDetection {
  final String className;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;
  final String source;

  RemappedDetection({
    required this.className,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.source,
  });
}
