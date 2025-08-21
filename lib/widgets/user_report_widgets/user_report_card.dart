import 'package:flutter/material.dart';
import 'package:roadfix/models/user_report_model.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Use themed status colors
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: statusColor, width: 4)),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: inputFill,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: statusColor,
                child: const Icon(
                  Icons.report,
                  color: inputFill,
                ), // icon color uses theme now
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: altSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                report.status.name.toUpperCase(),
                style: textTheme.labelLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
