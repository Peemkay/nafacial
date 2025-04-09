import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility class for platform-specific operations
class PlatformUtils {
  /// Check if the current platform is web
  static bool get isWeb => kIsWeb;
  
  /// Check if the current platform is Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Check if the current platform is iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if the current platform is Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  
  /// Check if the current platform is macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  
  /// Check if the current platform is Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  /// Check if the current platform is a desktop platform
  static bool get isDesktop => 
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  /// Check if the current platform is a mobile platform
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  /// Get the platform name as a string
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }
  
  /// Check if USB devices are supported on this platform
  static bool get supportsUSBDevices => 
      !kIsWeb && (Platform.isAndroid || Platform.isWindows || Platform.isLinux);
  
  /// Check if biometric authentication is likely to be supported
  static bool get supportsBiometrics => 
      kIsWeb || Platform.isAndroid || Platform.isIOS || 
      Platform.isWindows || Platform.isMacOS;
}
