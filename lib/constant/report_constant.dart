// lib/constants/report_constants.dart
class ReportConstants {
  // Empty state messages
  static const String emptyAllReports =
      'No reports found\nStart by submitting your first road issue report';
  static const String emptyPendingReports =
      'No pending reports\nAll your reports have been reviewed!';
  static const String emptyApprovedReports =
      'No approved reports yet\nWait for admin to approve your submissions';
  static const String emptyResolvedReports =
      'No resolved reports yet\nApproved reports will be resolved after fixes';
  static const String emptyRejectedReports =
      'No rejected reports\nGreat job on your submissions!';

  // Filter tab labels
  static const List<String> filterLabels = [
    'All',
    'Pending',
    'Approved',
    'Resolved',
    'Rejected',
  ];

  // Status values (if you want to centralize these too)
  static const String statusPending = 'pending';
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
