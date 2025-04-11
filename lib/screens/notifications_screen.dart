import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/notification_model.dart';
import '../providers/notification_service.dart';
import '../widgets/platform_aware_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final notifications = notificationService.notifications;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                notificationService.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Notifications'),
                    content: const Text(
                        'Are you sure you want to clear all notifications?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          notificationService.clearNotifications();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications cleared'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('CLEAR'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Clear all notifications',
            ),
          ],
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: isDarkMode
                        ? DesignSystem.darkTextSecondaryColor
                        : DesignSystem.lightTextSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode
                          ? DesignSystem.darkTextSecondaryColor
                          : DesignSystem.lightTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications about personnel changes,\nverifications, and system updates here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? DesignSystem.darkTextSecondaryColor
                          : DesignSystem.lightTextSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(
                  context,
                  notification,
                  notificationService,
                  isDarkMode,
                );
              },
            ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
    NotificationService notificationService,
    bool isDarkMode,
  ) {
    // Determine icon and color based on notification type
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case NotificationType.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case NotificationType.info:
      default:
        icon = Icons.info;
        color = DesignSystem.primaryColor;
        break;
    }

    // Format time
    final now = DateTime.now();
    final difference = now.difference(notification.timestamp);
    String timeText;

    if (difference.inMinutes < 1) {
      timeText = 'Just now';
    } else if (difference.inHours < 1) {
      timeText = '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      timeText = '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      timeText = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      timeText = '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}';
    }

    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        notificationService.removeNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead
            ? (isDarkMode ? DesignSystem.darkCardColor.withOpacity(0.7) : Colors.grey[50])
            : (isDarkMode ? DesignSystem.darkCardColor : Colors.white),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  if (notification.adminInfo != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'By: ${notification.adminInfo}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (!notification.isRead) {
              notificationService.markAsRead(notification.id);
            }
          },
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        notification.isRead
                            ? Icons.mark_email_unread
                            : Icons.mark_email_read,
                        color: DesignSystem.primaryColor,
                      ),
                      title: Text(
                        notification.isRead
                            ? 'Mark as unread'
                            : 'Mark as read',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (notification.isRead) {
                          // This would require a new method in the service
                          // notificationService.markAsUnread(notification.id);
                        } else {
                          notificationService.markAsRead(notification.id);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      title: const Text('Delete'),
                      onTap: () {
                        Navigator.pop(context);
                        notificationService.removeNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification removed'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
