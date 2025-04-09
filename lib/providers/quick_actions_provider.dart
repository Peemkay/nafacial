import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  bool isVisible;

  QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.isVisible = true,
  });
}

class QuickActionsProvider with ChangeNotifier {
  static const String _visibilityPreferenceKey = 'quick_actions_visibility';

  final List<QuickAction> _quickActions = [
    QuickAction(
      id: 'facial_verification',
      title: 'Facial Verification',
      icon: Icons.face,
      color: const Color(0xFF1E88E5), // Blue
      route: '/facial_verification',
    ),
    QuickAction(
      id: 'personnel_database',
      title: 'Personnel Database',
      icon: Icons.people,
      color: const Color(0xFF43A047), // Green
      route: '/personnel_database',
    ),
    QuickAction(
      id: 'access_logs',
      title: 'Access Logs',
      icon: Icons.history,
      color: const Color(0xFFE53935), // Red
      route: '/access_logs',
    ),
    QuickAction(
      id: 'settings',
      title: 'System Settings',
      icon: Icons.settings,
      color: const Color(0xFF546E7A), // Blue Grey
      route: '/settings',
    ),
    QuickAction(
      id: 'live_recognition',
      title: 'Live Recognition',
      icon: Icons.camera_alt,
      color: const Color(0xFF8E24AA), // Purple
      route: '/live_recognition',
    ),
    QuickAction(
      id: 'register_personnel',
      title: 'Register Personnel',
      icon: Icons.person_add,
      color: const Color(0xFF00897B), // Teal
      route: '/register_personnel',
    ),
    QuickAction(
      id: 'gallery',
      title: 'Gallery',
      icon: Icons.photo_library,
      color: const Color(0xFF5E35B1), // Deep Purple
      route: '/gallery',
    ),
    QuickAction(
      id: 'notifications',
      title: 'Notifications',
      icon: Icons.notifications,
      color: const Color(0xFFFFB300), // Amber
      route: '/notifications',
    ),
  ];

  List<QuickAction> get quickActions => _quickActions;

  List<QuickAction> get visibleQuickActions =>
      _quickActions.where((action) => action.isVisible).toList();

  QuickActionsProvider() {
    _loadVisibilityPreferences();
  }

  Future<void> _loadVisibilityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVisibility = prefs.getStringList(_visibilityPreferenceKey);

    if (savedVisibility != null) {
      // Create a map of visibility settings
      final visibilityMap = {
        for (var item in savedVisibility)
          item.split(':')[0]: item.split(':')[1] == 'true',
      };

      // Update quick actions visibility
      for (var action in _quickActions) {
        if (visibilityMap.containsKey(action.id)) {
          action.isVisible = visibilityMap[action.id]!;
        }
      }

      notifyListeners();
    }
  }

  Future<void> toggleActionVisibility(String actionId) async {
    final actionIndex =
        _quickActions.indexWhere((action) => action.id == actionId);

    if (actionIndex != -1) {
      _quickActions[actionIndex].isVisible =
          !_quickActions[actionIndex].isVisible;
      await _saveVisibilityPreferences();
      notifyListeners();

      // Notify app shortcuts service to update shortcuts
      _notifyShortcutsChanged();
    }
  }

  Future<void> setActionVisibility(String actionId, bool isVisible) async {
    final actionIndex =
        _quickActions.indexWhere((action) => action.id == actionId);

    if (actionIndex != -1) {
      _quickActions[actionIndex].isVisible = isVisible;
      await _saveVisibilityPreferences();
      notifyListeners();

      // Notify app shortcuts service to update shortcuts
      _notifyShortcutsChanged();
    }
  }

  Future<void> resetToDefaults() async {
    for (var action in _quickActions) {
      action.isVisible = true;
    }

    await _saveVisibilityPreferences();
    notifyListeners();

    // Notify app shortcuts service to update shortcuts
    _notifyShortcutsChanged();
  }

  // Notify that shortcuts have changed
  void _notifyShortcutsChanged() {
    // This will be used by listeners to update app shortcuts
    // The AppShortcutsService will listen to changes in this provider
  }

  Future<void> _saveVisibilityPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Create a list of strings in format "id:visibility"
    final visibilityList = _quickActions
        .map((action) => '${action.id}:${action.isVisible}')
        .toList();

    await prefs.setStringList(_visibilityPreferenceKey, visibilityList);
  }
}
