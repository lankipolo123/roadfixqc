import 'package:flutter/material.dart';
import 'package:roadfix/models/profile_summary.dart';
import 'package:roadfix/widgets/themes.dart';

class StatusSummaryRow extends StatelessWidget {
  final ProfileSummary user;

  const StatusSummaryRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statusBox('Reports', user.reportsCount, statusDanger),
        _statusBox('Pending', user.pendingCount, statusWarning),
        _statusBox('Resolved', user.resolvedCount, statusSuccess),
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
