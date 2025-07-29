import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_summary.dart';

class StatusSummaryRow extends StatelessWidget {
  final ProfileSummary user;

  const StatusSummaryRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statusBox('Reports', user.reportsCount, const Color(0xFFFF5252)),
        _statusBox('Pending', user.pendingCount, const Color(0xFFFFAB40)),
        _statusBox('Resolved', user.resolvedCount, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _statusBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 20),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
