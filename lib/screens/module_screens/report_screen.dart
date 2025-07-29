import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/mock_datas/mock_reports.dart';
import 'package:roadfix/widgets/report_widgets/report_card.dart';
import 'package:roadfix/widgets/report_widgets/report_filter_tabs.dart';
import 'package:roadfix/helpers/pagination_helper.dart';
import 'package:roadfix/widgets/header2.dart';
import 'package:roadfix/widgets/themes.dart'; // Custom theme colors

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
      backgroundColor: primary, // Yellow background
      body: Column(
        children: [
          const Header2(title: 'My Reports'),
          Expanded(
            child: Container(
              color: inputFill,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  ReportFilterTabs(
                    selectedIndex: selectedFilter,
                    onChanged: (index) {
                      setState(() {
                        selectedFilter = index;
                        currentPage = 1;
                      });
                    },
                  ),
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
                  if (pageCount > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pageCount, (index) {
                          final page = index + 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: page == currentPage
                                    ? primary
                                    : Colors.grey[300],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => currentPage = page),
                              child: Text('$page'),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
