import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import 'biometric_service.dart';
import 'auth_service.dart';

/// A service that handles admin authentication and verification
class AdminAuthService {
  static final AdminAuthService _instance = AdminAuthService._internal();
  factory AdminAuthService() => _instance;
  AdminAuthService._internal();

  // Services
  final BiometricService _biometricService = BiometricService();
  final AuthService _authService = AuthService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // State
  bool _isAdminVerified = false;
  DateTime? _lastVerificationTime;
  User? _verifiedAdmin;
  
  // Constants
  static const int _verificationTimeoutMinutes = 30; // Admin verification expires after 30 minutes
  static const String _adminVerifiedKey = 'admin_verified';
  static const String _adminVerificationTimeKey = 'admin_verification_time';
  static const String _adminIdKey = 'admin_id';

  // Getters
  bool get isAdminVerified => _isAdminVerified;
  User? get verifiedAdmin => _verifiedAdmin;
  
  /// Initialize the admin auth service
  Future<void> initialize() async {
    await _biometricService.initialize();
    await _loadVerificationState();
  }
  
  /// Load the verification state from shared preferences
  Future<void> _loadVerificationState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if admin is verified
    _isAdminVerified = prefs.getBool(_adminVerifiedKey) ?? false;
    
    // Check verification time
    final verificationTimeString = prefs.getString(_adminVerificationTimeKey);
    if (verificationTimeString != null) {
      _lastVerificationTime = DateTime.parse(verificationTimeString);
      
      // Check if verification has expired
      if (_isVerificationExpired()) {
        await _clearVerification();
      }
    }
    
    // Load admin user if verified
    if (_isAdminVerified) {
      final adminId = prefs.getString(_adminIdKey);
      if (adminId != null) {
        final users = await _authService.getUsers();
        _verifiedAdmin = users.firstWhere(
          (user) => user.id == adminId && user.isAdmin,
          orElse: () => null as User,
        );
        
        // If admin user not found, clear verification
        if (_verifiedAdmin == null) {
          await _clearVerification();
        }
      } else {
        await _clearVerification();
      }
    }
  }
  
  /// Check if the verification has expired
  bool _isVerificationExpired() {
    if (_lastVerificationTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastVerificationTime!);
    return difference.inMinutes > _verificationTimeoutMinutes;
  }
  
  /// Clear the admin verification
  Future<void> _clearVerification() async {
    _isAdminVerified = false;
    _lastVerificationTime = null;
    _verifiedAdmin = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminVerifiedKey);
    await prefs.remove(_adminVerificationTimeKey);
    await prefs.remove(_adminIdKey);
  }
  
  /// Verify admin with biometric authentication
  Future<bool> verifyAdmin({
    String reason = 'Verify administrator access',
    bool requireHighAccuracy = true,
  }) async {
    // Check if biometric is available
    if (!await _localAuth.canCheckBiometrics) {
      debugPrint('Biometric authentication is not available on this device');
      return false;
    }
    
    try {
      // Get admin user
      final adminUser = await _authService.getAdminUser();
      if (adminUser == null) {
        debugPrint('No admin user found');
        return false;
      }
      
      // Authenticate with biometrics
      final result = await _biometricService.authenticate(
        reason: reason,
        requireHighAccuracy: requireHighAccuracy,
        userId: adminUser.id,
      );
      
      if (result.success) {
        // Authentication successful
        _isAdminVerified = true;
        _lastVerificationTime = DateTime.now();
        _verifiedAdmin = adminUser;
        
        // Save verification state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_adminVerifiedKey, true);
        await prefs.setString(_adminVerificationTimeKey, _lastVerificationTime!.toIso8601String());
        await prefs.setString(_adminIdKey, adminUser.id);
        
        return true;
      } else {
        debugPrint('Biometric authentication failed: ${result.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during admin verification: $e');
      return false;
    }
  }
  
  /// Check if admin verification is required
  bool isVerificationRequired() {
    return !_isAdminVerified || _isVerificationExpired();
  }
  
  /// Logout admin
  Future<void> logoutAdmin() async {
    await _clearVerification();
  }
}
