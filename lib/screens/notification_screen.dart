import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final notifications = provider.notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.error,
              ),
              tooltip: 'Clear All',
              onPressed: () => _showClearAllDialog(context, provider),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    provider.deleteNotification(notif.id);
                  },
                  child: _buildNotificationCard(context, notif, provider),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notif,
    NotificationProvider provider,
  ) {
    // Determine icon and color based on type
    IconData icon;
    Color color;
    switch (notif.type) {
      case 'appointment':
        icon = Icons.calendar_today_rounded;
        color = AppColors.primary;
        break;
      case 'queue':
        icon = Icons.rocket_launch_rounded;
        color = AppColors.accent;
        break;
      case 'medicine':
        icon = Icons.medication_rounded;
        color = Colors.teal.shade300;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = AppColors.textSecondary;
    }
    final formattedTime = DateFormat('hh:mm a').format(notif.timestamp);
    final isToday = DateTime.now().difference(notif.timestamp).inDays == 0;
    final dateLabel = isToday
        ? 'Today, $formattedTime'
        : DateFormat('dd MMM, hh:mm a').format(notif.timestamp);
    return Card(
      elevation: 0.5,
      color: notif.isRead
          ? Colors.white
          : AppColors.primaryLight.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notif.isRead
              ? AppColors.border
              : AppColors.primary.withOpacity(0.2),
          width: notif.isRead ? 1 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notif.isRead) {
            provider.markAsRead(notif.id);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: notif.isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 72,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'New alerts or reminders will show up here.',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text(
            'Are you sure you want to permanently clear all notifications logs?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.clearAll();
                Navigator.pop(context);
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
