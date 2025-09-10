import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          const ModuleHeader(title: 'Report Details'),
          Expanded(
            child: Container(
              color: inputFill,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: inputFill,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Section (Centered at top)
                        if (report.imageUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: report.imageUrl.first,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: altSecondary.withValues(alpha: 0.1),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: altSecondary.withValues(alpha: 0.1),
                                child: const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: statusDanger,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Status Badge (Centered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ReportStatusUtils.getStatusColor(
                              report.status,
                            ).withValues(alpha: 0.1),
                            border: Border.all(
                              color: ReportStatusUtils.getStatusColor(
                                report.status,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ReportStatusUtils.getDetailedStatusText(
                              report.status,
                            ),
                            style: TextStyle(
                              color: ReportStatusUtils.getStatusColor(
                                report.status,
                              ),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Report Information
                        Column(
                          children: [
                            _buildInfoRow(
                              Icons.category,
                              'Type',
                              report.reportType,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.location_on,
                              'Location',
                              report.location,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.description,
                              'Description',
                              report.description,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.schedule,
                              'Submitted',
                              DateFormat(
                                'MMM dd, yyyy - hh:mm a',
                              ).format(report.reportedAt.toDate()),
                            ),

                            // Admin Notes (if available)
                            if (ReportStatusUtils.hasAdminNotes(
                              report.adminNotes,
                            )) ...[
                              const SizedBox(height: 20),
                              const Divider(color: altSecondary),
                              const SizedBox(height: 16),
                              _buildAdminNotesSection(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: altSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: secondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminNotesSection() {
    final formattedNotes = ReportStatusUtils.formatAdminNotes(
      report.adminNotes,
      report.reviewedBy,
    );

    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: indigoAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Admin Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: indigoAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: indigoAccent.withValues(alpha: 0.05),
            border: Border.all(color: indigoAccent.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            formattedNotes,
            style: const TextStyle(fontSize: 14, color: secondary, height: 1.4),
          ),
        ),
      ],
    );
  }
}
