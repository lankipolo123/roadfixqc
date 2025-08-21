// lib/models/report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id; // Document ID from Firestore

  // User-facing fields (filled by user)
  final String description;
  final String location; // Keep as String for address
  final List<String> imageUrl;
  final String reportType;
  final List<String> tags;

  // Auto-filled fields (from user profile + system)
  final String userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final Timestamp reportedAt;
  final String status; // pending/resolved/rejected

  // Admin-only fields (empty initially)
  final String adminNotes;
  final String reviewedBy;
  final Timestamp? reviewedAt;
  final String priority; // low/medium/high/urgent

  const ReportModel({
    this.id,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.reportType,
    required this.tags,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.reportedAt,
    this.status = 'pending',
    this.adminNotes = '',
    this.reviewedBy = '',
    this.reviewedAt,
    this.priority = 'medium',
  });

  // Create from Firestore document
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle location field - it might be a GeoPoint or String
    String locationString = '';
    final locationData = data['location'];
    if (locationData is GeoPoint) {
      // Convert GeoPoint to string representation
      locationString = '${locationData.latitude}°, ${locationData.longitude}°';
    } else if (locationData is String) {
      locationString = locationData;
    }

    // Handle tags field - it might be a String or List
    List<String> tagsList = [];
    final tagsData = data['tags'];
    if (tagsData is List) {
      tagsList = List<String>.from(tagsData);
    } else if (tagsData is String && tagsData.isNotEmpty) {
      // If tags is stored as comma-separated string, split it
      tagsList = tagsData
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    // Handle imageUrl field - ensure it's always a list
    List<String> imageList = [];
    final imageData = data['imageUrl'];
    if (imageData is List) {
      imageList = List<String>.from(imageData);
    } else if (imageData is String && imageData.isNotEmpty) {
      imageList = [imageData];
    }

    return ReportModel(
      id: doc.id,
      description: data['description'] ?? '',
      location: locationString,
      imageUrl: imageList,
      reportType: data['reportType'] ?? '',
      tags: tagsList,
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      reportedAt: data['reportedAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
      adminNotes: data['adminNotes'] ?? '',
      reviewedBy: data['reviewedBy'] ?? '',
      reviewedAt: data['reviewedAt'],
      priority: data['priority'] ?? 'medium',
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'location': location, // Store as string
      'imageUrl': imageUrl,
      'reportType': reportType,
      'tags': tags, // Store as array
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'reportedAt': reportedAt,
      'status': status,
      'adminNotes': adminNotes,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt,
      'priority': priority,
    };
  }

  // Create a copy with modified fields
  ReportModel copyWith({
    String? id,
    String? description,
    String? location,
    List<String>? imageUrl,
    String? reportType,
    List<String>? tags,
    String? userId,
    String? email,
    String? fullName,
    String? phoneNumber,
    Timestamp? reportedAt,
    String? status,
    String? adminNotes,
    String? reviewedBy,
    Timestamp? reviewedAt,
    String? priority,
  }) {
    return ReportModel(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      reportType: reportType ?? this.reportType,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      reportedAt: reportedAt ?? this.reportedAt,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      priority: priority ?? this.priority,
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isResolved => status == 'resolved';
  bool get isRejected => status == 'rejected';

  bool get hasAdminReview => reviewedBy.isNotEmpty;

  String get primaryImageUrl => imageUrl.isNotEmpty ? imageUrl.first : '';

  String get formattedReportedAt {
    final date = reportedAt.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, description: $description, status: $status, reportedAt: $reportedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum-like constants for better type safety
class ReportStatus {
  static const String pending = 'pending';
  static const String resolved = 'resolved';
  static const String rejected = 'rejected';

  static const List<String> all = [pending, resolved, rejected];
}

class ReportPriority {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String urgent = 'urgent';

  static const List<String> all = [low, medium, high, urgent];
}
