// lib/utils/jwt_helper.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class JWTHelper {
  static String generateUploadToken(
    String privateKey, {
    String? fileName,
    String? folder,
    List<String>? tags,
    Duration expiry = const Duration(hours: 1),
  }) {
    try {
      final header = {'alg': 'HS256', 'typ': 'JWT'};

      final now = DateTime.now();
      final payload = {
        'iss': 'roadfix-app',
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(expiry).millisecondsSinceEpoch ~/ 1000,
      };

      // Add optional claims
      if (fileName != null) payload['fileName'] = fileName;
      if (folder != null) payload['folder'] = folder;
      if (tags != null && tags.isNotEmpty) payload['tags'] = tags;

      if (kDebugMode) {
        print('JWT payload: $payload');
      }

      final headerEncoded = _base64UrlEncode(jsonEncode(header));
      final payloadEncoded = _base64UrlEncode(jsonEncode(payload));
      final signature = _generateSignature(
        '$headerEncoded.$payloadEncoded',
        privateKey,
      );

      final token = '$headerEncoded.$payloadEncoded.$signature';

      if (kDebugMode) {
        print('JWT token generated successfully');
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('JWT generation error: $e');
      }
      throw Exception('Failed to generate JWT token: $e');
    }
  }

  static String _base64UrlEncode(String data) {
    final bytes = utf8.encode(data);
    final base64 = base64Url.encode(bytes);
    // Remove padding for URL-safe base64
    return base64.replaceAll('=', '');
  }

  static String _generateSignature(String data, String secret) {
    try {
      final key = utf8.encode(secret);
      final dataBytes = utf8.encode(data);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(dataBytes);
      final signature = base64Url.encode(digest.bytes);
      return signature.replaceAll('=', '');
    } catch (e) {
      if (kDebugMode) {
        print('Signature generation error: $e');
      }
      throw Exception('Failed to generate signature: $e');
    }
  }

  /// Validate if token is expired (optional utility)
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      // Add padding if needed
      final paddedPayload = payload + '=' * (4 - payload.length % 4);
      final decodedPayload = utf8.decode(base64Url.decode(paddedPayload));
      final payloadJson = jsonDecode(decodedPayload);

      final exp = payloadJson['exp'] as int?;
      if (exp == null) return true;

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true; // If we can't parse, consider it expired
    }
  }
}
