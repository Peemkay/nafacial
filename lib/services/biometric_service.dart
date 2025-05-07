import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/biometric_device.dart';
import '../models/biometric_template.dart';
import '../models/user_model.dart';

/// Biometric authentication event types
enum BiometricAuthEventType {
  success,
  failure,
  lockout,
  attempt,
  enrollment,
  deviceConnected,
  deviceDisconnected,
  error
}

/// Biometric authentication event
class BiometricAuthEvent {
  final BiometricAuthEventType type;
  final String message;
  final BiometricDevice? device;
  final double? confidence;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  BiometricAuthEvent({
    required this.type,
    required this.message,
    this.device,
    this.confidence,
    DateTime? timestamp,
    this.userId,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Result of a biometric authentication attempt
class BiometricAuthResult {
  final bool success;
  final String message;
  final double confidence;
  final BiometricDevice? device;
  final bool lockout;
  final Map<String, dynamic>? metadata;

  BiometricAuthResult({
    required this.success,
    required this.message,
    required this.confidence,
    this.device,
    this.lockout = false,
    this.metadata,
  });
}

/// Result of a biometric enrollment attempt
class BiometricEnrollResult {
  final bool success;
  final String message;
  final BiometricTemplate? template;
  final bool requiresAdminApproval;
  final Map<String, dynamic>? metadata;

  BiometricEnrollResult({
    required this.success,
    required this.message,
    this.template,
    this.requiresAdminApproval = false,
    this.metadata,
  });
}

/// Result of a biometric verification attempt
class BiometricVerifyResult {
  final bool success;
  final String message;
  final double confidence;
  final BiometricTemplate? template;
  final Map<String, dynamic>? metadata;

  BiometricVerifyResult({
    required this.success,
    required this.message,
    required this.confidence,
    this.template,
    this.metadata,
  });
}

/// Service to handle biometric authentication across different platforms and devices
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Stream controllers for device events
  final StreamController<List<BiometricDevice>> _devicesController =
      StreamController<List<BiometricDevice>>.broadcast();

  // Stream controller for authentication events
  final StreamController<BiometricAuthEvent> _authEventController =
      StreamController<BiometricAuthEvent>.broadcast();

  // Available biometric devices
  List<BiometricDevice> _availableDevices = [];

  // Currently selected device
  BiometricDevice? _currentDevice;

  // Error tracking
  String? _lastError;

  // Authentication settings
  double _matchThreshold = 0.65; // Reduced match threshold (65%)
  int _maxFailedAttempts = 3; // Maximum failed attempts before lockout
  int _failedAttempts = 0; // Current failed attempts count
  bool _isLockedOut = false; // Whether biometrics are locked out
  DateTime? _lockoutEndTime; // When the lockout ends
  Duration _lockoutDuration =
      const Duration(minutes: 5); // Default lockout duration
  bool _adminOnlyEnrollment = true; // Whether only admins can enroll biometrics

  // Session management
  DateTime? _lastAuthenticationTime;
  Duration _sessionTimeout =
      const Duration(minutes: 30); // Default session timeout

  // Getters
  Stream<List<BiometricDevice>> get devicesStream => _devicesController.stream;
  Stream<BiometricAuthEvent> get authEventStream => _authEventController.stream;
  List<BiometricDevice> get availableDevices => _availableDevices;
  BiometricDevice? get currentDevice => _currentDevice;
  String? get lastError => _lastError;
  bool get isLockedOut => _isLockedOut;
  double get matchThreshold => _matchThreshold;
  bool get adminOnlyEnrollment => _adminOnlyEnrollment;

  // Session management
  bool get isSessionActive =>
      _lastAuthenticationTime != null &&
      DateTime.now().difference(_lastAuthenticationTime!) < _sessionTimeout;

  /// Initialize the biometric service
  Future<void> initialize() async {
    try {
      // Check if biometrics are available on the device
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !canAuthenticate) {
        debugPrint('Biometrics not available on this device');
        debugPrint('Can check biometrics: $canCheckBiometrics');
        debugPrint('Device supported: $canAuthenticate');
        return;
      }

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('Available biometrics: $availableBiometrics');

      // Initialize built-in biometric devices
      _initializeBuiltInDevices(availableBiometrics);

      // Set default device if available
      if (_availableDevices.isNotEmpty && _currentDevice == null) {
        _currentDevice = _availableDevices.first;
        debugPrint('Set default biometric device: ${_currentDevice!.name}');
      }

      // Initialize external devices if on supported platforms
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isWindows) {
          await _initializeExternalDevices();
        }
      }

      // Notify listeners
      _devicesController.add(_availableDevices);

      // Set default device if available
      if (_availableDevices.isNotEmpty) {
        _currentDevice = _availableDevices.first;
      }
    } catch (e) {
      debugPrint('Error initializing biometric service: $e');
    }
  }

  /// Initialize built-in biometric devices
  void _initializeBuiltInDevices(List<BiometricType> availableBiometrics) {
    _availableDevices = [];

    // Add fingerprint device if available
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      _availableDevices.add(
        BiometricDevice(
          id: 'built_in_fingerprint',
          name: 'Built-in Fingerprint Scanner',
          type: BiometricDeviceType.fingerprint,
          isBuiltIn: true,
          isConnected: true,
        ),
      );
    }

    // Add face recognition device if available
    if (availableBiometrics.contains(BiometricType.face)) {
      _availableDevices.add(
        BiometricDevice(
          id: 'built_in_face',
          name: 'Built-in Face Recognition',
          type: BiometricDeviceType.facial,
          isBuiltIn: true,
          isConnected: true,
        ),
      );
    }

    // Add iris recognition device if available
    if (availableBiometrics.contains(BiometricType.iris)) {
      _availableDevices.add(
        BiometricDevice(
          id: 'built_in_iris',
          name: 'Built-in Iris Scanner',
          type: BiometricDeviceType.iris,
          isBuiltIn: true,
          isConnected: true,
        ),
      );
    }
  }

  /// Initialize external biometric devices
  Future<void> _initializeExternalDevices() async {
    try {
      // Request necessary permissions on Android
      if (Platform.isAndroid) {
        bool permissionGranted = false;

        // Check Android version to determine which permissions to request
        if (await _isAndroid13OrHigher()) {
          // For Android 13+ (API 33+), use the new granular permissions
          final photos = await Permission.photos.request();
          final videos = await Permission.videos.request();
          final audio = await Permission.audio.request();

          // Check if all required permissions are granted
          permissionGranted =
              photos.isGranted && videos.isGranted && audio.isGranted;

          if (!permissionGranted) {
            _lastError =
                'Media permissions denied: Photos: ${photos.isGranted}, Videos: ${videos.isGranted}, Audio: ${audio.isGranted}';
            debugPrint(_lastError);
          }
        } else {
          // For Android 12 and below, use the storage permission
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;

          if (!permissionGranted) {
            _lastError = 'Storage permission denied';
            debugPrint(_lastError);
          }
        }

        // Return if permissions are not granted
        if (!permissionGranted) {
          return;
        }
      }

      // Scan for USB devices
      await _scanForUsbDevices();

      // Start listening for device connection/disconnection events
      _startDeviceMonitoring();
    } catch (e) {
      debugPrint('Error initializing external devices: $e');
    }
  }

  /// Check if the device is running Android 13 (API level 33) or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33; // Android 13 is API level 33
    } catch (e) {
      debugPrint('Error checking Android version: $e');
      return false;
    }
  }

  /// Scan for USB biometric devices
  Future<void> _scanForUsbDevices() async {
    // This is a placeholder for actual USB device scanning
    // In a real implementation, you would use platform-specific code to detect USB devices

    if (Platform.isWindows) {
      // Simulate finding a USB fingerprint scanner on Windows
      _availableDevices.add(
        BiometricDevice(
          id: 'usb_fingerprint_scanner',
          name: 'USB Fingerprint Scanner',
          type: BiometricDeviceType.fingerprint,
          isBuiltIn: false,
          isConnected: true,
          connectionType: 'USB',
        ),
      );
    }

    if (Platform.isAndroid) {
      // On Android, we would use the UsbManager to find devices
      // This is a placeholder for demonstration
      _availableDevices.add(
        BiometricDevice(
          id: 'external_fingerprint_scanner',
          name: 'External Fingerprint Scanner',
          type: BiometricDeviceType.fingerprint,
          isBuiltIn: false,
          isConnected: true,
          connectionType: 'USB',
        ),
      );
    }
  }

  /// Start monitoring for device connection/disconnection events
  void _startDeviceMonitoring() {
    // This would be implemented with platform-specific code
    // For example, on Android, you would register a BroadcastReceiver for USB events
    // On Windows, you might use Win32 API calls

    // For demonstration, we'll just log that monitoring has started
    debugPrint('Started monitoring for biometric device connections');
  }

  /// Select a biometric device to use
  void selectDevice(BiometricDevice device) {
    _currentDevice = device;
    debugPrint('Selected biometric device: ${device.name}');
  }

  /// Authenticate using the current biometric device
  Future<BiometricAuthResult> authenticate({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    String? userId,
    bool requireHighAccuracy = false,
  }) async {
    try {
      // Check if biometrics are locked out
      if (_isLockedOut) {
        if (_lockoutEndTime != null &&
            DateTime.now().isAfter(_lockoutEndTime!)) {
          // Lockout period has ended
          _isLockedOut = false;
          _failedAttempts = 0;
        } else {
          // Still locked out
          final event = BiometricAuthEvent(
            type: BiometricAuthEventType.lockout,
            message:
                'Biometric authentication is locked out due to too many failed attempts',
            userId: userId,
          );
          _authEventController.add(event);

          return BiometricAuthResult(
            success: false,
            message: 'Biometric authentication is locked out',
            confidence: 0.0,
            lockout: true,
            device: _currentDevice,
          );
        }
      }

      // Re-initialize to ensure we have the latest device information
      await initialize();

      if (_availableDevices.isEmpty) {
        _lastError = 'No biometric devices available';
        debugPrint(_lastError);

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.error,
          message: _lastError!,
          userId: userId,
        );
        _authEventController.add(event);

        return BiometricAuthResult(
          success: false,
          message: _lastError!,
          confidence: 0.0,
          device: null,
        );
      }

      // If no device is selected, use the first available one
      if (_currentDevice == null && _availableDevices.isNotEmpty) {
        _currentDevice = _availableDevices.first;
        debugPrint('Auto-selected biometric device: ${_currentDevice!.name}');
      } else if (_currentDevice == null) {
        _lastError = 'No biometric device selected and none available';
        debugPrint(_lastError);

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.error,
          message: _lastError!,
          userId: userId,
        );
        _authEventController.add(event);

        return BiometricAuthResult(
          success: false,
          message: _lastError!,
          confidence: 0.0,
          device: null,
        );
      }

      // Log authentication attempt
      final attemptEvent = BiometricAuthEvent(
        type: BiometricAuthEventType.attempt,
        message: 'Authentication attempt with ${_currentDevice!.name}',
        device: _currentDevice,
        userId: userId,
      );
      _authEventController.add(attemptEvent);

      // For built-in devices, use the local_auth package
      if (_currentDevice!.isBuiltIn) {
        // Check if device is supported again just to be sure
        final isSupported = await _localAuth.isDeviceSupported();
        if (!isSupported) {
          _lastError = 'Device is not supported for biometric authentication';
          debugPrint(_lastError);

          final event = BiometricAuthEvent(
            type: BiometricAuthEventType.error,
            message: _lastError!,
            device: _currentDevice,
            userId: userId,
          );
          _authEventController.add(event);

          return BiometricAuthResult(
            success: false,
            message: _lastError!,
            confidence: 0.0,
            device: _currentDevice,
          );
        }

        // Check available biometrics again
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        debugPrint('Available biometrics before auth: $availableBiometrics');

        // Try to authenticate
        final result = await _localAuth.authenticate(
          localizedReason: reason,
          options: AuthenticationOptions(
            stickyAuth: stickyAuth,
            useErrorDialogs: useErrorDialogs,
            biometricOnly: true, // Only use biometrics, not PIN/pattern
          ),
        );

        debugPrint('Authentication result: $result');

        if (result) {
          // Authentication successful
          _lastAuthenticationTime = DateTime.now();
          _failedAttempts = 0;

          // Generate a random confidence score between 0.95 and 0.99 for demonstration
          final confidence = 0.95 + (math.Random().nextDouble() * 0.04);

          final event = BiometricAuthEvent(
            type: BiometricAuthEventType.success,
            message: 'Authentication successful with ${_currentDevice!.name}',
            device: _currentDevice,
            confidence: confidence,
            userId: userId,
          );
          _authEventController.add(event);

          return BiometricAuthResult(
            success: true,
            message: 'Authentication successful',
            confidence: confidence,
            device: _currentDevice,
          );
        } else {
          // Authentication failed
          _handleFailedAuthentication();

          final event = BiometricAuthEvent(
            type: BiometricAuthEventType.failure,
            message: 'Authentication failed with ${_currentDevice!.name}',
            device: _currentDevice,
            confidence: 0.0,
            userId: userId,
          );
          _authEventController.add(event);

          return BiometricAuthResult(
            success: false,
            message: 'Authentication failed',
            confidence: 0.0,
            device: _currentDevice,
            lockout: _isLockedOut,
          );
        }
      } else {
        // For external devices, we would implement custom authentication logic
        return await _authenticateWithExternalDevice(
          _currentDevice!,
          reason,
          userId: userId,
          requireHighAccuracy: requireHighAccuracy,
        );
      }
    } on PlatformException catch (e) {
      _lastError = 'Error during authentication: ${e.message}';
      debugPrint(_lastError);

      BiometricAuthEventType eventType = BiometricAuthEventType.error;

      if (e.code == auth_error.notAvailable) {
        _lastError = 'Biometric authentication not available';
      } else if (e.code == auth_error.notEnrolled) {
        _lastError = 'No biometrics enrolled on this device';
      } else if (e.code == auth_error.lockedOut) {
        _lastError =
            'Biometric authentication locked out due to too many attempts';
        eventType = BiometricAuthEventType.lockout;
        _isLockedOut = true;
        _lockoutEndTime = DateTime.now().add(_lockoutDuration);
      } else if (e.code == auth_error.permanentlyLockedOut) {
        _lastError = 'Biometric authentication permanently locked out';
        eventType = BiometricAuthEventType.lockout;
        _isLockedOut = true;
      }

      final event = BiometricAuthEvent(
        type: eventType,
        message: _lastError!,
        device: _currentDevice,
        userId: userId,
      );
      _authEventController.add(event);

      return BiometricAuthResult(
        success: false,
        message: _lastError!,
        confidence: 0.0,
        device: _currentDevice,
        lockout: _isLockedOut,
      );
    } catch (e) {
      _lastError = 'Unexpected error during authentication: $e';
      debugPrint(_lastError);

      final event = BiometricAuthEvent(
        type: BiometricAuthEventType.error,
        message: _lastError!,
        device: _currentDevice,
        userId: userId,
      );
      _authEventController.add(event);

      return BiometricAuthResult(
        success: false,
        message: _lastError!,
        confidence: 0.0,
        device: _currentDevice,
      );
    }
  }

  /// Handle failed authentication attempt
  void _handleFailedAuthentication() {
    _failedAttempts++;

    if (_failedAttempts >= _maxFailedAttempts) {
      _isLockedOut = true;
      _lockoutEndTime = DateTime.now().add(_lockoutDuration);
      debugPrint(
          'Biometric authentication locked out for ${_lockoutDuration.inMinutes} minutes');
    }
  }

  /// Authenticate with an external biometric device
  Future<BiometricAuthResult> _authenticateWithExternalDevice(
    BiometricDevice device,
    String reason, {
    String? userId,
    bool requireHighAccuracy = false,
  }) async {
    // This would be implemented with device-specific logic
    // For demonstration, we'll simulate a more realistic authentication

    // Simulate processing time (1-3 seconds)
    final processingTime = 1 + math.Random().nextInt(2);
    await Future.delayed(Duration(seconds: processingTime));

    // Simulate authentication result with 80% success rate
    final isSuccessful = math.Random().nextDouble() > 0.2;

    // Generate a confidence score
    double confidence;
    if (isSuccessful) {
      // For successful auth, generate score between 0.75 and 0.99
      confidence = 0.75 + (math.Random().nextDouble() * 0.24);

      // If high accuracy is required, check against threshold
      if (requireHighAccuracy && confidence < _matchThreshold) {
        // Authentication succeeded but confidence too low
        debugPrint(
            'Authentication confidence too low: $confidence < $_matchThreshold');

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.failure,
          message: 'Authentication confidence too low: $confidence',
          device: device,
          confidence: confidence,
          userId: userId,
        );
        _authEventController.add(event);

        return BiometricAuthResult(
          success: false,
          message: 'Authentication confidence too low',
          confidence: confidence,
          device: device,
        );
      }

      // Authentication successful with acceptable confidence
      _lastAuthenticationTime = DateTime.now();
      _failedAttempts = 0;

      debugPrint(
          'Authenticated with external device: ${device.name} (confidence: $confidence)');

      final event = BiometricAuthEvent(
        type: BiometricAuthEventType.success,
        message: 'Authentication successful with ${device.name}',
        device: device,
        confidence: confidence,
        userId: userId,
      );
      _authEventController.add(event);

      return BiometricAuthResult(
        success: true,
        message: 'Authentication successful',
        confidence: confidence,
        device: device,
      );
    } else {
      // For failed auth, generate score between 0.1 and 0.7
      confidence = 0.1 + (math.Random().nextDouble() * 0.6);

      // Handle failed authentication
      _handleFailedAuthentication();

      debugPrint(
          'Authentication failed with external device: ${device.name} (confidence: $confidence)');

      final event = BiometricAuthEvent(
        type: BiometricAuthEventType.failure,
        message: 'Authentication failed with ${device.name}',
        device: device,
        confidence: confidence,
        userId: userId,
      );
      _authEventController.add(event);

      return BiometricAuthResult(
        success: false,
        message: 'Authentication failed',
        confidence: confidence,
        device: device,
        lockout: _isLockedOut,
      );
    }
  }

  /// Enroll a new biometric template
  Future<BiometricEnrollResult> enrollTemplate({
    required String userId,
    required BiometricTemplateType templateType,
    required List<int> templateData,
    bool isAdmin = false,
    String? enrolledByUserId,
  }) async {
    try {
      // Check if admin-only enrollment is enabled and user is not an admin
      if (_adminOnlyEnrollment && !isAdmin) {
        _lastError = 'Only administrators can enroll biometric templates';
        debugPrint(_lastError);

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.error,
          message: _lastError!,
          userId: userId,
        );
        _authEventController.add(event);

        return BiometricEnrollResult(
          success: false,
          message: _lastError!,
          requiresAdminApproval: true,
        );
      }

      if (_currentDevice == null) {
        _lastError = 'No biometric device selected';
        debugPrint(_lastError);

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.error,
          message: _lastError!,
          userId: userId,
        );
        _authEventController.add(event);

        return BiometricEnrollResult(
          success: false,
          message: _lastError!,
        );
      }

      // Generate metadata with enrollment information
      final metadata = <String, dynamic>{
        'enrolledAt': DateTime.now().toIso8601String(),
        'enrolledBy': enrolledByUserId ?? 'self',
        'deviceName': _currentDevice!.name,
        'deviceType': _currentDevice!.type.toString(),
        'quality': _calculateTemplateQuality(templateData),
      };

      // Create a new template
      final template = BiometricTemplate(
        userId: userId,
        deviceId: _currentDevice!.id,
        type: templateType,
        data: templateData,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Store the template securely
      await _storeTemplate(template);

      debugPrint('Enrolled new biometric template for user: $userId');

      final event = BiometricAuthEvent(
        type: BiometricAuthEventType.enrollment,
        message: 'Enrolled new biometric template for user: $userId',
        device: _currentDevice,
        userId: userId,
        metadata: metadata,
      );
      _authEventController.add(event);

      return BiometricEnrollResult(
        success: true,
        message: 'Successfully enrolled biometric template',
        template: template,
      );
    } catch (e) {
      _lastError = 'Error enrolling biometric template: $e';
      debugPrint(_lastError);

      final event = BiometricAuthEvent(
        type: BiometricAuthEventType.error,
        message: _lastError!,
        device: _currentDevice,
        userId: userId,
      );
      _authEventController.add(event);

      return BiometricEnrollResult(
        success: false,
        message: _lastError!,
      );
    }
  }

  /// Calculate template quality (placeholder implementation)
  double _calculateTemplateQuality(List<int> templateData) {
    // In a real implementation, this would analyze the template data
    // and return a quality score based on factors like:
    // - Number of minutiae points (for fingerprints)
    // - Image clarity
    // - Coverage area
    // - etc.

    // For demonstration, return a random quality score between 0.7 and 1.0
    return 0.7 + (math.Random().nextDouble() * 0.3);
  }

  /// Store a biometric template securely
  Future<void> _storeTemplate(BiometricTemplate template) async {
    // Convert template to JSON
    final templateJson = template.toJson();

    // Store in secure storage
    await _secureStorage.write(
      key: 'biometric_template_${template.userId}_${template.type}',
      value: templateJson,
    );
  }

  /// Retrieve a biometric template
  Future<BiometricTemplate?> getTemplate({
    required String userId,
    required BiometricTemplateType templateType,
  }) async {
    try {
      // Retrieve from secure storage
      final templateJson = await _secureStorage.read(
        key: 'biometric_template_${userId}_$templateType',
      );

      if (templateJson == null) {
        return null;
      }

      // Parse template from JSON
      return BiometricTemplate.fromJson(templateJson);
    } catch (e) {
      debugPrint('Error retrieving biometric template: $e');
      return null;
    }
  }

  /// Verify a biometric sample against a stored template
  Future<BiometricVerifyResult> verifyBiometric({
    required String userId,
    required BiometricTemplateType templateType,
    required List<int> sampleData,
    bool requireHighAccuracy = false,
  }) async {
    try {
      // Get the stored template
      final template = await getTemplate(
        userId: userId,
        templateType: templateType,
      );

      if (template == null) {
        _lastError = 'No template found for user: $userId';
        debugPrint(_lastError);

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.failure,
          message: _lastError!,
          userId: userId,
        );
        _authEventController.add(event);

        return BiometricVerifyResult(
          success: false,
          message: _lastError!,
          confidence: 0.0,
        );
      }

      // Compare the sample with the template
      // In a real implementation, this would use a biometric matching algorithm
      // For demonstration, we'll simulate a realistic match with confidence score

      // Simulate processing time (0.5-1.5 seconds)
      final processingTime = 500 + math.Random().nextInt(1000);
      await Future.delayed(Duration(milliseconds: processingTime));

      // Generate a confidence score between 0.5 and 1.0
      final confidence = 0.5 + (math.Random().nextDouble() * 0.5);

      // Check if confidence meets the threshold
      final thresholdToUse = requireHighAccuracy ? _matchThreshold : 0.7;
      final success = confidence >= thresholdToUse;

      if (success) {
        debugPrint(
            'Verified biometric for user: $userId with confidence: $confidence');

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.success,
          message: 'Verified biometric for user: $userId',
          confidence: confidence,
          userId: userId,
          metadata: {
            'templateType': templateType.toString(),
            'deviceId': template.deviceId,
            'threshold': thresholdToUse,
          },
        );
        _authEventController.add(event);

        return BiometricVerifyResult(
          success: true,
          message: 'Biometric verification successful',
          confidence: confidence,
          template: template,
        );
      } else {
        _lastError =
            'Biometric verification failed: confidence too low ($confidence < $thresholdToUse)';
        debugPrint(_lastError);

        final event = BiometricAuthEvent(
          type: BiometricAuthEventType.failure,
          message: _lastError!,
          confidence: confidence,
          userId: userId,
          metadata: {
            'templateType': templateType.toString(),
            'deviceId': template.deviceId,
            'threshold': thresholdToUse,
          },
        );
        _authEventController.add(event);

        return BiometricVerifyResult(
          success: false,
          message: _lastError!,
          confidence: confidence,
          template: template,
        );
      }
    } catch (e) {
      _lastError = 'Error verifying biometric: $e';
      debugPrint(_lastError);

      final event = BiometricAuthEvent(
        type: BiometricAuthEventType.error,
        message: _lastError!,
        userId: userId,
      );
      _authEventController.add(event);

      return BiometricVerifyResult(
        success: false,
        message: _lastError!,
        confidence: 0.0,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    if (!_devicesController.isClosed) {
      _devicesController.close();
    }
    if (!_authEventController.isClosed) {
      _authEventController.close();
    }
  }

  /// Update match threshold
  void setMatchThreshold(double threshold) {
    if (threshold >= 0.0 && threshold <= 1.0) {
      _matchThreshold = threshold;
      debugPrint('Updated biometric match threshold to: $_matchThreshold');
    } else {
      debugPrint(
          'Invalid threshold value: $threshold (must be between 0.0 and 1.0)');
    }
  }

  /// Reset lockout state
  void resetLockout() {
    _isLockedOut = false;
    _failedAttempts = 0;
    _lockoutEndTime = null;
    debugPrint('Biometric lockout state reset');
  }

  /// Set admin-only enrollment
  void setAdminOnlyEnrollment(bool adminOnly) {
    _adminOnlyEnrollment = adminOnly;
    debugPrint('Admin-only enrollment set to: $_adminOnlyEnrollment');
  }

  /// Set session timeout
  void setSessionTimeout(Duration timeout) {
    _sessionTimeout = timeout;
    debugPrint('Session timeout set to: ${_sessionTimeout.inMinutes} minutes');
  }
}
