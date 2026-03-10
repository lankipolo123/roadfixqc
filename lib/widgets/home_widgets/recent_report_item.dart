// lib/widgets/home_widgets/recent_report_item.dart

import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
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
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(10.r),
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
                    fontSize: 14.sp,
                    color: secondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14.r, color: secondary),
                    SizedBox(width: 4.w),
                    Text(
                      report.date,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: altSecondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.access_time, size: 14.r, color: altSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      report.time,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
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
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: statusColor,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}
