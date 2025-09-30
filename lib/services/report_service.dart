// lib/services/report_service.dart (DYNAMIC COUNTING VERSION)
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

  // SUBMIT REPORTS - SIMPLIFIED (NO COUNT UPDATES)
  Future<String?> submitReport({
    required File imageFile,
    required String description,
    required String location,
    required String reportType,
    required List<String> detections,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final userModel = await _firestoreService.getCurrentUser();
      if (userModel == null) throw Exception('User profile not found');

      // Upload image to ImageKit
      final imageUploadResponse = await _imageKitService.uploadReportImage(
        imageFile,
      );

      // Create report
      final report = ReportModel(
        description: description,
        location: location,
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

      // Simply add report to collection - NO COUNT UPDATES
      final docRef = await _db
          .collection(_reportsCollection)
          .add(report.toMap());
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
      };
    });
  }

  // GET APPROVED REPORTS (for Recent Reports section)
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

  // UPDATE REPORT STATUS - SIMPLIFIED (NO COUNT UPDATES)
  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
    String? adminNotes,
    String? reviewedBy,
  }) async {
    try {
      // Simply update report status - NO COUNT UPDATES
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

  // DELETE REPORT - SIMPLIFIED (NO COUNT UPDATES)
  Future<void> deleteReport(String reportId) async {
    try {
      // Simply delete the report - NO COUNT UPDATES
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
      };
    } catch (e) {
      throw Exception('Failed to get global report counts: $e');
    }
  }
}
