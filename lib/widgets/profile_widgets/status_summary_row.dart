// lib/widgets/profile_widgets/status_summary_row.dart (DYNAMIC VERSION)
import 'package:flutter/material.dart';
import 'package:roadfix/services/report_service.dart';
import 'package:roadfix/widgets/themes.dart';

class StatusSummaryRow extends StatelessWidget {
  const StatusSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportService reportService = ReportService();

    return StreamBuilder<Map<String, int>>(
      stream: reportService.getUserReportCountsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              _statusBox('Reports', 0, statusDanger),
              _statusBox('Pending', 0, statusWarning),
              _statusBox('Approved', 0, statusSuccess),
              _statusBox('Resolved', 0, primary),
            ],
          );
        }

        if (snapshot.hasError) {
          return Row(
            children: [
              _statusBox('Reports', 0, statusDanger),
              _statusBox('Pending', 0, statusWarning),
              _statusBox('Approved', 0, statusSuccess),
              _statusBox('Resolved', 0, primary),
            ],
          );
        }

        final counts =
            snapshot.data ??
            {'total': 0, 'pending': 0, 'approved': 0, 'resolved': 0};

        return Row(
          children: [
            _statusBox('Reports', counts['total']!, statusDanger),
            _statusBox('Pending', counts['pending']!, statusWarning),
            _statusBox('Approved', counts['approved']!, statusSuccess),
            _statusBox('Resolved', counts['resolved']!, primary),
          ],
        );
      },
    );
  }

  Widget _statusBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
