import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isBiometricEnabled = false;
  bool _isHighSecurityMode = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isBiometricAvailable => _isBiometricAvailable;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isHighSecurityMode => _isHighSecurityMode;

  // Get current user
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    // Try to get user from local storage
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Get authentication token
  Future<String?> getToken() async {
    final user = await getCurrentUser();
    return user?.token;
  }

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Initialize auth service
      await _authService.initialize();

      // Check if user is already logged in
      _currentUser = await _authService.getCurrentUser();

      // Check biometric availability
      _isBiometricAvailable = await _authService.isBiometricAvailable();
      if (_isBiometricAvailable) {
        _availableBiometrics = await _authService.getAvailableBiometrics();
      }

      // Check if biometric login is enabled
      _isBiometricEnabled = await _authService.isBiometricLoginEnabled();

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    _setLoading(true);

    try {
      final user = await _authService.login(username, password);

      if (user != null) {
        _currentUser = user;
        _isBiometricEnabled = user.isBiometricEnabled;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid username or password');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login with biometric
  Future<bool> loginWithBiometric() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) {
      _setError('Biometric authentication is not available or not enabled');
      return false;
    }

    _setLoading(true);

    try {
      final user = await _authService.loginWithBiometric();

      if (user != null) {
        _currentUser = user;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Biometric authentication failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login with biometrics using a specific user
  Future<bool> loginWithBiometrics(User user) async {
    if (!_isBiometricAvailable) {
      _setError('Biometric authentication is not available on this device');
      return false;
    }

    _setLoading(true);

    try {
      // Verify with high-security biometric authentication
      final result = await _biometricService.authenticate(
        reason: 'Authenticate as ${user.fullName}',
        requireHighAccuracy: true,
        userId: user.id,
      );

      if (result.success) {
        // Authentication successful
        _currentUser = user;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Biometric authentication failed: ${result.message}');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get admin user
  Future<User?> getAdminUser() async {
    try {
      return await _authService.getAdminUser();
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      return await _authService.getUserByUsername(username);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Enable high security mode
  void enableHighSecurityMode() {
    _isHighSecurityMode = true;
    _biometricService
        .setMatchThreshold(0.75); // Reduced high threshold for matching
    notifyListeners();
  }

  // Disable high security mode
  void disableHighSecurityMode() {
    _isHighSecurityMode = false;
    _biometricService
        .setMatchThreshold(0.65); // Reduced normal threshold for matching
    notifyListeners();
  }

  // Register a new user
  Future<bool> register(
      String username,
      String password,
      String fullName,
      String initials,
      String rank,
      String department,
      String armyNumber) async {
    _setLoading(true);

    try {
      final user = await _authService.register(
          username, password, fullName, initials, rank, department, armyNumber);

      _currentUser = user;
      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _currentUser = null;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Enable biometric authentication
  Future<bool> enableBiometric() async {
    if (!_isBiometricAvailable) {
      _setError('Biometric authentication is not available on this device');
      return false;
    }

    _setLoading(true);

    try {
      final result = await _authService.enableBiometric();

      if (result) {
        _isBiometricEnabled = true;

        // Update current user
        _currentUser = await _authService.getCurrentUser();

        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to enable biometric authentication');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Disable biometric authentication
  Future<bool> disableBiometric() async {
    _setLoading(true);

    try {
      final result = await _authService.disableBiometric();

      if (result) {
        _isBiometricEnabled = false;

        // Update current user
        _currentUser = await _authService.getCurrentUser();

        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to disable biometric authentication');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(User updatedUser) async {
    _setLoading(true);

    try {
      final result = await _authService.updateUserProfile(updatedUser);

      if (result) {
        // Update current user
        _currentUser = await _authService.getCurrentUser();

        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
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
