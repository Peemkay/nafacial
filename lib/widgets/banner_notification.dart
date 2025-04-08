import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../services/notification_service.dart';

class BannerNotification extends StatefulWidget {
  final NotificationItem notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const BannerNotification({
    Key? key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BannerNotification> createState() => _BannerNotificationState();
}

class _BannerNotificationState extends State<BannerNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isDismissing) {
        _dismissBanner();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissBanner() {
    if (_isDismissing) return;

    setState(() {
      _isDismissing = true;
    });

    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get icon and color based on notification type
    IconData icon;
    Color color;

    switch (widget.notification.type) {
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
        icon = Icons.info;
        color = DesignSystem.primaryColor;
        break;
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 4,
        child: GestureDetector(
          onTap: widget.onTap,
          onVerticalDragEnd: (_) => _dismissBanner(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: color,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.notification.body,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _dismissBanner,
                  color: Colors.grey[600],
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BannerNotificationManager extends StatefulWidget {
  final Widget child;

  const BannerNotificationManager({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<BannerNotificationManager> createState() =>
      _BannerNotificationManagerState();
}

class _BannerNotificationManagerState extends State<BannerNotificationManager> {
  NotificationItem? _currentNotification;
  final List<NotificationItem> _notificationQueue = [];

  @override
  void initState() {
    super.initState();

    // Listen for new notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      notificationService.notificationStream.listen(_handleNewNotification);
    });
  }

  void _handleNewNotification(NotificationItem notification) {
    if (mounted) {
      if (_currentNotification == null) {
        setState(() {
          _currentNotification = notification;
        });
      } else {
        // Add to queue if a notification is already showing
        _notificationQueue.add(notification);
      }
    }
  }

  void _dismissCurrentNotification() {
    if (mounted) {
      setState(() {
        if (_notificationQueue.isNotEmpty) {
          // Show next notification in queue
          _currentNotification = _notificationQueue.removeAt(0);
        } else {
          _currentNotification = null;
        }
      });
    }
  }

  void _onNotificationTap() {
    if (_currentNotification != null) {
      // Mark as read in the notification service
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      notificationService.markAsRead(_currentNotification!.id);

      // Dismiss the banner
      _dismissCurrentNotification();

      // Open the notification panel
      _showNotificationsPanel(context);
    }
  }

  void _showNotificationsPanel(BuildContext context) {
    // This is a simplified version - you would typically call your existing notification panel here
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);

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
                            if (notificationService
                                .notifications.isNotEmpty) ...[
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
                    child: notificationService.notifications.isEmpty
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
                            itemCount: notificationService.notifications.length,
                            itemBuilder: (context, index) {
                              final notification =
                                  notificationService.notifications[index];
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
      timeText =
          '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}';
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentNotification != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: BannerNotification(
                notification: _currentNotification!,
                onDismiss: _dismissCurrentNotification,
                onTap: _onNotificationTap,
              ),
            ),
          ),
      ],
    );
  }
}
