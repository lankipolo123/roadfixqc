// lib/models/recent_report_model.dart

enum ReportStatus { pending, resolved, rejected }

class RecentReport {
  final String title;
  final String date;
  final String time;
  final ReportStatus status;

  const RecentReport({
    required this.title,
    required this.date,
    required this.time,
    required this.status,
  });
}
