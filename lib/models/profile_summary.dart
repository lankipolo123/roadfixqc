// lib/models/profile_summary.dart
class ProfileSummary {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String imageUrl;
  final int reportsCount;
  final int pendingCount;
  final int approvedCount;
  final int resolvedCount;

  const ProfileSummary({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.imageUrl,
    required this.reportsCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.resolvedCount,
  });

  // Factory method for creating from JSON
  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      reportsCount: json['reportsCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      approvedCount: json['approvedCount'] ?? 0,
      resolvedCount: json['resolvedCount'] ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'imageUrl': imageUrl,
      'reportsCount': reportsCount,
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
      'resolvedCount': resolvedCount,
    };
  }
}
