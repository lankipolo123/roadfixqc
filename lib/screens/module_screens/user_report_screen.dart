// lib/screens/report_screen.dart (COMPLETE FILE)
import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_constant.dart';
import 'package:roadfix/layouts/reports_screen_layout.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/services/report_service.dart';
import 'package:roadfix/widgets/user_report_widgets/user_report_card.dart';
import 'package:roadfix/widgets/user_report_widgets/user_report_filter_tabs.dart';
import 'package:roadfix/screens/secondary_screens/report_detail_screen.dart';
import 'package:roadfix/utils/pagination_helper.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/user_report_widgets/pagination_fab.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  int selectedFilter = 0;
  int currentPage = 1;
  final int reportsPerPage = 10;

  List<ReportModel> getFilteredReports(List<ReportModel> allReports) {
    switch (selectedFilter) {
      case 1: // Pending
        return allReports
            .where((r) => r.status == ReportStatus.pending)
            .toList();
      case 2: // Accepted
        return allReports
            .where((r) => r.status == ReportStatus.accepted)
            .toList();
      case 3: // Invalid
        return allReports
            .where((r) => r.status == ReportStatus.invalid)
            .toList();
      case 4: // In Progress
        return allReports
            .where((r) => r.status == ReportStatus.inProgress)
            .toList();
      case 5: // Resolved
        return allReports
            .where((r) => r.status == ReportStatus.resolved)
            .toList();
      default: // All
        return allReports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportScreenLayout(
      title: 'My Reports',
      filterTabs: ReportFilterTabs(
        selectedIndex: selectedFilter,
        onChanged: (index) {
          setState(() {
            selectedFilter = index;
            currentPage = 1;
          });
        },
      ),
      content: StreamBuilder<List<ReportModel>>(
        stream: _reportService.getCurrentUserReportsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ReportScreenLayout.buildLoadingState();
          }

          if (snapshot.hasError) {
            return ReportScreenLayout.buildErrorState(
              error: snapshot.error.toString(),
              onRetry: () => setState(() {}),
            );
          }

          final allReports = snapshot.data ?? [];
          final filteredReports = getFilteredReports(allReports);
          final paginatedReports = paginate(
            items: filteredReports,
            page: currentPage,
            itemsPerPage: reportsPerPage,
          );

          if (filteredReports.isEmpty) {
            return ReportScreenLayout.buildEmptyState(
              icon: _getEmptyStateIcon(),
              message: _getEmptyStateMessage(),
              actionButton: (selectedFilter == 0 && allReports.isEmpty)
                  ? ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: secondary,
                      ),
                      child: const Text('Submit Your First Report'),
                    )
                  : null,
            );
          }

          return ReportScreenLayout.buildReportList(
            onRefresh: () => setState(() {}),
            children: paginatedReports
                .map(
                  (report) => Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 330),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => _showReportDetails(context, report),
                          child: ReportCard(report: report),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
      floatingWidget: _buildPaginationFAB(),
    );
  }

  Widget _buildPaginationFAB() {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getCurrentUserReportsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final filteredReports = getFilteredReports(snapshot.data!);
        final pageCount = totalPages(
          itemCount: filteredReports.length,
          itemsPerPage: reportsPerPage,
        );

        if (pageCount <= 1) return const SizedBox();

        return PaginationFAB(
          pageCount: pageCount,
          currentPage: currentPage,
          onPageSelected: (page) => setState(() => currentPage = page),
        );
      },
    );
  }

  IconData _getEmptyStateIcon() {
    switch (selectedFilter) {
      case 1:
        return Icons.hourglass_empty; // Pending
      case 2:
        return Icons.verified_outlined; // Accepted
      case 3:
        return Icons.cancel_outlined; // Invalid
      case 4:
        return Icons.autorenew_outlined; // In Progress
      case 5:
        return Icons.check_circle_outline; // Resolved
      default:
        return Icons.report_outlined; // All
    }
  }

  String _getEmptyStateMessage() {
    switch (selectedFilter) {
      case 1:
        return ReportConstants.emptyPendingReports;
      case 2:
        return ReportConstants.emptyAcceptedReports;
      case 3:
        return ReportConstants.emptyInvalidReports;
      case 4:
        return ReportConstants.emptyInProgressReports;
      case 5:
        return ReportConstants.emptyResolvedReports;
      default:
        return ReportConstants.emptyAllReports;
    }
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }
}
