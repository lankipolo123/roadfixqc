// lib/models/user_model.dart (UPDATED WITH TOTP FIELDS)
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

  // TOTP fields
  final bool totpEnabled;
  final String? totpSecret;
  final Timestamp? totpEnabledAt;

  // Report counts (updated when reports are submitted/status changed)
  final int reportsCount;
  final int pendingCount;
  final int approvedCount;
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
    this.totpEnabled = false,
    this.totpSecret,
    this.totpEnabledAt,
    this.reportsCount = 0,
    this.pendingCount = 0,
    this.approvedCount = 0,
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
      totpEnabled: data['totpEnabled'] ?? false,
      totpSecret: data['totpSecret'],
      totpEnabledAt: data['totpEnabledAt'],
      reportsCount: data['reportsCount'] ?? 0,
      pendingCount: data['pendingCount'] ?? 0,
      approvedCount: data['approvedCount'] ?? 0,
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
      'totpEnabled': totpEnabled,
      'totpSecret': totpSecret,
      'totpEnabledAt': totpEnabledAt,
      'reportsCount': reportsCount,
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
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
    bool? totpEnabled,
    String? totpSecret,
    Timestamp? totpEnabledAt,
    int? reportsCount,
    int? pendingCount,
    int? approvedCount,
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
      totpEnabled: totpEnabled ?? this.totpEnabled,
      totpSecret: totpSecret ?? this.totpSecret,
      totpEnabledAt: totpEnabledAt ?? this.totpEnabledAt,
      reportsCount: reportsCount ?? this.reportsCount,
      pendingCount: pendingCount ?? this.pendingCount,
      approvedCount: approvedCount ?? this.approvedCount,
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
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, reportsCount: $reportsCount, totpEnabled: $totpEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
