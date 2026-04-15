import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/layouts/diagonal_background.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/services/language_service.dart';
import 'package:roadfix/widgets/reporting_widgets/detection_tags.dart';
import 'package:roadfix/widgets/reporting_widgets/image_gallery_widget.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService(),
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final lang = LanguageService();
    final statusColor = ReportStatusUtils.getStatusColor(report.status);

    return DiagonalBackgroundLayout(
      child: Scaffold(
        backgroundColor: transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      color: inputFill,
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              lang.reportDetails,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: secondary,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // BEFORE — original report images (gallery)
                            if (report.imageUrl.isNotEmpty) ...[
                              ImageGalleryWidget(
                                images: report.imageUrl,
                                label: lang.t(
                                  'BEFORE - REPORTED ISSUE',
                                  'BAGO - INIULAT NA ISYU',
                                ),
                                labelColor: altSecondary,
                              ),
                              SizedBox(height: 20.h),
                            ],

                            // AFTER — admin resolved images (gallery)
                            if (report.hasResolvedImage) ...[
                              ImageGalleryWidget(
                                images: report.resolvedImages,
                                label: lang.t(
                                  'AFTER - RESOLVED',
                                  'PAGKATAPOS - NAAYOS NA',
                                ),
                                labelColor: statusSuccess,
                              ),
                              SizedBox(height: 20.h),
                            ],

                            // Status badge
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  border: Border.all(color: statusColor),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      ReportStatusUtils.getStatusIcon(
                                        report.status,
                                      ),
                                      color: statusColor,
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      ReportStatusUtils.getDetailedStatusText(
                                        report.status,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Status statement banner
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16.w,
                                    color: statusColor.withValues(alpha: 0.8),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      lang.statusStatement(report.status),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: secondary.withValues(alpha: 0.8),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // Detection Tags
                            if (report.tags.isNotEmpty) ...[
                              DetectionTags(detections: report.tags),
                            ],

                            _info(Icons.category, lang.typeLabel,
                                report.reportType),
                            _info(Icons.location_on, lang.locationLabel,
                                report.location),
                            _info(Icons.description, lang.descriptionLabel,
                                report.description),
                            _info(
                              Icons.schedule,
                              lang.submittedLabel,
                              DateFormat('MMM dd, yyyy - hh:mm a')
                                  .format(report.reportedAt.toDate()),
                            ),

                            // Completion Notes
                            if (report.completionNotes != null &&
                                report.completionNotes!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(height: 30.h, color: altSecondary),
                                  Row(
                                    children: [
                                      Icon(Icons.task_alt,
                                          color: statusSuccess, size: 16.w),
                                      SizedBox(width: 8.w),
                                      Text(
                                        lang.completionNotesLabel,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: statusSuccess,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: statusSuccess.withValues(
                                          alpha: 0.05),
                                      border: Border.all(
                                        color: statusSuccess.withValues(
                                            alpha: 0.2),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      report.completionNotes!,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: secondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // Admin Notes
                            if (ReportStatusUtils.hasAdminNotes(
                              report.adminNotes,
                            ))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(height: 30.h, color: altSecondary),
                                  Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings,
                                          color: indigoAccent, size: 16.w),
                                      SizedBox(width: 8.w),
                                      Text(
                                        lang.adminNotesLabel,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: indigoAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: indigoAccent.withValues(
                                          alpha: 0.05),
                                      border: Border.all(
                                        color: indigoAccent.withValues(
                                            alpha: 0.2),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      ReportStatusUtils.formatAdminNotes(
                                        report.adminNotes,
                                        report.reviewedBy,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: secondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      foregroundColor: inputFill,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      lang.backToReports,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _info(IconData icon, String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 18.w),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: altSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: secondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
