import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../providers/quick_actions_provider.dart';

/// Service to manage app shortcuts (quick actions) that appear when long-pressing the app icon
/// or on the lock screen.
class AppShortcutsService {
  final QuickActions _quickActions = const QuickActions();

  /// Initialize app shortcuts
  void initialize(BuildContext context) {
    // Skip on web platform
    if (kIsWeb) return;

    // Skip on platforms other than Android and iOS
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      final quickActionsProvider =
          Provider.of<QuickActionsProvider>(context, listen: false);

      // Get the top 4 visible quick actions for shortcuts
      final visibleActions = quickActionsProvider.visibleQuickActions;
      final shortcutItems = <ShortcutItem>[];

      // Add up to 4 shortcuts (platform limitation)
      for (int i = 0; i < visibleActions.length && i < 4; i++) {
        final action = visibleActions[i];
        shortcutItems.add(
          ShortcutItem(
            type: action.id,
            localizedTitle: action.title,
            icon: _getIconNameForPlatform(action.icon),
          ),
        );
      }

      // Set the shortcuts
      _quickActions.setShortcutItems(shortcutItems);

      // Listen for shortcut item invocations
      _quickActions.initialize((shortcutType) {
        // Handle the shortcut action
        _handleShortcut(context, shortcutType);
      });
    } catch (e) {
      debugPrint('Error initializing app shortcuts: $e');
    }
  }

  /// Update app shortcuts when quick actions change
  void updateShortcuts(BuildContext context) {
    initialize(context);
  }

  /// Handle shortcut action when app is launched from a shortcut
  void _handleShortcut(BuildContext context, String shortcutType) {
    final quickActionsProvider =
        Provider.of<QuickActionsProvider>(context, listen: false);

    // Find the action with the matching ID
    final action = quickActionsProvider.quickActions.firstWhere(
      (action) => action.id == shortcutType,
      orElse: () => quickActionsProvider.quickActions.first,
    );

    // Navigate to the appropriate route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(action.route);
    });
  }

  /// Get the appropriate icon name for the platform
  String _getIconNameForPlatform(IconData icon) {
    // Map Flutter icons to platform-specific icon names
    // This is a simplified mapping - you may need to expand this
    switch (icon.codePoint) {
      case 0xe332: // Icons.face
        return 'face';
      case 0xe7ef: // Icons.people
        return 'people';
      case 0xe889: // Icons.history
        return 'history';
      case 0xe8b8: // Icons.settings
        return 'settings';
      case 0xe3af: // Icons.camera_alt
        return 'camera';
      case 0xe7fe: // Icons.person_add
        return 'person_add';
      case 0xe413: // Icons.photo_library
        return 'photo_library';
      default:
        return 'app_icon'; // Default icon
    }
  }
}
