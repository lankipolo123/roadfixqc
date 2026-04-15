// lib/screens/secondary_screens/public_report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/services/language_service.dart';
import 'package:roadfix/widgets/reporting_widgets/image_gallery_widget.dart';
import 'package:roadfix/widgets/themes.dart';

class PublicReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const PublicReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService(),
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final lang = LanguageService();
    return Scaffold(
      backgroundColor: inputFill,
      appBar: AppBar(
        title: Text(lang.reportDetails),
        backgroundColor: primary,
        foregroundColor: inputFill,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BEFORE — original report images
            if (report.imageUrl.isNotEmpty) ...[
              ImageGalleryWidget(
                images: report.imageUrl,
                label: lang.t('BEFORE - REPORTED ISSUE', 'BAGO - INIULAT NA ISYU'),
                labelColor: altSecondary,
              ),
              SizedBox(height: 16.h),
            ],

            // AFTER — admin resolved images
            if (report.hasResolvedImage) ...[
              ImageGalleryWidget(
                images: report.resolvedImages,
                label: lang.t('AFTER - RESOLVED', 'PAGKATAPOS - NAAYOS NA'),
                labelColor: statusSuccess,
              ),
              SizedBox(height: 16.h),
            ],

            // Compact Info Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.typeLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        report.reportType,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (report.tags.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.tagsLabel,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          report.tags.join(', '),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16.w),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    report.location,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Description
            Text(
              report.description,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),

            // Timeline Graph
            _buildTimelineGraph(lang),
            SizedBox(height: 16.h),

            // Admin Notes
            if (ReportStatusUtils.hasAdminNotes(report.adminNotes)) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.adminNotesLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      ReportStatusUtils.formatAdminNotes(
                        report.adminNotes,
                        null,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue[800],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineGraph(LanguageService lang) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.timeline,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTimelineMilestone(
                  lang.reported,
                  report.formattedReportedAt,
                  Colors.blue,
                  true,
                ),
              ),
              Container(
                height: 2,
                width: 40.w,
                color: report.reviewedAt != null
                    ? ReportStatusUtils.getStatusColor(report.status)
                    : Colors.grey[300],
              ),
              Expanded(
                child: _buildTimelineMilestone(
                  ReportStatusUtils.getDetailedStatusText(report.status),
                  report.reviewedAt != null
                      ? _formatDateTime(report.reviewedAt!.toDate())
                      : lang.pendingLabel,
                  ReportStatusUtils.getStatusColor(report.status),
                  report.reviewedAt != null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineMilestone(
    String title,
    String date,
    Color color,
    bool isCompleted,
  ) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey[300],
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? color : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isCompleted ? color : Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          date,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
