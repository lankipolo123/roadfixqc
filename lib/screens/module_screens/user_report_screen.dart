import 'package:flutter/material.dart';
import 'package:roadfix/constant/report_constant.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/services/report_service.dart';
import 'package:roadfix/widgets/user_report_widgets/user_report_card.dart';
import 'package:roadfix/widgets/user_report_widgets/user_report_filter_tabs.dart';
import 'package:roadfix/screens/module_screens/report_detail_screen.dart';
import 'package:roadfix/utils/pagination_helper.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
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

  // Get filtered reports based on selected tab - NOW SORTED BY DATE
  List<ReportModel> getFilteredReports(List<ReportModel> allReports) {
    switch (selectedFilter) {
      case 1: // Pending
        return allReports
            .where((r) => r.status == ReportStatus.pending)
            .toList();
      case 2: // Approved
        return allReports
            .where((r) => r.status == ReportStatus.approved)
            .toList();
      case 3: // Resolved
        return allReports
            .where((r) => r.status == ReportStatus.resolved)
            .toList();
      case 4: // Rejected
        return allReports
            .where((r) => r.status == ReportStatus.rejected)
            .toList();
      default: // All
        return allReports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        children: [
          Column(
            children: [
              const ModuleHeader(title: 'My Reports', showBack: false),

              // Filter tabs
              Container(
                width: double.infinity,
                color: inputFill,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: ReportFilterTabs(
                  selectedIndex: selectedFilter,
                  onChanged: (index) {
                    setState(() {
                      selectedFilter = index;
                      currentPage =
                          1; // Reset to first page when filter changes
                    });
                  },
                ),
              ),

              // Reports list - NOW PROPERLY SORTED BY DATE
              Expanded(
                child: Container(
                  color: inputFill,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: StreamBuilder<List<ReportModel>>(
                    stream: _reportService
                        .getCurrentUserReportsStream(), // FIXED: Now sorts by date
                    builder: (context, snapshot) => _buildReportsBody(snapshot),
                  ),
                ),
              ),
            ],
          ),

          // Pagination FAB
          _buildPaginationFAB(),
        ],
      ),
    );
  }

  Widget _buildReportsBody(AsyncSnapshot<List<ReportModel>> snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primary),
            SizedBox(height: 16),
            Text('Loading your reports...', style: TextStyle(color: secondary)),
          ],
        ),
      );
    }

    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: statusDanger, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading reports:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: statusDanger),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: secondary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Process data - REPORTS ARE NOW SORTED BY DATE FROM FIREBASE
    final allReports = snapshot.data ?? [];
    final filteredReports = getFilteredReports(allReports);
    final paginatedReports = paginate(
      items: filteredReports,
      page: currentPage,
      itemsPerPage: reportsPerPage,
    );

    // Empty state
    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(),
              color: secondary.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondary.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            if (selectedFilter == 0 && allReports.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: secondary,
                ),
                child: const Text('Submit Your First Report'),
              ),
            ],
          ],
        ),
      );
    }

    // Reports list - NOW SHOWING NEWEST FIRST
    return RefreshIndicator(
      color: primary,
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // Date sort indicator
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Reports sorted by date (newest first)',
              style: TextStyle(
                color: secondary.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          ...paginatedReports.map(
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
          ),
        ],
      ),
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

  // Get appropriate icon for empty state
  IconData _getEmptyStateIcon() {
    switch (selectedFilter) {
      case 1:
        return Icons.hourglass_empty; // Pending
      case 2:
        return Icons.verified_outlined; // Approved
      case 3:
        return Icons.check_circle_outline; // Resolved
      case 4:
        return Icons.cancel_outlined; // Rejected
      default:
        return Icons.report_outlined; // All
    }
  }

  // Get appropriate message for empty state
  String _getEmptyStateMessage() {
    switch (selectedFilter) {
      case 1:
        return ReportConstants.emptyPendingReports;
      case 2:
        return ReportConstants.emptyApprovedReports;
      case 3:
        return ReportConstants.emptyResolvedReports;
      case 4:
        return ReportConstants.emptyRejectedReports;
      default:
        return ReportConstants.emptyAllReports;
    }
  }

  // Navigate to report details screen
  void _showReportDetails(BuildContext context, ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }
}
