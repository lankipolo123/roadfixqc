// lib/services/imagekit_transformer.dart
import 'package:roadfix/constant/image_kit_constant.dart';

class ImageKitTransformer {
  static String transform(String url, Map<String, dynamic> params) {
    if (!url.contains(ImageKitConstants.urlEndpoint) || params.isEmpty) {
      return url;
    }

    final transformations = params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}-${e.value}')
        .join(',');

    return url.replaceFirst(
      RegExp(r'(https://ik\.imagekit\.io/[^/]+)(/.*)?'),
      '\$1/tr:$transformations\$2',
    );
  }

  static String thumbnail(String url) =>
      transform(url, ImageKitConstants.thumbnailTransform);
  static String detail(String url) =>
      transform(url, ImageKitConstants.detailTransform);

  static String avatar(String url, {int size = 100}) {
    final params = Map<String, dynamic>.from(ImageKitConstants.avatarTransform);
    params['w'] = size;
    params['h'] = size;
    return transform(url, params);
  }

  static String custom(
    String url, {
    int? width,
    int? height,
    String? crop,
    int? quality,
    String? format,
    String? focus,
  }) {
    final params = <String, dynamic>{};
    if (width != null) params['w'] = width;
    if (height != null) params['h'] = height;
    if (crop != null) params['cm'] = crop;
    if (quality != null) params['q'] = quality;
    if (format != null) params['f'] = format;
    if (focus != null) params['fo'] = focus;
    return transform(url, params);
  }
}
