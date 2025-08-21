import 'dart:io';
import 'package:roadfix/constant/image_kit_constant.dart';

class FileValidator {
  static void validateImageFile(File file) {
    if (!file.existsSync()) {
      throw Exception('Image file does not exist');
    }

    final fileSize = file.lengthSync();
    if (fileSize > ImageKitConstants.maxFileSize) {
      final maxMB = (ImageKitConstants.maxFileSize / (1024 * 1024))
          .toStringAsFixed(1);
      throw Exception('File too large. Max: ${maxMB}MB');
    }

    final extension = file.path.split('.').last.toLowerCase();
    if (!ImageKitConstants.allowedFormats.contains(extension)) {
      throw Exception('Unsupported format: $extension');
    }
  }
}
