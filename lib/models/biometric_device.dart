import 'dart:convert';

/// Types of biometric devices
enum BiometricDeviceType {
  fingerprint,
  facial,
  iris,
  multimodal,
  other
}

/// Model representing a biometric device
class BiometricDevice {
  final String id;
  final String name;
  final BiometricDeviceType type;
  final bool isBuiltIn;
  final bool isConnected;
  final String? connectionType; // USB, Bluetooth, etc.
  final Map<String, dynamic>? deviceInfo;

  BiometricDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isBuiltIn,
    required this.isConnected,
    this.connectionType,
    this.deviceInfo,
  });

  /// Create a copy of this device with updated properties
  BiometricDevice copyWith({
    String? id,
    String? name,
    BiometricDeviceType? type,
    bool? isBuiltIn,
    bool? isConnected,
    String? connectionType,
    Map<String, dynamic>? deviceInfo,
  }) {
    return BiometricDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  /// Convert device to JSON
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'type': type.toString(),
      'isBuiltIn': isBuiltIn,
      'isConnected': isConnected,
      'connectionType': connectionType,
      'deviceInfo': deviceInfo,
    });
  }

  /// Create device from JSON
  factory BiometricDevice.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return BiometricDevice(
      id: data['id'],
      name: data['name'],
      type: _typeFromString(data['type']),
      isBuiltIn: data['isBuiltIn'],
      isConnected: data['isConnected'],
      connectionType: data['connectionType'],
      deviceInfo: data['deviceInfo'],
    );
  }

  /// Helper to convert string to BiometricDeviceType
  static BiometricDeviceType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'BiometricDeviceType.fingerprint':
        return BiometricDeviceType.fingerprint;
      case 'BiometricDeviceType.facial':
        return BiometricDeviceType.facial;
      case 'BiometricDeviceType.iris':
        return BiometricDeviceType.iris;
      case 'BiometricDeviceType.multimodal':
        return BiometricDeviceType.multimodal;
      default:
        return BiometricDeviceType.other;
    }
  }

  @override
  String toString() {
    return 'BiometricDevice(id: $id, name: $name, type: $type, isBuiltIn: $isBuiltIn, isConnected: $isConnected)';
  }
}
