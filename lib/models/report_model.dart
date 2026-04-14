import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id;
  final String description;
  final String location;
  final double? latitude; // NEW: GPS coordinate
  final double? longitude; // NEW: GPS coordinate
  final List<String> imageUrl;
  final String reportType;
  final List<String> tags;
  final String userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final Timestamp reportedAt;
  final String status;
  final String adminNotes;
  final String reviewedBy;
  final Timestamp? reviewedAt;
  final String priority;
  final bool isRead;

  // Resolved image fields
  final String? resolvedImageUrl;           // legacy single-image field (kept for backwards compat)
  final List<String> resolvedImages;        // multi-image list uploaded by admin
  final String? completionNotes;
  final Timestamp? completionImageUploadedAt;

  const ReportModel({
    this.id,
    required this.description,
    required this.location,
    this.latitude, // NEW
    this.longitude, // NEW
    required this.imageUrl,
    required this.reportType,
    required this.tags,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.reportedAt,
    this.status = ReportStatus.pending,
    this.adminNotes = '',
    this.reviewedBy = '',
    this.reviewedAt,
    this.priority = ReportPriority.medium,
    this.isRead = false,
    this.resolvedImageUrl,
    this.resolvedImages = const [],
    this.completionNotes,
    this.completionImageUploadedAt,
  });

  /// Parses resolved images from Firestore, supporting both:
  /// - New format: `resolvedImages` (List<String>)
  /// - Legacy format: `resolvedImageUrl` (String) — wrapped into a list
  static List<String> _parseResolvedImages(Map<String, dynamic> data) {
    final newField = data['resolvedImages'];
    if (newField is List && newField.isNotEmpty) {
      return List<String>.from(newField);
    }
    final legacy = data['resolvedImageUrl'];
    if (legacy is String && legacy.isNotEmpty) {
      return [legacy];
    }
    return [];
  }

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String locationString = '';
    final locationData = data['location'];
    if (locationData is GeoPoint) {
      locationString = '${locationData.latitude}°, ${locationData.longitude}°';
    } else if (locationData is String) {
      locationString = locationData;
    }

    List<String> tagsList = [];
    final tagsData = data['tags'];
    if (tagsData is List) {
      tagsList = List<String>.from(tagsData);
    } else if (tagsData is String && tagsData.isNotEmpty) {
      tagsList = tagsData
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

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
      latitude: data['latitude']?.toDouble(), // NEW
      longitude: data['longitude']?.toDouble(), // NEW
      imageUrl: imageList,
      reportType: data['reportType'] ?? '',
      tags: tagsList,
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      reportedAt: data['reportedAt'] ?? Timestamp.now(),
      status: data['status'] ?? ReportStatus.pending,
      adminNotes: data['adminNotes'] ?? '',
      reviewedBy: data['reviewedBy'] ?? '',
      reviewedAt: data['reviewedAt'],
      priority: data['priority'] ?? ReportPriority.medium,
      isRead: data['isRead'] ?? false,
      resolvedImageUrl: data['resolvedImageUrl'],
      resolvedImages: _parseResolvedImages(data),
      completionNotes: data['completionNotes'],
      completionImageUploadedAt: data['completionImageUploadedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'location': location,
      'latitude': latitude, // NEW
      'longitude': longitude, // NEW
      'imageUrl': imageUrl,
      'reportType': reportType,
      'tags': tags,
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
      'isRead': isRead,
      'resolvedImageUrl': resolvedImageUrl,
      'resolvedImages': resolvedImages,
      'completionNotes': completionNotes,
      'completionImageUploadedAt': completionImageUploadedAt,
    };
  }

  ReportModel copyWith({
    String? id,
    String? description,
    String? location,
    double? latitude, // NEW
    double? longitude, // NEW
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
    bool? isRead,
    String? resolvedImageUrl,
    List<String>? resolvedImages,
    String? completionNotes,
    Timestamp? completionImageUploadedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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
      isRead: isRead ?? this.isRead,
      resolvedImageUrl: resolvedImageUrl ?? this.resolvedImageUrl,
      resolvedImages: resolvedImages ?? this.resolvedImages,
      completionNotes: completionNotes ?? this.completionNotes,
      completionImageUploadedAt:
          completionImageUploadedAt ?? this.completionImageUploadedAt,
    );
  }

  bool get isPending => status == ReportStatus.pending;
  bool get isAccepted => status == ReportStatus.accepted;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isInvalid => status == ReportStatus.invalid;
  bool get isInProgress => status == ReportStatus.inProgress;
  bool get hasAdminReview => reviewedBy.isNotEmpty;
  bool get isUnreadNotification => !isRead && reviewedAt != null;
  bool get hasResolvedImage => resolvedImages.isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null; // NEW

  String get primaryImageUrl => imageUrl.isNotEmpty ? imageUrl.first : '';

  String get formattedReportedAt {
    final date = reportedAt.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() =>
      'ReportModel(id: $id, description: $description, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReportModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class ReportStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String accepted = 'accepted';
  static const String resolved = 'resolved';
  static const String invalid = 'invalid';

  static const List<String> all = [
    pending,
    inProgress,
    accepted,
    resolved,
    invalid,
  ];
}

class ReportPriority {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String urgent = 'urgent';

  static const List<String> all = [low, medium, high, urgent];
}
