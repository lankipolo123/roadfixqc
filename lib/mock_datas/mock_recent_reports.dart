// lib/mock_datas/mock_recent_reports.dart

import 'package:roadfix/models/recent_report_model.dart';

final List<RecentReport> mockRecentReports = [
  const RecentReport(
    title: 'Pothole on Main St.',
    date: '2025-07-30',
    time: '14:30',
    status: ReportStatus.pending,
  ),
  const RecentReport(
    title: 'Broken Traffic Light',
    date: '2025-07-29',
    time: '10:00',
    status: ReportStatus.resolved,
  ),
  const RecentReport(
    title: 'Illegal Dumping',
    date: '2025-07-28',
    time: '09:15',
    status: ReportStatus.rejected,
  ),
];
