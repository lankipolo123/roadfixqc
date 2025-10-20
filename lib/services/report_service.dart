import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/services/firestore_service.dart';
import 'package:roadfix/services/imagekit_services.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final ImageKitService _imageKitService = ImageKitService();

  static const String _reportsCollection = 'reports';

  // SUBMIT REPORTS - WITH PROGRESS TRACKING + COORDINATES
  Future<String?> submitReport({
    required File imageFile,
    required String description,
    required String location,
    required double latitude, // NEW: Required GPS coordinate
    required double longitude, // NEW: Required GPS coordinate
    required String reportType,
    required List<String> detections,
    Function(double)? onProgress,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final userModel = await _firestoreService.getCurrentUser();
      if (userModel == null) throw Exception('User profile not found');

      onProgress?.call(0.0);

      // Upload image with progress tracking (0-90%)
      final imageUploadResponse = await _imageKitService.uploadReportImage(
        imageFile,
        onProgress: (uploadProgress) {
          onProgress?.call(uploadProgress * 0.9);
        },
      );

      onProgress?.call(0.9);

      // Create report WITH coordinates
      final report = ReportModel(
        description: description,
        location: location,
        latitude: latitude, // NEW: Save GPS coordinate
        longitude: longitude, // NEW: Save GPS coordinate
        imageUrl: [imageUploadResponse.fileUrl],
        reportType: reportType,
        tags: detections.isNotEmpty ? detections : [reportType],
        userId: currentUser.uid,
        email: userModel.email,
        fullName: userModel.fullName,
        phoneNumber: userModel.contactNumber,
        reportedAt: Timestamp.now(),
        status: ReportStatus.pending,
        priority: ReportPriority.medium,
      );

      final docRef = await _db
          .collection(_reportsCollection)
          .add(report.toMap());

      onProgress?.call(1.0);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  // GET REPORTS - Current User
  Future<List<ReportModel>> getCurrentUserReports() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user signed in');
    return getUserReports(currentUser.uid);
  }

  Stream<List<ReportModel>> getCurrentUserReportsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);
    return _db
        .collection(_reportsCollection)
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('reportedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReportModel.fromFirestore(doc))
              .toList(),
        );
  }

  // GET REPORTS - By User
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_reportsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('reportedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user reports: $e');
    }
  }

  Stream<List<ReportModel>> getUserReportsStream(String userId) {
    return _db
        .collection(_reportsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('reportedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReportModel.fromFirestore(doc))
              .toList(),
        );
  }

  // GET REPORTS - By Status
  Future<List<ReportModel>> getReportsByStatus(
    String userId,
    String status,
  ) async {
    try {
      final querySnapshot = await _db
          .collection(_reportsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('reportedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports by status: $e');
    }
  }

  // CALCULATE COUNTS DYNAMICALLY
  Future<Map<String, int>> getUserReportCounts() async {
    try {
      final reports = await getCurrentUserReports();

      return {
        'total': reports.length,
        'pending': reports
            .where((r) => r.status == ReportStatus.pending)
            .length,
        'approved': reports
            .where((r) => r.status == ReportStatus.approved)
            .length,
        'resolved': reports
            .where((r) => r.status == ReportStatus.resolved)
            .length,
        'rejected': reports
            .where((r) => r.status == ReportStatus.rejected)
            .length,
        'underReview': reports
            .where((r) => r.status == ReportStatus.underReview)
            .length,
        'inProgress': reports
            .where((r) => r.status == ReportStatus.inProgress)
            .length,
      };
    } catch (e) {
      throw Exception('Failed to calculate user report counts: $e');
    }
  }

  // CALCULATE COUNTS DYNAMICALLY (STREAM VERSION)
  Stream<Map<String, int>> getUserReportCountsStream() {
    return getCurrentUserReportsStream().map((reports) {
      return {
        'total': reports.length,
        'pending': reports
            .where((r) => r.status == ReportStatus.pending)
            .length,
        'approved': reports
            .where((r) => r.status == ReportStatus.approved)
            .length,
        'resolved': reports
            .where((r) => r.status == ReportStatus.resolved)
            .length,
        'rejected': reports
            .where((r) => r.status == ReportStatus.rejected)
            .length,
        'underReview': reports
            .where((r) => r.status == ReportStatus.underReview)
            .length,
        'inProgress': reports
            .where((r) => r.status == ReportStatus.inProgress)
            .length,
      };
    });
  }

  // GET APPROVED REPORTS
  Future<List<ReportModel>> getApprovedReports({int limit = 10}) async {
    try {
      final querySnapshot = await _db
          .collection(_reportsCollection)
          .where('status', isEqualTo: ReportStatus.approved)
          .orderBy('reportedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get approved reports: $e');
    }
  }

  Stream<List<ReportModel>> getApprovedReportsStream({int limit = 10}) {
    return _db
        .collection(_reportsCollection)
        .where('status', isEqualTo: ReportStatus.approved)
        .orderBy('reportedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReportModel.fromFirestore(doc))
              .toList(),
        );
  }

  // GET SINGLE REPORT
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      final doc = await _db.collection(_reportsCollection).doc(reportId).get();
      return doc.exists ? ReportModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  // UPDATE REPORT STATUS
  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
    String? adminNotes,
    String? reviewedBy,
  }) async {
    try {
      final reportUpdates = <String, dynamic>{
        'status': newStatus,
        'reviewedAt': Timestamp.now(),
      };
      if (adminNotes != null) reportUpdates['adminNotes'] = adminNotes;
      if (reviewedBy != null) reportUpdates['reviewedBy'] = reviewedBy;

      await _db
          .collection(_reportsCollection)
          .doc(reportId)
          .update(reportUpdates);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  // DELETE REPORT
  Future<void> deleteReport(String reportId) async {
    try {
      await _db.collection(_reportsCollection).doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // ADMIN FUNCTIONS
  Future<List<ReportModel>> getAllReports({
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      Query query = _db
          .collection(_reportsCollection)
          .orderBy('reportedAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _db
            .collection(_reportsCollection)
            .doc(lastDocumentId)
            .get();
        query = query.startAfterDocument(lastDoc);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all reports: $e');
    }
  }

  Future<Map<String, int>> getGlobalReportCounts() async {
    try {
      final reports = await getAllReports(limit: 1000);

      return {
        'total': reports.length,
        'pending': reports
            .where((r) => r.status == ReportStatus.pending)
            .length,
        'approved': reports
            .where((r) => r.status == ReportStatus.approved)
            .length,
        'resolved': reports
            .where((r) => r.status == ReportStatus.resolved)
            .length,
        'rejected': reports
            .where((r) => r.status == ReportStatus.rejected)
            .length,
        'underReview': reports
            .where((r) => r.status == ReportStatus.underReview)
            .length,
        'inProgress': reports
            .where((r) => r.status == ReportStatus.inProgress)
            .length,
      };
    } catch (e) {
      throw Exception('Failed to get global report counts: $e');
    }
  }
}
