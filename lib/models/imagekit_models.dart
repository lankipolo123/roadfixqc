class ImageKitUploadResponse {
  final String fileId;
  final String fileUrl;
  final String? thumbnailUrl;
  final String fileName;
  final int fileSize;
  final List<String> tags;
  final DateTime uploadedAt;

  ImageKitUploadResponse({
    required this.fileId,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileName,
    required this.fileSize,
    required this.tags,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory ImageKitUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageKitUploadResponse(
      fileId: json['fileId'] ?? '',
      fileUrl: json['url'] ?? json['fileUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      fileName: json['name'] ?? json['fileName'] ?? '',
      fileSize: json['size'] ?? json['fileSize'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileUrl': fileUrl,
    'thumbnailUrl': thumbnailUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'tags': tags,
    'uploadedAt': uploadedAt.toIso8601String(),
  };
}

class ImageKitError extends Error {
  final String message;
  final String? code;

  ImageKitError(this.message, {this.code});

  @override
  String toString() =>
      'ImageKitError: $message${code != null ? ' ($code)' : ''}';
}
