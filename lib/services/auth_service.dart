import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Use secure storage for mobile and desktop, shared preferences for web
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  late SharedPreferences _prefs;

  // Key constants
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Predefined users for demonstration (in a real app, this would be a database)
  final List<User> _predefinedUsers = [
    User(
      id: '1',
      username: 'admin',
      fullName: 'Admin User',
      rank: 'Administrator',
      department: 'IT Department',
      passwordHash: _hashPassword('admin123'),
      isAdmin: true,
    ),
    User(
      id: '2',
      username: 'officer1',
      fullName: 'John Doe',
      rank: 'Captain',
      department: 'Security Division',
      passwordHash: _hashPassword('password123'),
    ),
    User(
      id: '3',
      username: 'officer2',
      fullName: 'Jane Smith',
      rank: 'Lieutenant',
      department: 'Intelligence Unit',
      passwordHash: _hashPassword('secure456'),
    ),
  ];

  // Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Initialize the auth service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final hasUsers = _prefs.containsKey(_usersKey);

    if (!hasUsers) {
      // Store predefined users if no users exist
      final usersJson =
          jsonEncode(_predefinedUsers.map((u) => u.toMap()).toList());
      await _prefs.setString(_usersKey, usersJson);
    }
  }

  // Get all users
  Future<List<User>> getUsers() async {
    final usersJson = _prefs.getString(_usersKey);

    if (usersJson == null) {
      return [];
    }

    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((u) => User.fromMap(u)).toList();
  }

  // Save users
  Future<void> saveUsers(List<User> users) async {
    final usersJson = jsonEncode(users.map((u) => u.toMap()).toList());
    await _prefs.setString(_usersKey, usersJson);
  }

  // Helper method to read from secure storage or shared preferences
  Future<String?> _secureRead(String key) async {
    if (kIsWeb) {
      return _prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  // Helper method to write to secure storage or shared preferences
  Future<void> _secureWrite(String key, String value) async {
    if (kIsWeb) {
      await _prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  // Helper method to delete from secure storage or shared preferences
  Future<void> _secureDelete(String key) async {
    if (kIsWeb) {
      await _prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  // Login with username and password
  Future<User?> login(String username, String password) async {
    final hashedPassword = _hashPassword(password);
    final users = await getUsers();

    for (final user in users) {
      if (user.username.toLowerCase() == username.toLowerCase() &&
          user.passwordHash == hashedPassword) {
        // Store current user
        await _secureWrite(_currentUserKey, jsonEncode(user.toMap()));
        return user;
      }
    }

    return null;
  }

  // Register a new user
  Future<User> register(String username, String password, String fullName,
      String rank, String department) async {
    final users = await getUsers();

    // Check if username already exists
    if (users.any((u) => u.username.toLowerCase() == username.toLowerCase())) {
      throw Exception('Username already exists');
    }

    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      fullName: fullName,
      rank: rank,
      department: department,
      passwordHash: _hashPassword(password),
    );

    // Add user to list and save
    users.add(newUser);
    await saveUsers(users);

    return newUser;
  }

  // Logout current user
  Future<void> logout() async {
    await _secureDelete(_currentUserKey);
  }

  // Get current logged in user
  Future<User?> getCurrentUser() async {
    final userJson = await _secureRead(_currentUserKey);
    if (userJson == null) {
      return null;
    }

    return User.fromMap(jsonDecode(userJson));
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    // Biometric authentication is not available on web
    if (kIsWeb) {
      return false;
    }

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    // Biometric authentication is not available on web
    if (kIsWeb) {
      return [];
    }

    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  // Enable biometric authentication for current user
  Future<bool> enableBiometric() async {
    // Biometric authentication is not available on web
    if (kIsWeb) {
      return false;
    }

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return false;
    }

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Update user's biometric setting
        final users = await getUsers();
        final userIndex = users.indexWhere((u) => u.id == currentUser.id);

        if (userIndex >= 0) {
          users[userIndex] =
              users[userIndex].copyWith(isBiometricEnabled: true);
          await saveUsers(users);

          // Update current user in secure storage
          final updatedUser = currentUser.copyWith(isBiometricEnabled: true);
          await _secureWrite(_currentUserKey, jsonEncode(updatedUser.toMap()));

          // Store username for biometric login
          await _secureWrite(_biometricEnabledKey, currentUser.username);

          return true;
        }
      }

      return false;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        // Handle specific biometric errors
        return false;
      }
      return false;
    }
  }

  // Login with biometric authentication
  Future<User?> loginWithBiometric() async {
    // Biometric authentication is not available on web
    if (kIsWeb) {
      return null;
    }

    final biometricUsername = await _secureRead(_biometricEnabledKey);

    if (biometricUsername == null) {
      return null;
    }

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        final users = await getUsers();
        final user = users.firstWhere(
          (u) => u.username == biometricUsername && u.isBiometricEnabled,
          orElse: () =>
              throw Exception('User not found or biometric not enabled'),
        );

        // Store current user
        await _secureWrite(_currentUserKey, jsonEncode(user.toMap()));
        return user;
      }

      return null;
    } on PlatformException {
      return null;
    } catch (e) {
      return null;
    }
  }

  // Disable biometric authentication for current user
  Future<bool> disableBiometric() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return false;
    }

    // Update user's biometric setting
    final users = await getUsers();
    final userIndex = users.indexWhere((u) => u.id == currentUser.id);

    if (userIndex >= 0) {
      users[userIndex] = users[userIndex].copyWith(isBiometricEnabled: false);
      await saveUsers(users);

      // Update current user in secure storage
      final updatedUser = currentUser.copyWith(isBiometricEnabled: false);
      await _secureWrite(_currentUserKey, jsonEncode(updatedUser.toMap()));

      // Remove username for biometric login
      await _secureDelete(_biometricEnabledKey);

      return true;
    }

    return false;
  }

  // Check if biometric login is enabled for any user
  Future<bool> isBiometricLoginEnabled() async {
    final biometricUsername = await _secureRead(_biometricEnabledKey);
    return biometricUsername != null;
  }
}
