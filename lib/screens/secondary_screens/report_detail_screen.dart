import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/layouts/diagonal_background.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = ReportStatusUtils.getStatusColor(report.status);

    return DiagonalBackgroundLayout(
      child: Scaffold(
        backgroundColor: transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card content
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: inputFill,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Report Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: secondary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (report.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: report.imageUrl.first,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _loader(),
                              errorWidget: (_, __, ___) => _error(),
                            ),
                          ),
                        if (report.imageUrl.isNotEmpty)
                          const SizedBox(height: 20),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            border: Border.all(color: statusColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ReportStatusUtils.getDetailedStatusText(
                              report.status,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _info(Icons.category, 'Type', report.reportType),
                        _info(Icons.location_on, 'Location', report.location),
                        _info(
                          Icons.description,
                          'Description',
                          report.description,
                        ),
                        _info(
                          Icons.schedule,
                          'Submitted',
                          DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(report.reportedAt.toDate()),
                        ),

                        if (ReportStatusUtils.hasAdminNotes(report.adminNotes))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 30, color: altSecondary),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: indigoAccent,
                                    size: 16,
                                  ),
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
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: indigoAccent.withValues(alpha: 0.05),
                                  border: Border.all(
                                    color: indigoAccent.withValues(alpha: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ReportStatusUtils.formatAdminNotes(
                                    report.adminNotes,
                                    report.reviewedBy,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
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

                const Spacer(),

                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      foregroundColor: inputFill,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Back to Reports',
                      style: TextStyle(
                        fontSize: 16,
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
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 18),
        const SizedBox(width: 10),
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
    ),
  );

  static Widget _loader() => Container(
    height: 180,
    color: altSecondary.withValues(alpha: 0.1),
    child: const Center(child: CircularProgressIndicator(color: primary)),
  );

  static Widget _error() => Container(
    height: 180,
    color: altSecondary.withValues(alpha: 0.1),
    child: const Center(
      child: Icon(Icons.error, color: statusDanger, size: 48),
    ),
  );
}
