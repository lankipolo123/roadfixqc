import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/utils/report_status_utils.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusColor, width: 4)),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: inputFill,
            // Add subtle background tint based on status
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status-colored avatar with icon
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Icon(
                    ReportStatusUtils.getStatusIcon(report.status),
                    color: Colors.white, // White icon for better contrast
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
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
                                fontSize: 16,
                                color: secondary,
                              ),
                            ),
                          ),
                          // Status badge without opacity
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ReportStatusUtils.getStatusText(
                                report.status,
                              ).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: altSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.location,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(report.reportedAt.toDate()),
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: altSecondary,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Click to view',
                                style: TextStyle(
                                  fontSize: 11,
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
