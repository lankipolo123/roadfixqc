import 'package:flutter/material.dart';
import 'package:roadfix/screens/secondary_screens/public_report_detail.dart';
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Reports - no fixed height
        StreamBuilder<List<ReportModel>>(
          stream: ReportService().getApprovedReportsStream(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No recent reports at the moment',
                    style: TextStyle(fontSize: 14, color: altSecondary),
                  ),
                ),
              );
            }

            final approvedReports = snapshot.data ?? [];
            final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

            // Filter by reviewedAt (approval date) instead of reportedAt
            final recentReports = approvedReports.where((report) {
              final approvalDate = report.reviewedAt != null
                  ? report.reviewedAt!.toDate()
                  : report.reportedAt.toDate();
              return approvalDate.isAfter(oneWeekAgo);
            }).toList();

            if (recentReports.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No recent reports at the moment',
                    style: TextStyle(fontSize: 14, color: altSecondary),
                  ),
                ),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: recentReports
                  .map((report) => _buildReportItem(context, report))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReportItem(BuildContext context, ReportModel report) {
    return GestureDetector(
      onTap: () {
        // Navigate to public report detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicReportDetailScreen(report: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.3),
          ),
          // Add subtle hover effect
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                      color: secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.location} • ${report.formattedReportedAt}',
                    style: TextStyle(
                      fontSize: 12,
                      color: altSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                  // Add reporter name
                  const SizedBox(height: 2),
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

            // Arrow indicator
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: altSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
