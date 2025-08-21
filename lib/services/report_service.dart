import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/services/firestore_service.dart';
import 'package:roadfix/services/imagekit_services.dart';
import 'dart:io';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final ImageKitService _imageKitService = ImageKitService();

  static const String _reportsCollection = 'reports';

  // Submit a new report (complete flow: upload image + save to Firestore + update user counts)
  Future<String?> submitReport({
    required File imageFile,
    required String description,
    required String location,
    required String reportType,
    required List<String> detections,
  }) async {
    try {
      // 1. Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user signed in');
      }

      final userModel = await _firestoreService.getCurrentUser();
      if (userModel == null) {
        throw Exception('User profile not found');
      }

      // 2. Upload image to ImageKit
      final imageUploadResponse = await _imageKitService.uploadReportImage(
        imageFile,
        reportId: null, // Will be generated after Firestore doc creation
      );

      // 3. Prepare tags - use detections if available, otherwise use reportType
      List<String> reportTags = [];
      if (detections.isNotEmpty) {
        reportTags = detections;
      } else if (reportType.isNotEmpty) {
        reportTags = [reportType];
      }

      // 4. Create report model
      final report = ReportModel(
        description: description,
        location: location,
        imageUrl: [imageUploadResponse.fileUrl],
        reportType: reportType,
        tags: reportTags, // Now properly populated
        userId: currentUser.uid,
        email: userModel.email,
        fullName: userModel.fullName,
        phoneNumber: userModel.contactNumber,
        reportedAt: Timestamp.now(),
        status: ReportStatus.pending,
        priority: ReportPriority.medium,
      );

      // 5. Save to Firestore and update user counts in a transaction
      String? docId;
      await _db.runTransaction((transaction) async {
        // ✅ FIRST: Do ALL reads
        final userRef = _db.collection('users').doc(currentUser.uid);
        final userSnapshot = await transaction.get(userRef);

        // ✅ THEN: Do ALL writes
        // Add report
        final reportRef = _db.collection(_reportsCollection).doc();
        transaction.set(reportRef, report.toMap());
        docId = reportRef.id;

        // Update user report counts
        if (userSnapshot.exists) {
          final currentReports = userSnapshot.data()?['reportsCount'] ?? 0;
          final currentPending = userSnapshot.data()?['pendingCount'] ?? 0;

          transaction.update(userRef, {
            'reportsCount': currentReports + 1,
            'pendingCount': currentPending + 1,
          });
        }
      });

      return docId;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  // Get all reports for a specific user
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

  // Get real-time stream of user reports
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

  // Get current user's reports
  Future<List<ReportModel>> getCurrentUserReports() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user signed in');
    }
    return getUserReports(currentUser.uid);
  }

  // Get current user's reports stream
  Stream<List<ReportModel>> getCurrentUserReportsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return getUserReportsStream(currentUser.uid);
  }

  // Get reports by status
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

  // Get a single report by ID
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      final doc = await _db.collection(_reportsCollection).doc(reportId).get();

      if (doc.exists) {
        return ReportModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  // Update report status (for admin use) + update user counts
  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
    String? adminNotes,
    String? reviewedBy,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        // ✅ FIRST: Do ALL reads
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

        // ✅ THEN: Do ALL writes
        // Update report
        final updates = <String, dynamic>{
          'status': newStatus,
          'reviewedAt': Timestamp.now(),
        };

        if (adminNotes != null) updates['adminNotes'] = adminNotes;
        if (reviewedBy != null) updates['reviewedBy'] = reviewedBy;

        transaction.update(reportRef, updates);

        // Update user counts if status changed
        if (oldStatus != newStatus && userSnapshot.exists) {
          final userData = userSnapshot.data() ?? {};
          int pendingCount = userData['pendingCount'] ?? 0;
          int resolvedCount = userData['resolvedCount'] ?? 0;
          int rejectedCount = userData['rejectedCount'] ?? 0;

          // Decrement old status count
          switch (oldStatus) {
            case 'pending':
              pendingCount = (pendingCount > 0) ? pendingCount - 1 : 0;
              break;
            case 'resolved':
              resolvedCount = (resolvedCount > 0) ? resolvedCount - 1 : 0;
              break;
            case 'rejected':
              rejectedCount = (rejectedCount > 0) ? rejectedCount - 1 : 0;
              break;
          }

          // Increment new status count
          switch (newStatus) {
            case 'pending':
              pendingCount++;
              break;
            case 'resolved':
              resolvedCount++;
              break;
            case 'rejected':
              rejectedCount++;
              break;
          }

          transaction.update(userRef, {
            'pendingCount': pendingCount,
            'resolvedCount': resolvedCount,
            'rejectedCount': rejectedCount,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  // Delete a report (also updates user counts)
  Future<void> deleteReport(String reportId) async {
    try {
      await _db.runTransaction((transaction) async {
        // ✅ FIRST: Do ALL reads
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

        // ✅ THEN: Do ALL writes
        // Delete report
        transaction.delete(reportRef);

        // Update user counts
        if (userSnapshot.exists) {
          final userData = userSnapshot.data() ?? {};
          int reportsCount = userData['reportsCount'] ?? 0;
          int pendingCount = userData['pendingCount'] ?? 0;
          int resolvedCount = userData['resolvedCount'] ?? 0;
          int rejectedCount = userData['rejectedCount'] ?? 0;

          // Decrement total count
          reportsCount = (reportsCount > 0) ? reportsCount - 1 : 0;

          // Decrement status count
          switch (status) {
            case 'pending':
              pendingCount = (pendingCount > 0) ? pendingCount - 1 : 0;
              break;
            case 'resolved':
              resolvedCount = (resolvedCount > 0) ? resolvedCount - 1 : 0;
              break;
            case 'rejected':
              rejectedCount = (rejectedCount > 0) ? rejectedCount - 1 : 0;
              break;
          }

          transaction.update(userRef, {
            'reportsCount': reportsCount,
            'pendingCount': pendingCount,
            'resolvedCount': resolvedCount,
            'rejectedCount': rejectedCount,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Get all reports (for admin dashboard later)
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

  // Get reports count by status (for admin dashboard)
  Future<Map<String, int>> getGlobalReportCounts() async {
    try {
      // Note: This could be expensive with large datasets
      // Consider using Cloud Functions to maintain counts
      final reports = await getAllReports(limit: 1000);

      return {
        'total': reports.length,
        'pending': reports
            .where((r) => r.status == ReportStatus.pending)
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
