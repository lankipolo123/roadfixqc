// lib/services/connectivity_service.dart
import 'dart:io';

class ConnectivityService {
  /// Checks if device has internet connection by attempting to lookup Google's DNS
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Alternative method using Firebase's servers for testing connectivity
  static Future<bool> hasFirebaseConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'firebase.google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
