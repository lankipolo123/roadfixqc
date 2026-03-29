// lib/services/email_service.dart
// Service to send custom HTML emails via Vercel API

import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _baseUrl = 'https://roadfix-dashboard.vercel.app/api';

  static Future<String?> sendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-verification-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'mode': 'user'}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return null;
        } else {
          return data['message'] ?? 'Failed to send verification email';
        }
      } else {
        final data = json.decode(response.body);
        return data['message'] ?? 'Failed to send verification email (${response.statusCode})';
      }
    } catch (e) {
      return 'Failed to send verification email: ${e.toString()}';
    }
  }

  static Future<String?> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-reset-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'mode': 'user'}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return null;
        } else {
          return data['message'] ?? 'Failed to send reset email';
        }
      } else {
        final data = json.decode(response.body);
        return data['message'] ?? 'Failed to send reset email (${response.statusCode})';
      }
    } catch (e) {
      return 'Failed to send reset email: ${e.toString()}';
    }
  }
}
