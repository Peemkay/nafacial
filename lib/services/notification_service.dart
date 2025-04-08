import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService with ChangeNotifier {
  int _notificationCount = 0;
  List<NotificationItem> _notifications = [];

  int get notificationCount => _notificationCount;
  List<NotificationItem> get notifications => _notifications;

  NotificationService();

  void showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.info,
  }) {
    // Add to internal list
    _addNotification(title, body, type);

    // In a real implementation, we would show a platform notification here
    // For now, we're just managing the in-app notification center
  }

  void _addNotification(String title, String body, NotificationType type) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );

    _notifications.insert(0, notification); // Add to beginning of list
    _notificationCount++;
    notifyListeners();
  }

  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      if (_notificationCount > 0) _notificationCount--;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notificationCount = 0;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications = [];
    _notificationCount = 0;
    notifyListeners();
  }

  void removeNotification(int notificationId) {
    final wasUnread =
        _notifications.any((n) => n.id == notificationId && !n.isRead);
    _notifications.removeWhere((n) => n.id == notificationId);
    if (wasUnread && _notificationCount > 0) _notificationCount--;
    notifyListeners();
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });

  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
