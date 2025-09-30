import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportStatusUtils {
  // Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status) {
      case ReportStatus.pending:
        return statusWarning;
      case ReportStatus.approved:
        return statusSuccess; // GREEN for approved!
      case ReportStatus.resolved:
        return statusSuccess; // Keep green for resolved too
      case ReportStatus.rejected:
        return statusDanger;
      default:
        return statusWarning;
    }
  }

  // Get status text display
  static String getStatusText(String status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.approved:
        return 'Approved'; // Added approved text
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  // Get status icon
  static IconData getStatusIcon(String status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.hourglass_empty;
      case ReportStatus.approved:
        return Icons.check_circle; // Added approved icon
      case ReportStatus.resolved:
        return Icons.task_alt; // Different icon for resolved
      case ReportStatus.rejected:
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  // Get detailed status text for detail screen
  static String getDetailedStatusText(String status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending Review';
      case ReportStatus.approved:
        return 'Approved'; // Added approved detailed text
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
      default:
        return 'Pending Review';
    }
  }

  // Get priority color based on priority string
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case ReportPriority.low:
        return tealAccent;
      case ReportPriority.medium:
        return statusWarning;
      case ReportPriority.high:
        return statusDanger;
      case ReportPriority.urgent:
        return redDark;
      default:
        return statusWarning;
    }
  }

  // Get priority text display
  static String getPriorityText(String priority) {
    switch (priority) {
      case ReportPriority.low:
        return 'Low';
      case ReportPriority.medium:
        return 'Medium';
      case ReportPriority.high:
        return 'High';
      case ReportPriority.urgent:
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  // Get priority icon
  static IconData getPriorityIcon(String priority) {
    switch (priority) {
      case ReportPriority.low:
        return Icons.arrow_downward;
      case ReportPriority.medium:
        return Icons.remove;
      case ReportPriority.high:
        return Icons.arrow_upward;
      case ReportPriority.urgent:
        return Icons.priority_high;
      default:
        return Icons.remove;
    }
  }

  // Build status widget for cards
  static Widget buildStatusWidget(String status, {double fontSize = 12}) {
    final color = getStatusColor(status);
    final text = getStatusText(status);

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );
  }

  // Build status badge for detail screens
  static Widget buildStatusBadge(String status) {
    final color = getStatusColor(status);
    final text = getDetailedStatusText(status);
    final icon = getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Check if report has admin notes
  static bool hasAdminNotes(String? adminNotes) {
    return adminNotes != null && adminNotes.isNotEmpty;
  }

  // Format admin notes display
  static String formatAdminNotes(String? adminNotes, String? reviewedBy) {
    if (adminNotes == null || adminNotes.isEmpty) return '';

    if (reviewedBy != null && reviewedBy.isNotEmpty) {
      return 'Reviewed by $reviewedBy:\n$adminNotes';
    }
    return adminNotes;
  }
}
