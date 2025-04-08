import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionProvider with ChangeNotifier {
  static const String _lastUpdateCheckKey = 'last_update_check';
  static const String _updateAvailableKey = 'update_available';
  static const String _latestVersionKey = 'latest_version';
  static const String _updateUrlKey = 'update_url';
  static const String _updateNotesKey = 'update_notes';
  
  // Update server URL - replace with your actual update server
  final String _updateCheckUrl = 'https://nafacial-api.example.com/api/version/check';
  
  PackageInfo? _packageInfo;
  bool _isLoading = false;
  bool _updateAvailable = false;
  String? _latestVersion;
  String? _currentVersion;
  String? _updateUrl;
  String? _updateNotes;
  DateTime? _lastUpdateCheck;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get updateAvailable => _updateAvailable;
  String? get latestVersion => _latestVersion;
  String get currentVersion => _currentVersion ?? '1.0.0';
  String? get updateUrl => _updateUrl;
  String? get updateNotes => _updateNotes;
  DateTime? get lastUpdateCheck => _lastUpdateCheck;
  
  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Load package info
      _packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = _packageInfo?.version;
      
      // Load saved update status
      await _loadUpdateStatus();
      
      // Check if we need to check for updates
      final now = DateTime.now();
      if (_lastUpdateCheck == null || 
          now.difference(_lastUpdateCheck!).inHours > 24) {
        await checkForUpdates();
      }
    } catch (e) {
      debugPrint('Error initializing version provider: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load update status from shared preferences
  Future<void> _loadUpdateStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load last update check time
      final lastCheckStr = prefs.getString(_lastUpdateCheckKey);
      if (lastCheckStr != null) {
        _lastUpdateCheck = DateTime.parse(lastCheckStr);
      }
      
      // Load update availability
      _updateAvailable = prefs.getBool(_updateAvailableKey) ?? false;
      
      // Load latest version
      _latestVersion = prefs.getString(_latestVersionKey);
      
      // Load update URL
      _updateUrl = prefs.getString(_updateUrlKey);
      
      // Load update notes
      _updateNotes = prefs.getString(_updateNotesKey);
    } catch (e) {
      debugPrint('Error loading update status: $e');
    }
  }
  
  // Save update status to shared preferences
  Future<void> _saveUpdateStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save last update check time
      if (_lastUpdateCheck != null) {
        await prefs.setString(_lastUpdateCheckKey, _lastUpdateCheck!.toIso8601String());
      }
      
      // Save update availability
      await prefs.setBool(_updateAvailableKey, _updateAvailable);
      
      // Save latest version
      if (_latestVersion != null) {
        await prefs.setString(_latestVersionKey, _latestVersion!);
      }
      
      // Save update URL
      if (_updateUrl != null) {
        await prefs.setString(_updateUrlKey, _updateUrl!);
      }
      
      // Save update notes
      if (_updateNotes != null) {
        await prefs.setString(_updateNotesKey, _updateNotes!);
      }
    } catch (e) {
      debugPrint('Error saving update status: $e');
    }
  }
  
  // Check for updates
  Future<bool> checkForUpdates() async {
    _setLoading(true);
    
    try {
      // Update last check time
      _lastUpdateCheck = DateTime.now();
      
      // For demo purposes, simulate an update check
      // In a real app, you would make an API call to your update server
      if (kDebugMode) {
        // Simulate a delay
        await Future.delayed(const Duration(seconds: 1));
        
        // Simulate an update being available
        _updateAvailable = true;
        _latestVersion = '2.0.0';
        _updateUrl = 'https://nafacial-api.example.com/downloads/nafacial-2.0.0.apk';
        _updateNotes = 'What\'s new in version 2.0.0:\n'
            '- Enhanced facial recognition accuracy\n'
            '- Improved UI and responsiveness\n'
            '- Added new personnel management features\n'
            '- Fixed various bugs and performance issues';
        
        await _saveUpdateStatus();
        notifyListeners();
        return _updateAvailable;
      }
      
      // Make API call to check for updates
      final response = await http.post(
        Uri.parse(_updateCheckUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_version': _currentVersion,
          'platform': defaultTargetPlatform.toString(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _updateAvailable = data['update_available'] ?? false;
        _latestVersion = data['latest_version'];
        _updateUrl = data['update_url'];
        _updateNotes = data['update_notes'];
        
        await _saveUpdateStatus();
        notifyListeners();
        return _updateAvailable;
      } else {
        debugPrint('Error checking for updates: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Download and install update
  Future<bool> downloadAndInstallUpdate() async {
    // This would typically launch a URL or use a package like install_plugin
    // For now, we'll just return true to simulate success
    return true;
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
