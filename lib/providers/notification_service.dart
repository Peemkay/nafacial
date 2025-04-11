import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models/notification_model.dart';

class NotificationService with ChangeNotifier {
  // In-app notification management
  int _notificationCount = 0;
  final List<NotificationItem> _notifications = [];
  final StreamController<NotificationItem> _notificationStreamController =
      StreamController<NotificationItem>.broadcast();

  // Audio player for notification sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Stream for notification selection
  final StreamController<int> _selectNotificationStream =
      StreamController<int>.broadcast();

  // Getters
  int get notificationCount => _notificationCount;
  List<NotificationItem> get notifications => _notifications;
  Stream<NotificationItem> get notificationStream => _notificationStreamController.stream;
  Stream<int> get selectNotificationStream => _selectNotificationStream.stream;

  // Constructor
  NotificationService() {
    _loadNotifications();
  }

  // Load notifications from storage
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];

      _notifications.clear();
      for (final json in notificationsJson) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          final notification = NotificationItem(
            id: data['id'] as int,
            title: data['title'] as String,
            body: data['body'] as String,
            timestamp: DateTime.parse(data['timestamp'] as String),
            type: NotificationType.values.firstWhere(
              (e) => e.toString() == data['type'],
              orElse: () => NotificationType.info,
            ),
            isRead: data['isRead'] as bool,
            imageUrl: data['imageUrl'] as String?,
            adminInfo: data['adminInfo'] as String?,
          );
          _notifications.add(notification);
        } catch (e) {
          debugPrint('Error parsing notification: $e');
        }
      }

      _notificationCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((n) => jsonEncode({
                'id': n.id,
                'title': n.title,
                'body': n.body,
                'timestamp': n.timestamp.toIso8601String(),
                'type': n.type.toString(),
                'isRead': n.isRead,
                'imageUrl': n.imageUrl,
                'adminInfo': n.adminInfo,
              }))
          .toList();
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Show a notification
  void showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String? adminInfo,
    NotificationType type = NotificationType.info,
    bool playSound = true,
    bool vibrate = true,
    bool showBanner = true,
    bool showPopup = true,
  }) {
    // Add to internal list and notify listeners
    final notification = _addNotification(title, body, type, imageUrl, adminInfo);

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

    // Save notifications to persistent storage
    _saveNotifications();
  }

  // Mark a notification as read
  void markAsRead(int id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = notification.copyWith(isRead: true);
        _notificationCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
        _saveNotifications();
      }
    }
  }

  // Mark all notifications as read
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
      _saveNotifications();
    }
  }

  // Remove a notification
  void removeNotification(int id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      final wasUnread = !_notifications[index].isRead;
      _notifications.removeAt(index);
      if (wasUnread) {
        _notificationCount--;
      }
      notifyListeners();
      _saveNotifications();
    }
  }

  // Clear all notifications
  void clearNotifications() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      _notificationCount = 0;
      notifyListeners();
      _saveNotifications();
    }
  }

  // Add a notification to the list
  NotificationItem _addNotification(
    String title,
    String body,
    NotificationType type,
    String? imageUrl,
    [String? adminInfo]
  ) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      imageUrl: imageUrl,
      adminInfo: adminInfo,
    );

    _notifications.insert(0, notification); // Add to beginning of list
    _notificationCount++;
    notifyListeners();
    return notification;
  }

  // Play notification sound based on type
  Future<void> _playNotificationSound(NotificationType type) async {
    try {
      String soundAsset;
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
        default:
          soundAsset = 'assets/sounds/notification.mp3';
          break;
      }
      await _audioPlayer.play(AssetSource(soundAsset));
    } catch (e) {
      // Ignore sound errors
      debugPrint('Error playing notification sound: $e');
    }
  }

  // Vibrate device if supported
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
      debugPrint('Error vibrating device: $e');
    }
  }

  @override
  void dispose() {
    _notificationStreamController.close();
    _selectNotificationStream.close();
    _audioPlayer.dispose();
    super.dispose();
  }
}
