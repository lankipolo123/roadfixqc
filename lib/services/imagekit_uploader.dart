// lib/services/imagekit_uploader.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:roadfix/constant/image_kit_constant.dart';
import '../models/imagekit_models.dart';

class ImageKitUploader {
  static Future<ImageKitUploadResponse> upload(
    File file, {
    required String fileName,
    required String folder,
    List<String>? tags,
  }) async {
    try {
      if (kDebugMode) {
        print('Starting ImageKit upload...');
        print('File path: ${file.path}');
        print('File exists: ${file.existsSync()}');
        print('File name: $fileName');
        print('Folder: $folder');
      }

      // Generate basic auth (we don't actually need JWT for uploads)
      if (kDebugMode) {
        print('Setting up basic authentication...');
      }

      if (kDebugMode) {
        print('Using basic auth with private key');
      }

      // Create multipart request
      final uri = Uri.parse(ImageKitConstants.uploadEndpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers with correct ImageKit authentication
      request.headers.addAll({
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${ImageKitConstants.privateKey}:'))}',
      });

      // Get MIME type
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      if (kDebugMode) {
        print('MIME type: $mimeType');
      }

      // Add file to request
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Add form fields
      request.fields.addAll({
        'fileName': fileName,
        'folder': folder,
        'tags': (tags ?? []).join(','),
        'useUniqueFileName': 'false',
        'responseFields':
            'fileId,url,thumbnailUrl,name,size,filePath,tags,folder',
      });

      if (kDebugMode) {
        print('Request fields: ${request.fields}');
        print('Sending request to: ${uri.toString()}');
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ImageKitUploadResponse.fromJson(responseData);
      } else {
        // Log the full error for debugging
        String errorMessage = 'Upload failed: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage +=
                ' - ${errorData['message'] ?? errorData['error'] ?? response.body}';
          } catch (e) {
            errorMessage += ' - ${response.body}';
          }
        }

        if (kDebugMode) {
          print('Upload error details: $errorMessage');
        }

        throw ImageKitError(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Upload exception: $e');
      }

      if (e is ImageKitError) {
        rethrow;
      }
      throw ImageKitError('Upload error: $e');
    }
  }
}
