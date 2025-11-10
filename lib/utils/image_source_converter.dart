import 'package:image_picker/image_picker.dart';

import '../widgets/dialog_widgets/detection_image_source.dart';

/// Helper utility to convert ImageSourceOption to ImageSource
class ImageSourceConverter {
  /// Convert ImageSourceOption to ImageSource
  static ImageSource? toImageSource(ImageSourceOption option) {
    switch (option) {
      case ImageSourceOption.camera:
        return ImageSource.camera;
      case ImageSourceOption.gallery:
        return ImageSource.gallery;
    }
  }

  /// Check if the option is a standard image source
  static bool isStandardSource(ImageSourceOption option) {
    return option == ImageSourceOption.camera ||
        option == ImageSourceOption.gallery;
  }
}
