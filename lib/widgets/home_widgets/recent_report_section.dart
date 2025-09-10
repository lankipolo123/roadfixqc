import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/services/report_service.dart';
import 'package:roadfix/models/report_model.dart';

class RecentReportsSection extends StatelessWidget {
  const RecentReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title stays fixed at top-left
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 18, // a bit bigger for emphasis
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Reports / empty state
        SizedBox(
          height: 200, // give space for centering
          child: StreamBuilder<List<ReportModel>>(
            stream: ReportService().getApprovedReportsStream(limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 2,
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'No recent reports at the moment',
                    style: TextStyle(fontSize: 14, color: altSecondary),
                  ),
                );
              }

              final approvedReports = snapshot.data ?? [];
              final oneWeekAgo = DateTime.now().subtract(
                const Duration(days: 7),
              );
              final recentReports = approvedReports.where((report) {
                final reportDate = report.reportedAt.toDate();
                return reportDate.isAfter(oneWeekAgo);
              }).toList();

              if (recentReports.isEmpty) {
                return const Center(
                  child: Text(
                    'No recent reports at the moment',
                    style: TextStyle(fontSize: 14, color: altSecondary),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: recentReports
                    .map((report) => _buildReportItem(report))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(ReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusSuccess.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: statusSuccess,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Report info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.description.length > 50
                      ? '${report.description.substring(0, 50)}...'
                      : report.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.location} • ${report.formattedReportedAt}',
                  style: TextStyle(
                    fontSize: 12,
                    color: primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusSuccess.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              report.reportType,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusSuccess,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
