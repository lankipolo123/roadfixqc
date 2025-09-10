// lib/services/user_service.dart (FIXED TO WORK WITH YOUR USERMODEL)
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/models/profile_summary.dart';
import 'package:roadfix/services/firestore_service.dart';

class UserService {
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user data (for homepage, profile, reporting)
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _firestoreService.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Stream current user data (real-time updates for all screens)
  Stream<UserModel?> getCurrentUserStream() {
    return _firestoreService.getCurrentUserStream();
  }

  // Convert UserModel to ProfileSummary with REAL report counts from database
  ProfileSummary userToProfileSummary(UserModel user) {
    return ProfileSummary(
      name: user.fullName,
      email: user.email,
      phone: user.contactNumber.isNotEmpty
          ? user.contactNumber
          : 'No phone number',
      location: user.address.isNotEmpty ? user.address : 'No address provided',
      imageUrl: user.userProfile,
      // ✅ FIXED: Use real counts from UserModel (now includes approvedCount)
      reportsCount: user.reportsCount,
      pendingCount: user.pendingCount,
      approvedCount: user.approvedCount,
      resolvedCount: user.resolvedCount,
    );
  }

  // Get current user's profile summary (for profile screen)
  Future<ProfileSummary?> getCurrentUserProfileSummary() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;
      return userToProfileSummary(user);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Stream profile summary (for profile screen)
  Stream<ProfileSummary?> getCurrentUserProfileSummaryStream() {
    return getCurrentUserStream().map((user) {
      if (user == null) return null;
      return userToProfileSummary(user);
    });
  }

  // Update profile method to use userProfile field
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? middleInitial,
    String? contactNumber,
    String? address,
    String? imageUrl, // Keep this parameter name for compatibility
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser?.uid == null) throw Exception('No user logged in');

      await _firestoreService.updateUserProfile(
        uid: currentUser!.uid!,
        fname: firstName,
        lname: lastName,
        mi: middleInitial,
        contactNumber: contactNumber,
        address: address,
        userProfile: imageUrl, // Map imageUrl parameter to userProfile field
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user's full name (for homepage greeting)
  Future<String> getCurrentUserName() async {
    try {
      final user = await getCurrentUser();
      return user?.fullName ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  // Check if user profile is complete (for reporting requirements)
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
}
