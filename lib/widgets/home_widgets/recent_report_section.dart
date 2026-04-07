import 'package:flutter/material.dart';
import 'package:roadfix/screens/secondary_screens/public_report_detail.dart';
import 'package:roadfix/utils/responsive.dart';
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Reports - no fixed height
        StreamBuilder<List<ReportModel>>(
          stream: ReportService().getAcceptedReportsStream(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 100.h,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 100.h,
                child: Center(
                  child: Text(
                    'No recent reports at the moment',
                    style: TextStyle(fontSize: 14.sp, color: altSecondary),
                  ),
                ),
              );
            }

            final recentReports = snapshot.data ?? [];

            if (recentReports.isEmpty) {
              return SizedBox(
                height: 100.h,
                child: Center(
                  child: Text(
                    'No recent reports at the moment',
                    style: TextStyle(fontSize: 14.sp, color: altSecondary),
                  ),
                ),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
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
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(8.r),
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
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: statusSuccess,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),

            // Report info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.description.length > 50
                        ? '${report.description.substring(0, 50)}...'
                        : report.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${report.location} • ${report.formattedReportedAt}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: altSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                  // Add reporter name
                  SizedBox(height: 2.h),
                ],
              ),
            ),

            // Type badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusSuccess.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                report.reportType,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: statusSuccess,
                ),
              ),
            ),

            // Arrow indicator
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: altSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
