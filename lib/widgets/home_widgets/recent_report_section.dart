// lib/widgets/home_widgets/recent_report_section.dart

import 'package:flutter/material.dart';
import 'package:roadfix/widgets/home_widgets/recent_report_item.dart';
import 'package:roadfix/models/recent_report_model.dart';
import 'package:roadfix/widgets/themes.dart';

class RecentReportsSection extends StatelessWidget {
  final List<RecentReport> reports;

  const RecentReportsSection({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: reports.map((r) => RecentReportItem(report: r)).toList(),
          ),
        ),
      ],
    );
  }
}
