class ImageKitConstants {
  static const String publicKey = 'public_Nj2ApVdQr9TIVMApBquPRDWQypo=';
  static const String privateKey = 'private_1X5U8Rq1IoHBkyG4moJUtmwRyos=';
  static const String urlEndpoint = 'https://ik.imagekit.io/roadfixqc';
  static const String uploadEndpoint =
      'https://upload.imagekit.io/api/v1/files/upload';

  static const String reportsFolder = '/roadfix/reports';
  static const String profilesFolder = '/roadfix/profiles';

  // UPDATED: Reduced from 50MB to 25MB for capstone requirement
  static const int maxFileSize = 25 * 1024 * 1024; // 25MB
  static const int minFileSize = 100 * 1024; // 100KB minimum
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // NEW: Security constants
  static const int spamCooldownMinutes = 5; // 5 minutes between reports
  static const int maxReportsPerDay = 10;
  static const int maxDescriptionLength = 500;
  static const List<String> forbiddenPatterns = [
    '<script',
    '</script>',
    'javascript:',
    'onclick=',
    'onerror=',
    'onload=',
    'eval(',
    'document.',
    'window.',
    'alert(',
    'setTimeout',
    'setInterval',
    'Function(',
    'constructor',
  ];

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
