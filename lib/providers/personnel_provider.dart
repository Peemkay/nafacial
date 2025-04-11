import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/personnel_model.dart';
import '../models/notification_model.dart';
import '../services/personnel_service.dart';
import '../services/database_sync_service.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_service.dart';

class PersonnelProvider with ChangeNotifier {
  final PersonnelService _personnelService = PersonnelService();
  final DatabaseSyncService _syncService = DatabaseSyncService();
  final AuthProvider _authProvider = AuthProvider();
  final NotificationService _notificationService;

  List<Personnel> _allPersonnel = [];
  List<Personnel> _filteredPersonnel = [];
  Personnel? _selectedPersonnel;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  PersonnelCategory? _selectedCategory;

  // Getters
  List<Personnel> get allPersonnel => _allPersonnel;
  List<Personnel> get filteredPersonnel => _filteredPersonnel;
  Personnel? get selectedPersonnel => _selectedPersonnel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  PersonnelCategory? get selectedCategory => _selectedCategory;

  // Constructor
  PersonnelProvider({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService() {
    initialize();
  }

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Initialize personnel service
      await _personnelService.initialize();

      // Load all personnel
      await loadAllPersonnel();

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load all personnel
  Future<void> loadAllPersonnel() async {
    _setLoading(true);

    try {
      _allPersonnel = await _personnelService.getAllPersonnel();
      _applyFilters();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Set selected personnel
  void setSelectedPersonnel(Personnel? personnel) {
    _selectedPersonnel = personnel;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Set selected category
  void setSelectedCategory(PersonnelCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Apply filters
  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      _filteredPersonnel = List.from(_allPersonnel);
    } else {
      _filteredPersonnel = _allPersonnel.where((personnel) {
        // Apply category filter
        if (_selectedCategory != null &&
            personnel.category != _selectedCategory) {
          return false;
        }

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return personnel.fullName.toLowerCase().contains(query) ||
              personnel.armyNumber.toLowerCase().contains(query) ||
              personnel.rank.displayName.toLowerCase().contains(query) ||
              personnel.unit.toLowerCase().contains(query);
        }

        return true;
      }).toList();
    }

    notifyListeners();
  }

  // Get personnel by army number
  Future<Personnel?> getPersonnelByArmyNumber(String armyNumber) async {
    _setLoading(true);

    try {
      final personnel =
          await _personnelService.getPersonnelByArmyNumber(armyNumber);
      _setError(null);
      return personnel;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get personnel by ID
  Personnel? getPersonnelById(String id) {
    try {
      return _allPersonnel.firstWhere(
        (personnel) => personnel.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Add new personnel
  Future<Personnel?> addPersonnel({
    required String armyNumber,
    required String fullName,
    required String initials,
    required Rank rank,
    required String unit,
    required Corps corps,
    String? photoUrl,
    String? notes,
    ServiceStatus serviceStatus = ServiceStatus.active,
    DateTime? dateOfBirth,
    DateTime? enlistmentDate,
  }) async {
    _setLoading(true);

    try {
      final newPersonnel = await _personnelService.addPersonnel(
        armyNumber: armyNumber,
        fullName: fullName,
        initials: initials,
        rank: rank,
        unit: unit,
        corps: corps,
        photoUrl: photoUrl,
        notes: notes,
        serviceStatus: serviceStatus,
        dateOfBirth: dateOfBirth,
        enlistmentDate: enlistmentDate,
      );

      // Log the change with admin information
      final currentAdmin = await _authProvider.getCurrentUser();
      if (currentAdmin != null) {
        await _syncService.addChange(
          entityType: 'personnel',
          entityId: newPersonnel.id,
          changeType: ChangeType.create,
          data: newPersonnel.toJson(),
          adminId: currentAdmin.id,
          adminName: currentAdmin.name,
          adminArmyNumber: currentAdmin.armyNumber ?? 'UNKNOWN',
        );
      }

      // Reload personnel list
      await loadAllPersonnel();

      // Trigger database sync
      _syncService.syncDatabase();

      // Show notification about the new personnel with admin info
      _notificationService.showNotification(
        title: 'Personnel Added',
        body:
            'New personnel ${newPersonnel.fullName} (${newPersonnel.armyNumber}) has been added by ${currentAdmin?.rank ?? ''} ${currentAdmin?.fullName ?? 'Unknown'} (${currentAdmin?.armyNumber ?? 'Unknown'}).',
        type: NotificationType.success,
      );

      _setError(null);
      return newPersonnel;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update personnel
  Future<Personnel?> updatePersonnel(Personnel personnel) async {
    _setLoading(true);

    try {
      final updatedPersonnel =
          await _personnelService.updatePersonnel(personnel);

      // Update selected personnel if it's the one being updated
      if (_selectedPersonnel != null &&
          _selectedPersonnel!.id == personnel.id) {
        _selectedPersonnel = updatedPersonnel;
      }

      // Log the change with admin information
      final currentAdmin = await _authProvider.getCurrentUser();
      if (currentAdmin != null) {
        // Get the original personnel to track changes
        final originalPersonnel =
            await _personnelService.getPersonnelById(personnel.id);

        // Create a map of changes
        final Map<String, dynamic> changes = {};
        if (originalPersonnel != null) {
          final originalJson = originalPersonnel.toJson();
          final updatedJson = updatedPersonnel.toJson();

          // Compare fields and track changes
          updatedJson.forEach((key, value) {
            if (originalJson[key] != value) {
              changes[key] = {
                'from': originalJson[key],
                'to': value,
              };
            }
          });
        }

        await _syncService.addChange(
          entityType: 'personnel',
          entityId: updatedPersonnel.id,
          changeType: ChangeType.update,
          data: {
            'personnel': updatedPersonnel.toJson(),
            'changes': changes,
          },
          adminId: currentAdmin.id,
          adminName: currentAdmin.name,
          adminArmyNumber: currentAdmin.armyNumber ?? '',
        );
      }

      // Reload personnel list
      await loadAllPersonnel();

      // Trigger database sync
      _syncService.syncDatabase();

      // Show notification about the update with admin info and changes
      String changesText = '';
      // Only process changes if we have a current admin
      if (currentAdmin != null) {
        // Get the original personnel to compare changes
        final originalPersonnel =
            await _personnelService.getPersonnelById(personnel.id);
        final Map<String, dynamic> changesMap = {};

        if (originalPersonnel != null) {
          final originalJson = originalPersonnel.toJson();
          final updatedJson = updatedPersonnel.toJson();

          // Compare fields and track changes for notification
          updatedJson.forEach((key, value) {
            if (originalJson[key] != value) {
              changesMap[key] = {
                'from': originalJson[key],
                'to': value,
              };
            }
          });
        }

        if (changesMap.isNotEmpty) {
          // Get the first 2 changes to show in notification
          final changesList = changesMap.entries.take(2).map((entry) {
            final fieldName = entry.key;
            final fieldChanges = entry.value;
            return '$fieldName: ${fieldChanges['from']} → ${fieldChanges['to']}';
          }).toList();

          changesText = '\nChanges: ${changesList.join(', ')}';
          if (changesMap.length > 2) {
            changesText += ' and ${changesMap.length - 2} more';
          }
        }
      }

      _notificationService.showNotification(
        title: 'Personnel Updated',
        body:
            'Personnel ${updatedPersonnel.fullName} (${updatedPersonnel.armyNumber}) has been updated by ${currentAdmin?.rank ?? ''} ${currentAdmin?.fullName ?? 'Unknown'} (${currentAdmin?.armyNumber ?? 'Unknown'}).$changesText',
        type: NotificationType.success,
      );

      _setError(null);
      return updatedPersonnel;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update verification status
  Future<Personnel?> updateVerificationStatus(
    String personnelId,
    VerificationStatus status,
  ) async {
    _setLoading(true);

    try {
      final updatedPersonnel = await _personnelService.updateVerificationStatus(
        personnelId,
        status,
      );

      // Update selected personnel if it's the one being updated
      if (_selectedPersonnel != null && _selectedPersonnel!.id == personnelId) {
        _selectedPersonnel = updatedPersonnel;
      }

      // Reload personnel list
      await loadAllPersonnel();

      _setError(null);
      return updatedPersonnel;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete personnel
  Future<bool> deletePersonnel(String personnelId) async {
    _setLoading(true);

    try {
      await _personnelService.deletePersonnel(personnelId);

      // Clear selected personnel if it's the one being deleted
      if (_selectedPersonnel != null && _selectedPersonnel!.id == personnelId) {
        _selectedPersonnel = null;
      }

      // Reload personnel list
      await loadAllPersonnel();

      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Save personnel photo
  Future<String?> savePersonnelPhoto(String personnelId, File photoFile) async {
    _setLoading(true);

    try {
      final photoUrl = await _personnelService.savePersonnelPhoto(
        personnelId,
        photoFile,
      );

      // Reload personnel list
      await loadAllPersonnel();

      _setError(null);
      return photoUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
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
