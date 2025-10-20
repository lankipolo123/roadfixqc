import 'package:image_picker/image_picker.dart';

import '../widgets/dialog_widgets/detection_image_source.dart';

/// ✅ Helper utility to convert ImageSourceOption to ImageSource
/// This is useful when you need to use the built-in ImagePicker
class ImageSourceConverter {
  /// Convert ImageSourceOption to ImageSource
  /// Returns null if distanceCamera is selected (since it's not a standard ImageSource)
  static ImageSource? toImageSource(ImageSourceOption option) {
    switch (option) {
      case ImageSourceOption.camera:
        return ImageSource.camera;
      case ImageSourceOption.gallery:
        return ImageSource.gallery;
      case ImageSourceOption.distanceCamera:
        // Distance camera is custom, not a standard ImageSource
        return null;
    }
  }

  /// Check if the option is a standard image source
  static bool isStandardSource(ImageSourceOption option) {
    return option == ImageSourceOption.camera ||
        option == ImageSourceOption.gallery;
  }

  /// Check if the option is the distance camera
  static bool isDistanceCamera(ImageSourceOption option) {
    return option == ImageSourceOption.distanceCamera;
  }
}
