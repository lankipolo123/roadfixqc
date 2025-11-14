// lib/services/email_service.dart
// Service to send custom HTML emails via Vercel API

import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Vercel API endpoint
  static const String _baseUrl = 'https://roadfix-dashboard.vercel.app/api';

  /// Send verification email via Vercel API
  /// Returns null on success, error message on failure
  static Future<String?> sendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-verification-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return null; // Success
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

  /// Send password reset email via Vercel API
  /// Returns null on success, error message on failure
  static Future<String?> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-reset-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return null; // Success
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
