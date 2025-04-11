// Notification types
enum NotificationType {
  info,
  success,
  warning,
  error,
}

// Notification item model
class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? imageUrl;
  final String? adminInfo;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.imageUrl,
    this.adminInfo,
  });

  // Create a copy with modified fields
  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? imageUrl,
    String? adminInfo,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      adminInfo: adminInfo ?? this.adminInfo,
    );
  }
}
