// lib/services/report_service.dart (CLEAN REWRITE)
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

  // SUBMIT REPORTS
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

      // Save to Firestore and update counts
      String? docId;
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(currentUser.uid);
        final userSnapshot = await transaction.get(userRef);

        final reportRef = _db.collection(_reportsCollection).doc();
        transaction.set(reportRef, report.toMap());
        docId = reportRef.id;

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() ?? {};
          transaction.update(userRef, {
            'reportsCount': (userData['reportsCount'] ?? 0) + 1,
            'pendingCount': (userData['pendingCount'] ?? 0) + 1,
          });
        }
      });

      return docId;
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
    return getUserReportsStream(currentUser.uid);
  }

  // GET REPORTS - By User
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_reportsCollection)
          .where('userId', isEqualTo: userId)
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
          .get();

      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports by status: $e');
    }
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

  // UPDATE REPORT STATUS (Admin function)
  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
    String? adminNotes,
    String? reviewedBy,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final reportRef = _db.collection(_reportsCollection).doc(reportId);
        final reportSnapshot = await transaction.get(reportRef);

        if (!reportSnapshot.exists) {
          throw Exception('Report not found');
        }

        final reportData = reportSnapshot.data()!;
        final oldStatus = reportData['status'] as String;
        final userId = reportData['userId'] as String;

        final userRef = _db.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userRef);

        // Update report
        final reportUpdates = <String, dynamic>{
          'status': newStatus,
          'reviewedAt': Timestamp.now(),
        };
        if (adminNotes != null) reportUpdates['adminNotes'] = adminNotes;
        if (reviewedBy != null) reportUpdates['reviewedBy'] = reviewedBy;

        transaction.update(reportRef, reportUpdates);

        // Update user counts if status changed
        if (oldStatus != newStatus && userSnapshot.exists) {
          final userData = userSnapshot.data() ?? {};
          final counts = _calculateNewCounts(userData, oldStatus, newStatus);
          transaction.update(userRef, counts);
        }
      });
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  // DELETE REPORT
  Future<void> deleteReport(String reportId) async {
    try {
      await _db.runTransaction((transaction) async {
        final reportRef = _db.collection(_reportsCollection).doc(reportId);
        final reportSnapshot = await transaction.get(reportRef);

        if (!reportSnapshot.exists) {
          throw Exception('Report not found');
        }

        final reportData = reportSnapshot.data()!;
        final status = reportData['status'] as String;
        final userId = reportData['userId'] as String;

        final userRef = _db.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userRef);

        transaction.delete(reportRef);

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() ?? {};
          final counts = _calculateDeleteCounts(userData, status);
          transaction.update(userRef, counts);
        }
      });
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

  // PRIVATE HELPER METHODS
  Map<String, int> _calculateNewCounts(
    Map<String, dynamic> userData,
    String oldStatus,
    String newStatus,
  ) {
    int pendingCount = userData['pendingCount'] ?? 0;
    int approvedCount = userData['approvedCount'] ?? 0;
    int resolvedCount = userData['resolvedCount'] ?? 0;
    int rejectedCount = userData['rejectedCount'] ?? 0;

    // Decrement old status
    switch (oldStatus) {
      case 'pending':
        pendingCount = (pendingCount > 0) ? pendingCount - 1 : 0;
        break;
      case 'approved':
        approvedCount = (approvedCount > 0) ? approvedCount - 1 : 0;
        break;
      case 'resolved':
        resolvedCount = (resolvedCount > 0) ? resolvedCount - 1 : 0;
        break;
      case 'rejected':
        rejectedCount = (rejectedCount > 0) ? rejectedCount - 1 : 0;
        break;
    }

    // Increment new status
    switch (newStatus) {
      case 'pending':
        pendingCount++;
        break;
      case 'approved':
        approvedCount++;
        break;
      case 'resolved':
        resolvedCount++;
        break;
      case 'rejected':
        rejectedCount++;
        break;
    }

    return {
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
      'resolvedCount': resolvedCount,
      'rejectedCount': rejectedCount,
    };
  }

  Map<String, int> _calculateDeleteCounts(
    Map<String, dynamic> userData,
    String status,
  ) {
    int reportsCount = userData['reportsCount'] ?? 0;
    int pendingCount = userData['pendingCount'] ?? 0;
    int approvedCount = userData['approvedCount'] ?? 0;
    int resolvedCount = userData['resolvedCount'] ?? 0;
    int rejectedCount = userData['rejectedCount'] ?? 0;

    reportsCount = (reportsCount > 0) ? reportsCount - 1 : 0;

    switch (status) {
      case 'pending':
        pendingCount = (pendingCount > 0) ? pendingCount - 1 : 0;
        break;
      case 'approved':
        approvedCount = (approvedCount > 0) ? approvedCount - 1 : 0;
        break;
      case 'resolved':
        resolvedCount = (resolvedCount > 0) ? resolvedCount - 1 : 0;
        break;
      case 'rejected':
        rejectedCount = (rejectedCount > 0) ? rejectedCount - 1 : 0;
        break;
    }

    return {
      'reportsCount': reportsCount,
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
      'resolvedCount': resolvedCount,
      'rejectedCount': rejectedCount,
    };
  }
}
