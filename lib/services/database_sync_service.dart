import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/personnel_model.dart';
import '../models/change_log_model.dart';
import '../providers/auth_provider.dart';

class DatabaseSyncService {
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _pendingSyncActionsKey = 'pending_sync_actions';
  static const Duration _syncInterval = Duration(minutes: 15);
  
  final String _baseUrl = 'https://nafacial-api.example.com/api'; // Replace with actual API endpoint
  
  // Singleton pattern
  static final DatabaseSyncService _instance = DatabaseSyncService._internal();
  
  factory DatabaseSyncService() {
    return _instance;
  }
  
  DatabaseSyncService._internal();
  
  // Stream controller for sync status updates
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  // Timer for periodic sync
  Timer? _syncTimer;
  
  // Current sync status
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  
  // Initialize the sync service
  Future<void> initialize() async {
    // Start listening for connectivity changes
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
    
    // Start periodic sync
    _startPeriodicSync();
    
    // Check for pending sync actions
    await _checkPendingSyncActions();
  }
  
  // Start periodic sync
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncDatabase());
  }
  
  // Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      // We have connectivity, check for pending sync actions
      await _checkPendingSyncActions();
    }
  }
  
  // Check for pending sync actions
  Future<void> _checkPendingSyncActions() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingActions = prefs.getStringList(_pendingSyncActionsKey) ?? [];
    
    if (pendingActions.isNotEmpty) {
      // We have pending actions, try to sync
      await syncDatabase();
    }
  }
  
  // Sync database with server
  Future<bool> syncDatabase() async {
    if (_currentStatus == SyncStatus.syncing) {
      // Already syncing
      return false;
    }
    
    _updateSyncStatus(SyncStatus.syncing);
    
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _updateSyncStatus(SyncStatus.offline);
        return false;
      }
      
      // Get last sync time
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTime = prefs.getString(_lastSyncTimeKey);
      
      // Get pending sync actions
      final pendingActions = prefs.getStringList(_pendingSyncActionsKey) ?? [];
      
      // Prepare request data
      final requestData = {
        'last_sync_time': lastSyncTime,
        'device_id': await _getDeviceId(),
        'pending_actions': pendingActions,
      };
      
      // Send sync request
      final response = await http.post(
        Uri.parse('$_baseUrl/sync'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        // Parse response
        final responseData = jsonDecode(response.body);
        
        // Update local database with server data
        await _updateLocalDatabase(responseData);
        
        // Clear pending actions
        await prefs.setStringList(_pendingSyncActionsKey, []);
        
        // Update last sync time
        await prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
        
        _updateSyncStatus(SyncStatus.success);
        return true;
      } else {
        _updateSyncStatus(SyncStatus.error);
        return false;
      }
    } catch (e) {
      print('Sync error: $e');
      _updateSyncStatus(SyncStatus.error);
      return false;
    }
  }
  
  // Update local database with server data
  Future<void> _updateLocalDatabase(Map<String, dynamic> serverData) async {
    // Update personnel data
    if (serverData.containsKey('personnel')) {
      final personnelList = (serverData['personnel'] as List)
          .map((data) => Personnel.fromJson(data))
          .toList();
      
      // Save to local storage
      await _savePersonnelToLocalStorage(personnelList);
    }
    
    // Update change logs
    if (serverData.containsKey('change_logs')) {
      final changeLogs = (serverData['change_logs'] as List)
          .map((data) => ChangeLog.fromJson(data))
          .toList();
      
      // Save to local storage
      await _saveChangeLogsToLocalStorage(changeLogs);
    }
  }
  
  // Save personnel to local storage
  Future<void> _savePersonnelToLocalStorage(List<Personnel> personnelList) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/personnel.json');
      
      await file.writeAsString(jsonEncode(personnelList.map((p) => p.toJson()).toList()));
    } catch (e) {
      print('Error saving personnel to local storage: $e');
    }
  }
  
  // Save change logs to local storage
  Future<void> _saveChangeLogsToLocalStorage(List<ChangeLog> changeLogs) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/change_logs.json');
      
      // Read existing logs if file exists
      List<ChangeLog> existingLogs = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        existingLogs = (jsonDecode(content) as List)
            .map((data) => ChangeLog.fromJson(data))
            .toList();
      }
      
      // Merge logs (avoid duplicates by checking ID)
      final existingIds = existingLogs.map((log) => log.id).toSet();
      final newLogs = changeLogs.where((log) => !existingIds.contains(log.id)).toList();
      
      final allLogs = [...existingLogs, ...newLogs];
      
      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      await file.writeAsString(jsonEncode(allLogs.map((log) => log.toJson()).toList()));
    } catch (e) {
      print('Error saving change logs to local storage: $e');
    }
  }
  
  // Add a change to the local database and queue for sync
  Future<void> addChange({
    required String entityType,
    required String entityId,
    required ChangeType changeType,
    required Map<String, dynamic> data,
    required String adminId,
    required String adminName,
    required String adminArmyNumber,
  }) async {
    try {
      // Create change log
      final changeLog = ChangeLog(
        id: '${DateTime.now().millisecondsSinceEpoch}_${entityId}_${changeType.toString().split('.').last}',
        entityType: entityType,
        entityId: entityId,
        changeType: changeType,
        data: data,
        timestamp: DateTime.now(),
        adminId: adminId,
        adminName: adminName,
        adminArmyNumber: adminArmyNumber,
        deviceId: await _getDeviceId(),
      );
      
      // Save to local storage
      await _addChangeLogToLocalStorage(changeLog);
      
      // Add to pending sync actions
      await _addPendingSyncAction(changeLog);
    } catch (e) {
      print('Error adding change: $e');
    }
  }
  
  // Add change log to local storage
  Future<void> _addChangeLogToLocalStorage(ChangeLog changeLog) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/change_logs.json');
      
      // Read existing logs if file exists
      List<ChangeLog> existingLogs = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        existingLogs = (jsonDecode(content) as List)
            .map((data) => ChangeLog.fromJson(data))
            .toList();
      }
      
      // Add new log
      existingLogs.add(changeLog);
      
      // Sort by timestamp (newest first)
      existingLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      await file.writeAsString(jsonEncode(existingLogs.map((log) => log.toJson()).toList()));
    } catch (e) {
      print('Error adding change log to local storage: $e');
    }
  }
  
  // Add pending sync action
  Future<void> _addPendingSyncAction(ChangeLog changeLog) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingActions = prefs.getStringList(_pendingSyncActionsKey) ?? [];
      
      pendingActions.add(jsonEncode(changeLog.toJson()));
      
      await prefs.setStringList(_pendingSyncActionsKey, pendingActions);
    } catch (e) {
      print('Error adding pending sync action: $e');
    }
  }
  
  // Get change logs for an entity
  Future<List<ChangeLog>> getChangeLogsForEntity(String entityType, String entityId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/change_logs.json');
      
      if (!await file.exists()) {
        return [];
      }
      
      final content = await file.readAsString();
      final allLogs = (jsonDecode(content) as List)
          .map((data) => ChangeLog.fromJson(data))
          .toList();
      
      // Filter logs for the specific entity
      return allLogs.where((log) => 
        log.entityType == entityType && log.entityId == entityId
      ).toList();
    } catch (e) {
      print('Error getting change logs: $e');
      return [];
    }
  }
  
  // Get all change logs
  Future<List<ChangeLog>> getAllChangeLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/change_logs.json');
      
      if (!await file.exists()) {
        return [];
      }
      
      final content = await file.readAsString();
      final allLogs = (jsonDecode(content) as List)
          .map((data) => ChangeLog.fromJson(data))
          .toList();
      
      return allLogs;
    } catch (e) {
      print('Error getting all change logs: $e');
      return [];
    }
  }
  
  // Get device ID
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      // Generate a new device ID
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }
  
  // Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    // Get auth token from AuthProvider
    final authProvider = AuthProvider();
    final token = await authProvider.getToken();
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Update sync status
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }
  
  // Dispose
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

// Change type enum
enum ChangeType {
  create,
  update,
  delete,
}
