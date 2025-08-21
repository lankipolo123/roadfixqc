// lib/models/user_model.dart (UPDATED WITH REPORT COUNTS)
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String fname;
  final String lname;
  final String mi;
  final String email;
  final String contactNumber;
  final String address;
  final bool isActive;
  final String role;
  final String userProfile;
  final Timestamp? joinedAt;

  // Report counts (updated when reports are submitted/status changed)
  final int reportsCount;
  final int pendingCount;
  final int resolvedCount;
  final int rejectedCount;

  const UserModel({
    this.uid,
    required this.fname,
    required this.lname,
    required this.mi,
    required this.email,
    required this.contactNumber,
    required this.address,
    this.isActive = true,
    this.role = 'user',
    this.userProfile = '',
    this.joinedAt,
    this.reportsCount = 0,
    this.pendingCount = 0,
    this.resolvedCount = 0,
    this.rejectedCount = 0,
  });

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      fname: data['fname'] ?? '',
      lname: data['lname'] ?? '',
      mi: data['mi'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
      role: data['role'] ?? 'user',
      userProfile: data['userProfile'] ?? '',
      joinedAt: data['joinedAt'],
      reportsCount: data['reportsCount'] ?? 0,
      pendingCount: data['pendingCount'] ?? 0,
      resolvedCount: data['resolvedCount'] ?? 0,
      rejectedCount: data['rejectedCount'] ?? 0,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'fname': fname,
      'lname': lname,
      'mi': mi,
      'email': email,
      'contactNumber': contactNumber,
      'address': address,
      'isActive': isActive,
      'role': role,
      'userProfile': userProfile,
      'joinedAt': joinedAt ?? FieldValue.serverTimestamp(),
      'reportsCount': reportsCount,
      'pendingCount': pendingCount,
      'resolvedCount': resolvedCount,
      'rejectedCount': rejectedCount,
    };
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? fname,
    String? lname,
    String? mi,
    String? email,
    String? contactNumber,
    String? address,
    bool? isActive,
    String? role,
    String? userProfile,
    Timestamp? joinedAt,
    int? reportsCount,
    int? pendingCount,
    int? resolvedCount,
    int? rejectedCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      mi: mi ?? this.mi,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      userProfile: userProfile ?? this.userProfile,
      joinedAt: joinedAt ?? this.joinedAt,
      reportsCount: reportsCount ?? this.reportsCount,
      pendingCount: pendingCount ?? this.pendingCount,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
    );
  }

  // Helper getter for full name
  String get fullName {
    final middle = mi.isNotEmpty ? ' $mi ' : ' ';
    return '$fname$middle$lname'.trim();
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, reportsCount: $reportsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
