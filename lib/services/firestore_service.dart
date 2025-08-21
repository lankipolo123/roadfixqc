// lib/services/firestore_service.dart (CLEAN - NO DUPLICATE TRANSACTIONS)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadfix/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  Future<void> createUser(UserModel user) async {
    try {
      if (user.uid == null || user.uid!.isEmpty) {
        throw Exception('User UID is required but was null or empty');
      }

      await _db.collection(_usersCollection).doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection(_usersCollection).doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(_usersCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot query = await _db
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  Future<List<UserModel>> getAllActiveUsers() async {
    try {
      QuerySnapshot query = await _db
          .collection(_usersCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('joinedAt', descending: true)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active users: $e');
    }
  }

  Future<void> updateUserStatus(String uid, bool isActive) async {
    try {
      await _db.collection(_usersCollection).doc(uid).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Stream<List<UserModel>> getActiveUsersStream() {
    return _db
        .collection(_usersCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map(
          (query) =>
              query.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      return await getUser(currentUser.uid);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Stream<UserModel?> getCurrentUserStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }
    return getUserStream(currentUser.uid);
  }

  Future<void> updateUserProfile({
    required String uid,
    String? fname,
    String? lname,
    String? mi,
    String? contactNumber,
    String? address,
    String? userProfile,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (fname != null) {
        updates['fname'] = fname;
      }
      if (lname != null) {
        updates['lname'] = lname;
      }
      if (mi != null) {
        updates['mi'] = mi;
      }
      if (contactNumber != null) {
        updates['contactNumber'] = contactNumber;
      }
      if (address != null) {
        updates['address'] = address;
      }
      if (userProfile != null) {
        updates['userProfile'] = userProfile;
      }

      if (updates.isNotEmpty) {
        await _db.collection(_usersCollection).doc(uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ✅ REMOVED ALL TRANSACTION METHODS
  // ReportService handles all user count updates in its own transaction

  // Simple update method (no transaction - for direct updates only)
  Future<void> updateUserReportCounts({
    required String uid,
    required int reportsCount,
    required int pendingCount,
    required int resolvedCount,
    required int rejectedCount,
  }) async {
    try {
      await _db.collection(_usersCollection).doc(uid).update({
        'reportsCount': reportsCount,
        'pendingCount': pendingCount,
        'resolvedCount': resolvedCount,
        'rejectedCount': rejectedCount,
      });
    } catch (e) {
      throw Exception('Failed to update user report counts: $e');
    }
  }
}
