//lib/screens/secondary_screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/screens/secondary_screens/report_detail_screen.dart';
import 'package:roadfix/services/notification_service.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:roadfix/widgets/themes.dart';

// Create a data class to hold both reports and viewed status
class NotificationData {
  final List<ReportModel> reports;
  final Set<String> viewedIds;

  NotificationData(this.reports, this.viewedIds);
}

class NotificationsScreen extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();

  NotificationsScreen({super.key});

  // Create a combined stream to avoid timing issues
  Stream<NotificationData> get _combinedStream {
    return _notificationService.getRecentlyUpdatedReportsStream().asyncExpand((
      reports,
    ) {
      return _notificationService.getViewedNotificationIdsStream().map((
        viewedIds,
      ) {
        return NotificationData(reports, viewedIds);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: inputFill,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<NotificationData>(
        stream: _combinedStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: secondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          final reports = data.reports;
          final viewedIds = data.viewedIds;

          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No new notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: secondary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see updates on your reports here when they are reviewed by admin.',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondary.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              final isViewed = viewedIds.contains(report.id);
              return _buildDismissibleNotificationCard(
                context,
                report,
                isViewed,
                index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDismissibleNotificationCard(
    BuildContext context,
    ReportModel report,
    bool isViewed,
    int index,
  ) {
    return Dismissible(
      key: Key('notification_${report.id}_$index'),
      direction: DismissDirection.endToStart, // Swipe left to delete
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: statusDanger,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await _showDeleteConfirmation(context, report);
      },
      onDismissed: (direction) async {
        // Delete the notification
        if (report.id != null) {
          await _notificationService.deleteNotification(report.id!);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Notification deleted'),
                backgroundColor: secondary,
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: primary,
                  onPressed: () async {
                    // Restore the notification
                    await _notificationService.restoreNotification(report.id!);
                  },
                ),
              ),
            );
          }
        }
      },
      child: _buildNotificationCard(context, report, isViewed),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    ReportModel report,
    bool isViewed,
  ) {
    // Use ReportStatusUtils instead of custom _getStatusColor method
    final statusColor = ReportStatusUtils.getStatusColor(report.status);
    final relativeTime = report.reviewedAt != null
        ? _notificationService.getRelativeTime(report.reviewedAt!.toDate())
        : 'Unknown time';

    return GestureDetector(
      onTap: () async {
        // Mark as viewed when clicked
        if (report.id != null) {
          await _notificationService.markAsViewed(report.id!);
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isViewed
                ? Colors.grey.withValues(alpha: 0.3)
                : statusColor.withValues(alpha: 0.5),
            width: isViewed ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isViewed ? 0.03 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isViewed ? Colors.grey : statusColor).withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isViewed ? Icons.notifications : Icons.notifications_active,
                color: isViewed ? Colors.grey : statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Updated',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isViewed ? FontWeight.w500 : FontWeight.w600,
                      color: isViewed
                          ? secondary.withValues(alpha: 0.7)
                          : primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your ${report.reportType.toLowerCase()} report has been ${ReportStatusUtils.getStatusText(report.status).toLowerCase()}.',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondary.withValues(alpha: isViewed ? 0.6 : 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relativeTime,
                    style: TextStyle(
                      color: secondary.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: secondary.withValues(alpha: isViewed ? 0.3 : 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    ReportModel report,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: inputFill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Delete Notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: secondary.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: secondary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusDanger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
