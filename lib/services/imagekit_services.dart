import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadfix/constant/image_kit_constant.dart';
import 'package:roadfix/services/image_kit_transformer.dart';
import 'package:roadfix/utils/image_compression_utility.dart';
import '../models/imagekit_models.dart';
import '../utils/file_validator.dart';
import 'imagekit_uploader.dart';

class ImageKitService {
  static final ImageKitService _instance = ImageKitService._internal();
  factory ImageKitService() => _instance;
  ImageKitService._internal();

  final _auth = FirebaseAuth.instance;

  /// Upload report image
  Future<ImageKitUploadResponse> uploadReportImage(
    File imageFile, {
    String? reportId,
    Function(double)? onProgress,
  }) async {
    try {
      FileValidator.validateImageFile(imageFile);

      // ✅ COMPRESS IMAGE
      final compressedImage =
          await ImageCompressionUtility.compressImageAdaptive(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'report_${reportId ?? timestamp}.jpg';

      final response = await ImageKitUploader.upload(
        compressedImage,
        fileName: fileName,
        folder: ImageKitConstants.reportsFolder,
        tags: ['roadfix', 'report', reportId ?? 'unknown'],
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile image - FIXED: Same filename = overwrite
  Future<ImageKitUploadResponse> uploadProfileImage(
    File imageFile, {
    String? userId,
    Function(double)? onProgress,
  }) async {
    try {
      FileValidator.validateImageFile(imageFile);

      final targetUserId = userId ?? _auth.currentUser?.uid ?? 'anonymous';

      final fileName = 'profile_$targetUserId.jpg';

      final response = await ImageKitUploader.upload(
        imageFile,
        fileName: fileName,
        folder: ImageKitConstants.profilesFolder,
        tags: ['roadfix', 'profile', targetUserId],
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // URL transformation methods
  String getReportThumbnail(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    return ImageKitTransformer.thumbnail(imageUrl);
  }

  String getReportDetailImage(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    return ImageKitTransformer.detail(imageUrl);
  }

  String getProfileAvatar(String imageUrl, {int size = 100}) {
    if (imageUrl.isEmpty) return '';
    return ImageKitTransformer.avatar(imageUrl, size: size);
  }

  String getCustomOptimizedImage(
    String imageUrl, {
    int? width,
    int? height,
    String? crop,
    int? quality,
    String? format,
    String? focus,
  }) {
    if (imageUrl.isEmpty) return '';

    return ImageKitTransformer.custom(
      imageUrl,
      width: width,
      height: height,
      crop: crop,
      quality: quality,
      format: format,
      focus: focus,
    );
  }
}
