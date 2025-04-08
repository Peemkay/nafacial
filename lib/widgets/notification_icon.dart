import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../config/design_system.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final bool isDesktop = ResponsiveUtils.isDesktop(context);
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
    return GestureDetector(
      onTap: () => _showNotificationsPanel(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: badges.Badge(
          position: badges.BadgePosition.topEnd(top: -5, end: -3),
          showBadge: notificationService.notificationCount > 0,
          badgeContent: Text(
            notificationService.notificationCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(5),
          ),
          child: Icon(
            Icons.notifications,
            color: DesignSystem.primaryColor,
            size: isDesktop || isTablet ? 28 : 24,
          ),
        ),
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final notifications = notificationService.notifications;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (notifications.isNotEmpty) ...[
                              TextButton(
                                onPressed: () {
                                  notificationService.markAllAsRead();
                                  Navigator.pop(context);
                                },
                                child: const Text('Mark all as read'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  notificationService.clearNotifications();
                                  Navigator.pop(context);
                                },
                                tooltip: 'Clear all',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Notifications list
                  Expanded(
                    child: notifications.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No notifications',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _buildNotificationItem(
                                context, 
                                notification,
                                notificationService,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, 
    NotificationItem notification,
    NotificationService notificationService,
  ) {
    // Get icon and color based on notification type
    IconData icon;
    Color color;
    
    switch (notification.type) {
      case NotificationType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.warning:
        icon = Icons.warning_amber;
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
    
    // Format timestamp
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
      timeText = '${difference.inDays} days ago';
    } else {
      timeText = '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}';
    }
    
    return Dismissible(
      key: Key('notification_${notification.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        notificationService.removeNotification(notification.id);
      },
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead ? Colors.grey[50] : Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withAlpha(30),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              const SizedBox(height: 4),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            notificationService.markAsRead(notification.id);
          },
        ),
      ),
    );
  }
}
