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

  List<QuickAction> _quickActions = [
    QuickAction(
      id: 'facial_verification',
      title: 'Facial Verification',
      icon: Icons.face,
      color: Color(0xFF001F3F), // Primary color
      route: '/facial_verification',
    ),
    QuickAction(
      id: 'personnel_database',
      title: 'Personnel Database',
      icon: Icons.people,
      color: Color(0xFF2C3E50), // Secondary color
      route: '/personnel_database',
    ),
    QuickAction(
      id: 'access_logs',
      title: 'Access Logs',
      icon: Icons.history,
      color: Colors.orange,
      route: '/access_logs',
    ),
    QuickAction(
      id: 'settings',
      title: 'System Settings',
      icon: Icons.settings,
      color: Colors.grey.shade700,
      route: '/settings',
    ),
    QuickAction(
      id: 'live_recognition',
      title: 'Live Recognition',
      icon: Icons.camera_alt,
      color: Colors.purple,
      route: '/live_recognition',
    ),
    QuickAction(
      id: 'register_personnel',
      title: 'Register Personnel',
      icon: Icons.person_add,
      color: Colors.teal,
      route: '/register_personnel',
    ),
    QuickAction(
      id: 'gallery',
      title: 'Gallery',
      icon: Icons.photo_library,
      color: Colors.deepPurple,
      route: '/gallery',
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
      final visibilityMap = Map.fromIterable(
        savedVisibility,
        key: (item) => item.split(':')[0],
        value: (item) => item.split(':')[1] == 'true',
      );

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
