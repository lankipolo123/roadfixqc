class ImageKitConstants {
  static const String publicKey = 'public_Nj2ApVdQr9TIVMApBquPRDWQypo=';
  static const String privateKey = 'private_1X5U8Rq1IoHBkyG4moJUtmwRyos=';
  static const String urlEndpoint = 'https://ik.imagekit.io/roadfixqc';
  static const String uploadEndpoint =
      'https://upload.imagekit.io/api/v1/files/upload';

  static const String reportsFolder = '/roadfix/reports';
  static const String profilesFolder = '/roadfix/profiles';

  static const int maxFileSize = 50 * 1024 * 1024; // 50MB (increased from 10MB)
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  static const Map<String, dynamic> thumbnailTransform = {
    'w': 150,
    'h': 150,
    'cm': 'maintain_ratio',
    'q': 80,
    'f': 'webp',
  };

  static const Map<String, dynamic> detailTransform = {
    'w': 800,
    'q': 85,
    'f': 'webp',
    'pr': 'true',
  };

  static const Map<String, dynamic> avatarTransform = {
    'cm': 'maintain_ratio',
    'fo': 'face',
    'q': 90,
    'f': 'webp',
  };
}
