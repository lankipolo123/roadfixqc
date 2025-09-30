import 'package:flutter/foundation.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/services/firestore_service.dart';

class UserService {
  final FirestoreService _firestoreService = FirestoreService();

  // Cache for user data to avoid unnecessary calls
  UserModel? _cachedUser;
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  Future<UserModel?> getCurrentUser() async {
    try {
      // Return cached user if still valid
      if (_cachedUser != null &&
          _lastCacheTime != null &&
          DateTime.now().difference(_lastCacheTime!) < _cacheTimeout) {
        return _cachedUser;
      }

      // Fetch fresh user data
      final user = await _firestoreService.getCurrentUser();

      // Update cache
      _cachedUser = user;
      _lastCacheTime = DateTime.now();

      return user;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Stream<UserModel?> getCurrentUserStream() {
    // Stream from FirestoreService directly
    return _firestoreService.getCurrentUserStream();
  }

  /// Get user once without caching (for real-time updates)
  Future<UserModel?> getCurrentUserFresh() async {
    try {
      final user = await _firestoreService.getCurrentUser();

      // Update cache with fresh data
      _cachedUser = user;
      _lastCacheTime = DateTime.now();

      return user;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Clear cache when user data is updated
  void clearCache() {
    _cachedUser = null;
    _lastCacheTime = null;
  }

  /// Update profile; automatically sets lastUpdated if not provided.
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? middleInitial,
    String? contactNumber,
    String? address,
    String? userProfile,
    int? lastUpdated,
  }) async {
    try {
      final currentUser = await _firestoreService.getCurrentUser();
      if (currentUser?.uid == null) throw Exception('No user logged in');

      final uid = currentUser!.uid!;
      final effectiveLastUpdated =
          lastUpdated ?? DateTime.now().millisecondsSinceEpoch;

      await _firestoreService.updateUserProfile(
        uid: uid,
        fname: firstName,
        lname: lastName,
        mi: middleInitial,
        contactNumber: contactNumber,
        address: address,
        userProfile: userProfile,
        lastUpdated: effectiveLastUpdated,
      );

      // Clear cache after update to ensure fresh data on next fetch
      clearCache();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String> getCurrentUserName() async {
    try {
      final user = await getCurrentUser();
      return user?.fullName ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  Future<bool> isProfileComplete() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;
      return user.fname.isNotEmpty &&
          user.lname.isNotEmpty &&
          user.email.isNotEmpty &&
          user.contactNumber.isNotEmpty &&
          user.address.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get user stream but with better error handling
  Stream<UserModel?> getCurrentUserStreamSafe() {
    return getCurrentUserStream().handleError((error) {
      if (kDebugMode) {
        print('User stream error: $error');
      }
      return null;
    });
  }
}
