import 'package:flutter/foundation.dart';
import '../models/trash_model.dart';
import '../models/personnel_model.dart';
import '../models/notification_model.dart';
import '../services/trash_service.dart';
import '../services/database_sync_service.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_service.dart';

class TrashProvider with ChangeNotifier {
  final TrashService _trashService = TrashService();
  final DatabaseSyncService _syncService = DatabaseSyncService();
  final AuthProvider _authProvider = AuthProvider();
  final NotificationService _notificationService;

  List<TrashItem> _allTrashItems = [];
  List<TrashItem> _personnelTrashItems = [];
  bool _isLoading = false;
  String? _error;

  // Constructor
  TrashProvider(this._notificationService);

  // Getters
  List<TrashItem> get allTrashItems => _allTrashItems;
  List<TrashItem> get personnelTrashItems => _personnelTrashItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Initialize trash service
      await _trashService.initialize();

      // Load all trash items
      await loadAllTrashItems();

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load all trash items
  Future<void> loadAllTrashItems() async {
    _setLoading(true);

    try {
      _allTrashItems = await _trashService.getAllTrashItems();
      _personnelTrashItems = await _trashService.getPersonnelTrashItems();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Move a personnel to trash
  Future<bool> movePersonnelToTrash(Personnel personnel) async {
    _setLoading(true);

    try {
      // Get current admin
      final currentAdmin = await _authProvider.getCurrentUser();
      if (currentAdmin == null) {
        throw Exception('Admin not authenticated');
      }

      // Move personnel to trash
      final trashItem = await _trashService.movePersonnelToTrash(
        personnel: personnel,
        deletedBy: currentAdmin.id,
        deletedByName: currentAdmin.name,
        deletedByArmyNumber: currentAdmin.armyNumber,
      );

      if (trashItem == null) {
        throw Exception('Failed to move personnel to trash');
      }

      // Log the change with admin information
      await _syncService.addChange(
        entityType: 'personnel',
        entityId: personnel.id,
        changeType: ChangeType.delete,
        data: {
          'personnel': personnel.toJson(),
          'trashItemId': trashItem.id,
        },
        adminId: currentAdmin.id,
        adminName: currentAdmin.name,
        adminArmyNumber: currentAdmin.armyNumber ?? 'UNKNOWN',
      );

      // Trigger database sync
      _syncService.syncDatabase();

      // Show notification about the deleted personnel with admin info
      _notificationService.showNotification(
        title: 'Personnel Moved to Trash',
        body:
            '${personnel.fullName} (${personnel.armyNumber}) has been moved to trash by ${currentAdmin.rank ?? ''} ${currentAdmin.fullName ?? 'Unknown'} (${currentAdmin.armyNumber ?? 'Unknown'}).',
        type: NotificationType.warning,
      );

      // Reload trash items
      await loadAllTrashItems();

      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Restore a personnel from trash
  Future<Personnel?> restorePersonnelFromTrash(String trashItemId) async {
    _setLoading(true);

    try {
      // Restore personnel
      final personnel = await _trashService.restorePersonnelFromTrash(trashItemId);

      if (personnel == null) {
        throw Exception('Failed to restore personnel from trash');
      }

      // Get current admin
      final currentAdmin = await _authProvider.getCurrentUser();
      if (currentAdmin != null) {
        // Log the change with admin information
        await _syncService.addChange(
          entityType: 'personnel',
          entityId: personnel.id,
          changeType: ChangeType.create,
          data: {
            'personnel': personnel.toJson(),
            'restoredFromTrash': true,
          },
          adminId: currentAdmin.id,
          adminName: currentAdmin.name,
          adminArmyNumber: currentAdmin.armyNumber ?? 'UNKNOWN',
        );

        // Show notification about the restored personnel with admin info
        _notificationService.showNotification(
          title: 'Personnel Restored',
          body:
              '${personnel.fullName} (${personnel.armyNumber}) has been restored from trash by ${currentAdmin.rank ?? ''} ${currentAdmin.fullName ?? 'Unknown'} (${currentAdmin.armyNumber ?? 'Unknown'}).',
          type: NotificationType.success,
        );
      }

      // Trigger database sync
      _syncService.syncDatabase();

      // Reload trash items
      await loadAllTrashItems();

      _setError(null);
      return personnel;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Permanently delete a trash item
  Future<bool> permanentlyDeleteTrashItem(String trashItemId) async {
    _setLoading(true);

    try {
      // Find the trash item first to get information for the notification
      final trashItem = _allTrashItems.firstWhere(
        (item) => item.id == trashItemId,
        orElse: () => throw Exception('Trash item not found'),
      );

      // Permanently delete the trash item
      final success = await _trashService.permanentlyDeleteTrashItem(trashItemId);

      if (!success) {
        throw Exception('Failed to permanently delete trash item');
      }

      // Get current admin
      final currentAdmin = await _authProvider.getCurrentUser();
      if (currentAdmin != null) {
        // Show notification about the permanently deleted item with admin info
        String itemDescription = 'Item';
        if (trashItem.entityType == 'personnel') {
          final personnel = trashItem.toPersonnel();
          if (personnel != null) {
            itemDescription = '${personnel.fullName} (${personnel.armyNumber})';
          }
        }

        _notificationService.showNotification(
          title: 'Item Permanently Deleted',
          body:
              '$itemDescription has been permanently deleted by ${currentAdmin.rank ?? ''} ${currentAdmin.fullName ?? 'Unknown'} (${currentAdmin.armyNumber ?? 'Unknown'}).',
          type: NotificationType.warning,
        );
      }

      // Reload trash items
      await loadAllTrashItems();

      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Empty the trash (permanently delete all items)
  Future<bool> emptyTrash() async {
    _setLoading(true);

    try {
      // Empty the trash
      final success = await _trashService.emptyTrash();

      if (!success) {
        throw Exception('Failed to empty trash');
      }

      // Get current admin
      final currentAdmin = await _authProvider.getCurrentUser();
      if (currentAdmin != null) {
        // Show notification about emptying the trash with admin info
        _notificationService.showNotification(
          title: 'Trash Emptied',
          body:
              'All items in the trash have been permanently deleted by ${currentAdmin.rank ?? ''} ${currentAdmin.fullName ?? 'Unknown'} (${currentAdmin.armyNumber ?? 'Unknown'}).',
          type: NotificationType.warning,
        );
      }

      // Reload trash items
      await loadAllTrashItems();

      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
