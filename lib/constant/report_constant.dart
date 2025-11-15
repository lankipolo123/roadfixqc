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
      'No reports in progress\nAccepted reports that are being fixed will show here.';
  static const String emptyAcceptedReports =
      'No accepted reports yet\nWait for admin to accept your submissions';
  static const String emptyResolvedReports =
      'No resolved reports yet\nAccepted reports will be resolved after fixes';
  static const String emptyInvalidReports =
      'No invalid reports\nGreat job on your submissions!';

  // Filter tab labels - SYNCED WITH user_report_screen.dart filtering
  static const List<String> filterLabels = [
    'All', // 0
    'Pending', // 1
    'Accepted', // 2
    'Invalid', // 3
    'Progress', // 4 (In Progress)
    'Resolved', // 5
  ];

  // Status values (centralized)
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusAccepted = 'accepted';
  static const String statusResolved = 'resolved';
  static const String statusInvalid = 'invalid';

  // UI Messages
  static const String loadingReports = 'Loading your reports...';
  static const String errorLoadingReports = 'Error loading reports:';
  static const String retryButton = 'Retry';
  static const String submitFirstReport = 'Submit Your First Report';
  static const String myReportsTitle = 'My Reports';
}
