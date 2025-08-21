// lib/models/imagekit_upload_response.dart
class ImageKitUploadResponse {
  final String fileId;
  final String fileUrl;
  final String? thumbnailUrl;
  final String fileName;
  final String filePath;
  final int fileSize;
  final List<String> tags;
  final String? folder;
  final DateTime uploadedAt;

  ImageKitUploadResponse({
    required this.fileId,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.tags,
    this.folder,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  // Convert from ImageKit SDK response
  factory ImageKitUploadResponse.fromImageKitResponse(dynamic response) {
    return ImageKitUploadResponse(
      fileId: response.fileId ?? '',
      fileUrl: response.url ?? response.fileUrl ?? '',
      thumbnailUrl: response.thumbnailUrl,
      fileName: response.name ?? response.fileName ?? '',
      filePath: response.filePath ?? '',
      fileSize: response.size ?? 0,
      tags: response.tags != null ? List<String>.from(response.tags) : [],
      folder: response.folder,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'tags': tags,
      'folder': folder,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ImageKitUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageKitUploadResponse(
      fileId: json['fileId'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      folder: json['folder'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ImageKitUploadResponse(fileId: $fileId, fileName: $fileName, fileSize: $fileSize)';
  }
}
