import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class NotificationService with ChangeNotifier {
  // In-app notification management
  int _notificationCount = 0;
  List<NotificationItem> _notifications = [];
  final StreamController<NotificationItem> _notificationStreamController =
      StreamController<NotificationItem>.broadcast();

  // Audio player for notification sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getters
  int get notificationCount => _notificationCount;
  List<NotificationItem> get notifications => _notifications;
  Stream<NotificationItem> get notificationStream =>
      _notificationStreamController.stream;

  NotificationService();

  void showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    NotificationType type = NotificationType.info,
    bool playSound = true,
    bool vibrate = true,
    bool showBanner = true,
  }) {
    // Add to internal list and notify listeners
    final notification = _addNotification(title, body, type, imageUrl);

    // Add to stream for reactive UI updates
    _notificationStreamController.add(notification);

    // Play sound if requested
    if (playSound && !kIsWeb) {
      _playNotificationSound(type);
    }

    // Vibrate if requested and supported
    if (vibrate && !kIsWeb) {
      _vibrate();
    }
  }

  // Method to mark a notification as read
  void markAsRead(int id) {
    final index =
        _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = notification.copyWith(isRead: true);
        _notificationCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    }
  }

  // Method to mark all notifications as read
  void markAllAsRead() {
    bool hasUnread = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }

    if (hasUnread) {
      _notificationCount = 0;
      notifyListeners();
    }
  }

  // Method to remove a notification
  void removeNotification(int id) {
    final index =
        _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      final wasUnread = !_notifications[index].isRead;
      _notifications.removeAt(index);
      if (wasUnread) {
        _notificationCount--;
      }
      notifyListeners();
    }
  }

  // Method to clear all notifications
  void clearNotifications() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      _notificationCount = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationStreamController.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  NotificationItem _addNotification(
      String title, String body, NotificationType type, String? imageUrl) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      imageUrl: imageUrl,
    );

    _notifications.insert(0, notification); // Add to beginning of list
    _notificationCount++;
    notifyListeners();
    return notification;
  }

  void _playNotificationSound(NotificationType type) {
    try {
      String soundAsset;

      // Select sound based on notification type
      switch (type) {
        case NotificationType.success:
          soundAsset = 'assets/sounds/success.mp3';
          break;
        case NotificationType.warning:
          soundAsset = 'assets/sounds/warning.mp3';
          break;
        case NotificationType.error:
          soundAsset = 'assets/sounds/error.mp3';
          break;
        case NotificationType.info:
          soundAsset = 'assets/sounds/notification.mp3';
          break;
      }

      // Play the sound
      _audioPlayer.play(AssetSource(soundAsset));
    } catch (e) {
      // Fallback to default system sound if asset not found
      try {
        _audioPlayer.play(AssetSource('assets/sounds/notification.mp3'));
      } catch (e) {
        // Ignore if sound file not found
      }
    }
  }

  void _vibrate() {
    try {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.hasCustomVibrationsSupport().then((hasCustom) {
            if (hasCustom ?? false) {
              // Custom vibration pattern
              Vibration.vibrate(pattern: [100, 50, 100, 50, 100]);
            } else {
              // Standard vibration
              Vibration.vibrate(duration: 200);
            }
          });
        }
      });
    } catch (e) {
      // Ignore vibration errors
    }
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.imageUrl,
  });

  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? imageUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}
