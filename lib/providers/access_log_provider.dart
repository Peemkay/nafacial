import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/access_log_model.dart';
import '../models/personnel_model.dart';
import '../services/database_sync_service.dart';
import '../providers/auth_provider.dart';

class AccessLogProvider with ChangeNotifier {
  static const String _accessLogsKey = 'access_logs';
  
  final DatabaseSyncService _syncService = DatabaseSyncService();
  final AuthProvider _authProvider = AuthProvider();
  
  List<AccessLog> _accessLogs = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<AccessLog> get accessLogs => _accessLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize the provider
  Future<void> initialize() async {
    await loadAccessLogs();
  }
  
  // Load access logs from storage
  Future<void> loadAccessLogs() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_accessLogsKey);
      
      if (logsJson != null) {
        final List<dynamic> logsList = jsonDecode(logsJson);
        _accessLogs = logsList.map((log) => AccessLog.fromJson(log)).toList();
        
        // Sort by timestamp (newest first)
        _accessLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      
      _setError(null);
    } catch (e) {
      _setError('Error loading access logs: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new access log
  Future<AccessLog?> addAccessLog({
    required String? personnelId,
    required String? personnelName,
    required String? personnelArmyNumber,
    required AccessLogStatus status,
    required double confidence,
    String? imageUrl,
    String? location,
    String? notes,
  }) async {
    _setLoading(true);
    
    try {
      // Get current admin
      final currentAdmin = await _authProvider.getCurrentUser();
      
      // Create new access log
      final newLog = AccessLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        personnelId: personnelId,
        personnelName: personnelName,
        personnelArmyNumber: personnelArmyNumber,
        timestamp: DateTime.now(),
        status: status,
        confidence: confidence,
        imageUrl: imageUrl,
        location: location,
        deviceId: await _getDeviceId(),
        adminId: currentAdmin?.id,
        adminName: currentAdmin?.name,
        adminArmyNumber: currentAdmin?.armyNumber,
        notes: notes,
      );
      
      // Add to local list
      _accessLogs.insert(0, newLog);
      
      // Save to storage
      await _saveAccessLogs();
      
      // Log the change with admin information
      if (currentAdmin != null) {
        await _syncService.addChange(
          entityType: 'access_log',
          entityId: newLog.id,
          changeType: ChangeType.create,
          data: newLog.toJson(),
          adminId: currentAdmin.id,
          adminName: currentAdmin.name,
          adminArmyNumber: currentAdmin.armyNumber ?? 'UNKNOWN',
        );
        
        // Trigger database sync
        _syncService.syncDatabase();
      }
      
      _setError(null);
      notifyListeners();
      return newLog;
    } catch (e) {
      _setError('Error adding access log: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get access logs for a specific personnel
  List<AccessLog> getAccessLogsForPersonnel(String personnelId) {
    return _accessLogs.where((log) => log.personnelId == personnelId).toList();
  }
  
  // Get recent access logs
  List<AccessLog> getRecentAccessLogs({int limit = 10}) {
    return _accessLogs.take(limit).toList();
  }
  
  // Get access logs by date range
  List<AccessLog> getAccessLogsByDateRange(DateTime start, DateTime end) {
    return _accessLogs.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();
  }
  
  // Get access logs by status
  List<AccessLog> getAccessLogsByStatus(AccessLogStatus status) {
    return _accessLogs.where((log) => log.status == status).toList();
  }
  
  // Save access logs to storage
  Future<void> _saveAccessLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = jsonEncode(_accessLogs.map((log) => log.toJson()).toList());
      await prefs.setString(_accessLogsKey, logsJson);
    } catch (e) {
      _setError('Error saving access logs: $e');
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
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
