import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (report.status) {
      case ReportStatus.pending:
        statusColor = Colors.orange;
        break;
      case ReportStatus.resolved:
        statusColor = Colors.green;
        break;
      case ReportStatus.rejected:
        statusColor = Colors.red;
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
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: statusColor,
                child: const Icon(Icons.report, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      style: const TextStyle(fontSize: 14),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                report.status.name.toUpperCase(),
                style: TextStyle(
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
