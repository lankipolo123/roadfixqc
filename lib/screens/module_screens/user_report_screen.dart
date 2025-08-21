import 'package:flutter/material.dart';
import 'package:roadfix/models/user_report_model.dart';
import 'package:roadfix/mock_datas/mock_reports.dart';
import 'package:roadfix/widgets/user_report_widgets/user_report_card.dart';
import 'package:roadfix/widgets/user_report_widgets/user_report_filter_tabs.dart';
import 'package:roadfix/utils/pagination_helper.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/user_report_widgets/pagination_fab.dart'; // FAB-style pagination

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int selectedFilter = 0;
  int currentPage = 1;
  final int reportsPerPage = 10;

  List<Report> get filteredReports {
    switch (selectedFilter) {
      case 1:
        return mockReports
            .where((r) => r.status == ReportStatus.pending)
            .toList();
      case 2:
        return mockReports
            .where((r) => r.status == ReportStatus.resolved)
            .toList();
      case 3:
        return mockReports
            .where((r) => r.status == ReportStatus.rejected)
            .toList();
      default:
        return mockReports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginatedReports = paginate(
      items: filteredReports,
      page: currentPage,
      itemsPerPage: reportsPerPage,
    );

    final pageCount = totalPages(
      itemCount: filteredReports.length,
      itemsPerPage: reportsPerPage,
    );

    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        children: [
          Column(
            children: [
              const ModuleHeader(title: 'My Reports', showBack: false),

              // Fixed filter tabs just below header
              Container(
                width: double.infinity,
                color: inputFill,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: ReportFilterTabs(
                  selectedIndex: selectedFilter,
                  onChanged: (index) {
                    setState(() {
                      selectedFilter = index;
                      currentPage = 1;
                    });
                  },
                ),
              ),

              // Scrollable report list
              Expanded(
                child: Container(
                  color: inputFill,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      const SizedBox(height: 8),
                      if (paginatedReports.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text("No reports found")),
                        )
                      else
                        ...paginatedReports.map(
                          (report) => Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 330),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ReportCard(report: report),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating pagination FAB
          if (pageCount > 1)
            PaginationFAB(
              pageCount: pageCount,
              currentPage: currentPage,
              onPageSelected: (page) {
                setState(() => currentPage = page);
              },
            ),
        ],
      ),
    );
  }
}
