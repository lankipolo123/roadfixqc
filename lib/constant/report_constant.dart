// lib/constant/report_constant.dart
class ReportConstants {
  // Empty state messages
  static const String emptyAllReports =
      'No reports found\nStart by submitting your first road issue report';
  static const String emptyPendingReports =
      'No pending reports\nAll your reports have been reviewed!';
  static const String emptyUnderReviewReports =
      'No reports under review\nYour reports will appear here once being reviewed.';
  static const String emptyInProgressReports =
      'No reports in progress\nApproved reports that are being fixed will show here.';
  static const String emptyApprovedReports =
      'No approved reports yet\nWait for admin to approve your submissions';
  static const String emptyResolvedReports =
      'No resolved reports yet\nApproved reports will be resolved after fixes';
  static const String emptyRejectedReports =
      'No rejected reports\nGreat job on your submissions!';

  // Filter tab labels - UPDATED WITH SHORTER LABELS
  static const List<String> filterLabels = [
    'All', // 0
    'Pending', // 1
    'Review', // 2 (was "Under Review")
    'Progress', // 3 (was "In Progress")
    'Approved', // 4
    'Resolved', // 5
    'Rejected', // 6
  ];

  // Status values (centralized)
  static const String statusPending = 'pending';
  static const String statusUnderReview = 'under_review';
  static const String statusInProgress = 'in_progress';
  static const String statusApproved = 'approved';
  static const String statusResolved = 'resolved';
  static const String statusRejected = 'rejected';

  // UI Messages
  static const String loadingReports = 'Loading your reports...';
  static const String errorLoadingReports = 'Error loading reports:';
  static const String retryButton = 'Retry';
  static const String submitFirstReport = 'Submit Your First Report';
  static const String myReportsTitle = 'My Reports';
}
