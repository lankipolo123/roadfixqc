import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressionUtility {
  static Future<File> compressImageAdaptive(File imageFile) async {
    try {
      final sizeInBytes = await imageFile.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      int quality;
      if (sizeInMB > 5) {
        quality = 60;
      } else if (sizeInMB > 3) {
        quality = 70;
      } else {
        quality = 80;
      }

      debugPrint(
        '📦 Compressing image: ${sizeInMB.toStringAsFixed(2)}MB at $quality% quality',
      );

      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        return imageFile;
      }

      final compressedSize =
          await File(compressedFile.path).length() / (1024 * 1024);
      debugPrint('✅ Compressed to: ${compressedSize.toStringAsFixed(2)}MB');

      return File(compressedFile.path);
    } catch (e) {
      debugPrint('❌ Compression error: $e');
      return imageFile;
    }
  }
}
