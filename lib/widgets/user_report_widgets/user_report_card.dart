import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final statusColor = ReportStatusUtils.getStatusColor(report.status);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusColor, width: 4.w)),
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            color: inputFill,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status-colored avatar with icon
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Icon(
                    ReportStatusUtils.getStatusIcon(report.status),
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.reportType,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: secondary,
                              ),
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              ReportStatusUtils.getStatusText(
                                report.status,
                              ).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        report.description,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: altSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12.r,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              report.location,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(report.reportedAt.toDate()),
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12.sp,
                              color: altSecondary,
                            ),
                          ),
                          const Spacer(),
                          // Show completion badge if resolved with image
                          if (report.hasResolvedImage)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusSuccess.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: statusSuccess.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12.r,
                                    color: statusSuccess,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: statusSuccess,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 14.r,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Click to view',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
