// lib/screens/tutorial_screens/mock_home_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/mock_home_header.dart';
import 'package:roadfix/widgets/common_widgets/diagonal_stripes.dart';
import 'package:roadfix/widgets/themes.dart';

class MockHomeScreen extends StatelessWidget {
  final bool withScaffold;

  const MockHomeScreen({super.key, this.withScaffold = true});

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      children: [
        // DiagonalStripes background covering the entire primary area
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DiagonalStripes(
            height: 120, // Height to cover primary area above header
          ),
        ),

        Column(
          children: [
            // Add spacing for the diagonal stripes area
            const SizedBox(height: 50),

            // Header - now transparent with diagonal stripes showing through
            const MockHomeHeader(),

            // Body with inputFill background - this will overlay on top
            Expanded(
              child: Container(
                width: double.infinity,
                color: inputFill,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildReportSummary(),
                      const SizedBox(height: 20),
                      _buildBanner(),
                      const SizedBox(height: 20),
                      _buildRecentReports(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (withScaffold) {
      return Scaffold(
        backgroundColor: primary, // Keep primary as base background
        body: SafeArea(child: content),
        resizeToAvoidBottomInset: false,
      );
    }

    return SizedBox(width: double.infinity, child: content);
  }

  Widget _buildReportSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Reports Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryItem('Total', '5', primary),
              _buildSummaryItem('Pending', '2', statusWarning),
              _buildSummaryItem('Resolved', '2', statusSuccess),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: altSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1A4CAF50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4D4CAF50)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Help improve road safety in your community!',
              style: TextStyle(color: secondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: statusWarning),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pothole Report',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: secondary,
                        ),
                      ),
                      Text(
                        'Main Street - Pending',
                        style: TextStyle(fontSize: 12, color: altSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '2 days ago',
                  style: TextStyle(fontSize: 12, color: altSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
