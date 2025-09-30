// lib/services/notification_service.dart (IMPROVED with DELETE)
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _viewedKey = 'viewed_notifications';
  static const String _deletedKey =
      'deleted_notifications'; // New key for deleted notifications

  // Stream controller for viewed notification IDs
  final BehaviorSubject<Set<String>> _viewedIdsController =
      BehaviorSubject<Set<String>>();

  // Stream controller for deleted notification IDs
  final BehaviorSubject<Set<String>> _deletedIdsController =
      BehaviorSubject<Set<String>>();

  // Initialize viewed IDs on first access
  bool _initialized = false;

  // Get all recently updated reports (filtered by deleted status)
  Stream<List<ReportModel>> getRecentlyUpdatedReportsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return Rx.combineLatest2<QuerySnapshot, Set<String>, List<ReportModel>>(
      _firestore
          .collection('reports')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      getDeletedNotificationIdsStream(),
      (snapshot, deletedIds) {
        final reports = snapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList();

        final reviewedReports = reports
            .where(
              (report) =>
                  report.reviewedAt != null && !deletedIds.contains(report.id),
            ) // Filter out deleted notifications
            .toList();

        // Sort by most recent first
        reviewedReports.sort((a, b) => b.reviewedAt!.compareTo(a.reviewedAt!));
        return reviewedReports;
      },
    );
  }

  // Get viewed notification IDs stream
  Stream<Set<String>> getViewedNotificationIdsStream() async* {
    await _initializeIfNeeded();
    yield* _viewedIdsController.stream;
  }

  // Get deleted notification IDs stream
  Stream<Set<String>> getDeletedNotificationIdsStream() async* {
    await _initializeIfNeeded();
    yield* _deletedIdsController.stream;
  }

  // Initialize viewed and deleted IDs from SharedPreferences
  Future<void> _initializeIfNeeded() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Initialize viewed IDs
    final viewedIds = prefs.getStringList(_viewedKey) ?? [];
    _viewedIdsController.add(viewedIds.toSet());

    // Initialize deleted IDs
    final deletedIds = prefs.getStringList(_deletedKey) ?? [];
    _deletedIdsController.add(deletedIds.toSet());

    _initialized = true;
  }

  // Mark notification as viewed and immediately update stream
  Future<void> markAsViewed(String reportId) async {
    await _initializeIfNeeded();

    final prefs = await SharedPreferences.getInstance();
    final currentViewedIds = _viewedIdsController.valueOrNull ?? <String>{};

    if (!currentViewedIds.contains(reportId)) {
      final updatedViewedIds = {...currentViewedIds, reportId};

      // Update SharedPreferences
      await prefs.setStringList(_viewedKey, updatedViewedIds.toList());

      // Immediately emit the updated viewed IDs
      _viewedIdsController.add(updatedViewedIds);
    }
  }

  // Delete notification (mark as deleted)
  Future<void> deleteNotification(String reportId) async {
    await _initializeIfNeeded();

    final prefs = await SharedPreferences.getInstance();
    final currentDeletedIds = _deletedIdsController.valueOrNull ?? <String>{};

    if (!currentDeletedIds.contains(reportId)) {
      final updatedDeletedIds = {...currentDeletedIds, reportId};

      // Update SharedPreferences
      await prefs.setStringList(_deletedKey, updatedDeletedIds.toList());

      // Immediately emit the updated deleted IDs
      _deletedIdsController.add(updatedDeletedIds);
    }
  }

  // Restore notification (remove from deleted)
  Future<void> restoreNotification(String reportId) async {
    await _initializeIfNeeded();

    final prefs = await SharedPreferences.getInstance();
    final currentDeletedIds = _deletedIdsController.valueOrNull ?? <String>{};

    if (currentDeletedIds.contains(reportId)) {
      final updatedDeletedIds = Set<String>.from(currentDeletedIds);
      updatedDeletedIds.remove(reportId);

      // Update SharedPreferences
      await prefs.setStringList(_deletedKey, updatedDeletedIds.toList());

      // Immediately emit the updated deleted IDs
      _deletedIdsController.add(updatedDeletedIds);
    }
  }

  // Get unread notification count stream - IMPROVED VERSION
  Stream<int> getUnreadNotificationCountStream() {
    // Combine reports stream with viewed IDs stream
    return Rx.combineLatest2<List<ReportModel>, Set<String>, int>(
      getRecentlyUpdatedReportsStream(),
      getViewedNotificationIdsStream(),
      (reports, viewedIds) {
        // Calculate unread count (already filtered by deleted in getRecentlyUpdatedReportsStream)
        final unreadCount = reports
            .where((report) => !viewedIds.contains(report.id))
            .length;
        return unreadCount;
      },
    ).distinct(); // Only emit when the count actually changes
  }

  String getStatusDisplayText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      case 'in_review':
        return 'In Review';
      default:
        return 'Pending';
    }
  }

  String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _viewedIdsController.close();
    _deletedIdsController.close();
  }
}
