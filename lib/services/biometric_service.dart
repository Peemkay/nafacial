import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/biometric_device.dart';
import '../models/biometric_template.dart';

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

  // Available biometric devices
  List<BiometricDevice> _availableDevices = [];

  // Currently selected device
  BiometricDevice? _currentDevice;

  // Getters
  Stream<List<BiometricDevice>> get devicesStream => _devicesController.stream;
  List<BiometricDevice> get availableDevices => _availableDevices;
  BiometricDevice? get currentDevice => _currentDevice;

  /// Initialize the biometric service
  Future<void> initialize() async {
    try {
      // Check if biometrics are available on the device
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        debugPrint('Biometrics not available on this device');
        return;
      }

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('Available biometrics: $availableBiometrics');

      // Initialize built-in biometric devices
      _initializeBuiltInDevices(availableBiometrics);

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
        // For Android 10+ we need storage permission to access USB devices
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          debugPrint('Storage permission denied');
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
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    if (_currentDevice == null) {
      debugPrint('No biometric device selected');
      return false;
    }

    try {
      // For built-in devices, use the local_auth package
      if (_currentDevice!.isBuiltIn) {
        return await _localAuth.authenticate(
          localizedReason: reason,
          options: AuthenticationOptions(
            stickyAuth: stickyAuth,
            useErrorDialogs: useErrorDialogs,
          ),
        );
      } else {
        // For external devices, we would implement custom authentication logic
        // This is a placeholder for demonstration
        return await _authenticateWithExternalDevice(_currentDevice!, reason);
      }
    } on PlatformException catch (e) {
      debugPrint('Error during authentication: ${e.message}');
      if (e.code == auth_error.notAvailable) {
        debugPrint('Biometric authentication not available');
      } else if (e.code == auth_error.notEnrolled) {
        debugPrint('No biometrics enrolled on this device');
      } else if (e.code == auth_error.lockedOut) {
        debugPrint(
            'Biometric authentication locked out due to too many attempts');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        debugPrint('Biometric authentication permanently locked out');
      }
      return false;
    } catch (e) {
      debugPrint('Unexpected error during authentication: $e');
      return false;
    }
  }

  /// Authenticate with an external biometric device
  Future<bool> _authenticateWithExternalDevice(
      BiometricDevice device, String reason) async {
    // This would be implemented with device-specific logic
    // For demonstration, we'll simulate a successful authentication

    await Future.delayed(
        const Duration(seconds: 2)); // Simulate processing time

    debugPrint('Authenticated with external device: ${device.name}');
    return true;
  }

  /// Enroll a new biometric template
  Future<bool> enrollTemplate({
    required String userId,
    required BiometricTemplateType templateType,
    required List<int> templateData,
  }) async {
    if (_currentDevice == null) {
      debugPrint('No biometric device selected');
      return false;
    }

    try {
      // Create a new template
      final template = BiometricTemplate(
        userId: userId,
        deviceId: _currentDevice!.id,
        type: templateType,
        data: templateData,
        createdAt: DateTime.now(),
      );

      // Store the template securely
      await _storeTemplate(template);

      debugPrint('Enrolled new biometric template for user: $userId');
      return true;
    } catch (e) {
      debugPrint('Error enrolling biometric template: $e');
      return false;
    }
  }

  /// Store a biometric template securely
  Future<void> _storeTemplate(BiometricTemplate template) async {
    // Convert template to JSON
    final templateJson = template.toJson();

    // Store in secure storage
    await _secureStorage.write(
      key: 'biometric_template_' +
          template.userId +
          '_' +
          template.type.toString(),
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
        key: 'biometric_template_' + userId + '_' + templateType.toString(),
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
  Future<bool> verifyBiometric({
    required String userId,
    required BiometricTemplateType templateType,
    required List<int> sampleData,
  }) async {
    try {
      // Get the stored template
      final template = await getTemplate(
        userId: userId,
        templateType: templateType,
      );

      if (template == null) {
        debugPrint('No template found for user: $userId');
        return false;
      }

      // Compare the sample with the template
      // In a real implementation, this would use a biometric matching algorithm
      // For demonstration, we'll simulate a match

      await Future.delayed(
          const Duration(seconds: 1)); // Simulate processing time

      debugPrint('Verified biometric for user: $userId');
      return true;
    } catch (e) {
      debugPrint('Error verifying biometric: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _devicesController.close();
  }
}
