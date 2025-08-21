// lib/widgets/home_widgets/recent_report_item.dart

import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/models/recent_report_model.dart';

class RecentReportItem extends StatelessWidget {
  final RecentReport report;

  const RecentReportItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    switch (report.status) {
      case ReportStatus.pending:
        statusColor = statusWarning;
        break;
      case ReportStatus.resolved:
        statusColor = statusSuccess;
        break;
      case ReportStatus.rejected:
        statusColor = statusDanger;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: secondary),
                    const SizedBox(width: 4),
                    Text(
                      report.date,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: altSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 14, color: altSecondary),
                    const SizedBox(width: 4),
                    Text(
                      report.time,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: altSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right side status icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
