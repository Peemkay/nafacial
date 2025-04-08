import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Service to manage hardware button press detection for quick camera launch
class ButtonService {
  static const MethodChannel _channel = MethodChannel('com.example.nafacial/buttons');
  
  /// Start the button listener service
  static Future<bool> startButtonService() async {
    if (!Platform.isAndroid) {
      return false;
    }
    
    try {
      final bool result = await _channel.invokeMethod('startButtonService');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error starting button service: ${e.message}');
      return false;
    }
  }
  
  /// Stop the button listener service
  static Future<bool> stopButtonService() async {
    if (!Platform.isAndroid) {
      return false;
    }
    
    try {
      final bool result = await _channel.invokeMethod('stopButtonService');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error stopping button service: ${e.message}');
      return false;
    }
  }
}
