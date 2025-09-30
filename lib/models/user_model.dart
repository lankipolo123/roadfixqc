// lib/models/user_model.dart
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
  final String userProfile; // clean ImageKit url (no ?updatedAt)
  final Timestamp? joinedAt;

  // TOTP fields
  final bool totpEnabled;
  final String? totpSecret;
  final Timestamp? totpEnabledAt;

  // lastUpdated: millisecondsSinceEpoch — used for cache-busting
  final int? lastUpdated;

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
    this.lastUpdated,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    int? parsedLastUpdated;
    final rawLast = data['lastUpdated'];
    if (rawLast is int) {
      parsedLastUpdated = rawLast;
    } else if (rawLast is Timestamp) {
      parsedLastUpdated = rawLast.millisecondsSinceEpoch;
    } else if (rawLast is String) {
      // in case it's stored as string number
      parsedLastUpdated = int.tryParse(rawLast);
    }

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
      lastUpdated: parsedLastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
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
    };

    if (lastUpdated != null) {
      map['lastUpdated'] = lastUpdated;
    }
    return map;
  }

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
    int? lastUpdated,
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
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get fullName {
    final middle = mi.isNotEmpty ? ' $mi ' : ' ';
    return '$fname$middle$lname'.trim();
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, totpEnabled: $totpEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
