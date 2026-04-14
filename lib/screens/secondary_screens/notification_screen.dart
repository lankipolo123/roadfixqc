//lib/screens/secondary_screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/models/report_model.dart';
import 'package:roadfix/screens/secondary_screens/report_detail_screen.dart';
import 'package:roadfix/services/language_service.dart';
import 'package:roadfix/services/notification_service.dart';
import 'package:roadfix/utils/report_status_utils.dart';
import 'package:roadfix/utils/pagination_helper.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/user_report_widgets/pagination_fab.dart';
import 'package:rxdart/rxdart.dart';

// Create a data class to hold both reports and viewed status
class NotificationData {
  final List<ReportModel> reports;
  final Set<String> viewedIds;

  NotificationData(this.reports, this.viewedIds);
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  int currentPage = 1;
  final int notificationsPerPage = 10;

  // Combine reports and viewed IDs into a single stream
  Stream<NotificationData> get _combinedStream {
    return Rx.combineLatest2<List<ReportModel>, Set<String>, NotificationData>(
      _notificationService.getRecentlyUpdatedReportsStream(),
      _notificationService.getViewedNotificationIdsStream(),
      (reports, viewedIds) => NotificationData(reports, viewedIds),
    );
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

          final allReports = data.reports;
          final viewedIds = data.viewedIds;

          if (allReports.isEmpty) {
            final lang = LanguageService();
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
                    lang.noNewNotifications,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: secondary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      lang.notificationsEmptyHint,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondary.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          // Apply pagination
          final paginatedReports = paginate(
            items: allReports,
            page: currentPage,
            itemsPerPage: notificationsPerPage,
          );

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100,
                ),
                itemCount: paginatedReports.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = paginatedReports[index];
                  final isViewed = viewedIds.contains(report.id);
                  return _buildDismissibleNotificationCard(
                    context,
                    report,
                    isViewed,
                    index,
                  );
                },
              ),
              // Pagination FAB
              _buildPaginationFAB(allReports.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaginationFAB(int totalNotifications) {
    final pageCount = totalPages(
      itemCount: totalNotifications,
      itemsPerPage: notificationsPerPage,
    );

    if (pageCount <= 1) return const SizedBox();

    return PaginationFAB(
      pageCount: pageCount,
      currentPage: currentPage,
      onPageSelected: (page) => setState(() => currentPage = page),
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
      direction: DismissDirection.endToStart,
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
        return await _showDeleteConfirmation(context, report);
      },
      onDismissed: (direction) async {
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
    final statusColor = ReportStatusUtils.getStatusColor(report.status);
    final relativeTime = report.reviewedAt != null
        ? _notificationService.getRelativeTime(report.reviewedAt!.toDate())
        : 'Unknown time';

    final lang = LanguageService();
    final title = lang.notificationTitle(report.status);
    final message = lang.notificationMessage(report.status, report.reportType);

    return GestureDetector(
      onTap: () async {
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                isViewed
                    ? Icons.notifications
                    : Icons.notifications_active,
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
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isViewed ? FontWeight.w500 : FontWeight.w700,
                      color: isViewed
                          ? secondary.withValues(alpha: 0.7)
                          : primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondary.withValues(
                        alpha: isViewed ? 0.55 : 0.75,
                      ),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Status badge chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      ReportStatusUtils.getStatusText(report.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relativeTime,
                    style: TextStyle(
                      color: secondary.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: secondary.withValues(alpha: isViewed ? 0.3 : 0.4),
              size: 14,
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
