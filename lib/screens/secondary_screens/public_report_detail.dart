// lib/screens/secondary_screens/public_report_detail_screen.dart (SIMPLIFIED)
import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:roadfix/widgets/themes.dart';

class PublicReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const PublicReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: primary,
        foregroundColor: inputFill,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Image
            _buildReportImage(),
            const SizedBox(height: 16),

            // Compact Info Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        report.reportType,
                        style: const TextStyle(
                          fontSize: 14,
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
                          'Tags',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          report.tags.join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report.location,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Timeline Graph
            _buildTimelineGraph(),
            const SizedBox(height: 16),

            // Admin Notes - using ReportStatusUtils helper
            if (ReportStatusUtils.hasAdminNotes(report.adminNotes)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Notes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ReportStatusUtils.formatAdminNotes(
                        report.adminNotes,
                        null,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportImage() {
    if (report.imageUrl.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No image available',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          report.primaryImageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineGraph() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Reported milestone
              Expanded(
                child: _buildTimelineMilestone(
                  'Reported',
                  report.formattedReportedAt,
                  Colors.blue,
                  true,
                ),
              ),

              // Connection line
              Container(
                height: 2,
                width: 40,
                color: report.reviewedAt != null
                    ? ReportStatusUtils.getStatusColor(report.status)
                    : Colors.grey[300],
              ),

              // Reviewed milestone - using ReportStatusUtils
              Expanded(
                child: _buildTimelineMilestone(
                  ReportStatusUtils.getDetailedStatusText(report.status),
                  report.reviewedAt != null
                      ? _formatDateTime(report.reviewedAt!.toDate())
                      : 'Pending',
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey[300],
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? color : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCompleted ? color : Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
