import 'dart:convert';

/// Types of biometric templates
enum BiometricTemplateType {
  fingerprint,
  facialGeometry,
  irisPattern,
  voicePrint,
  other
}

/// Model representing a biometric template
class BiometricTemplate {
  final String userId;
  final String deviceId;
  final BiometricTemplateType type;
  final List<int> data;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  BiometricTemplate({
    required this.userId,
    required this.deviceId,
    required this.type,
    required this.data,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Create a copy of this template with updated properties
  BiometricTemplate copyWith({
    String? userId,
    String? deviceId,
    BiometricTemplateType? type,
    List<int>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return BiometricTemplate(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert template to JSON
  String toJson() {
    return jsonEncode({
      'userId': userId,
      'deviceId': deviceId,
      'type': type.toString(),
      'data': base64Encode(data),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    });
  }

  /// Create template from JSON
  factory BiometricTemplate.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return BiometricTemplate(
      userId: data['userId'],
      deviceId: data['deviceId'],
      type: _typeFromString(data['type']),
      data: base64Decode(data['data']),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : null,
      metadata: data['metadata'],
    );
  }

  /// Helper to convert string to BiometricTemplateType
  static BiometricTemplateType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'BiometricTemplateType.fingerprint':
        return BiometricTemplateType.fingerprint;
      case 'BiometricTemplateType.facialGeometry':
        return BiometricTemplateType.facialGeometry;
      case 'BiometricTemplateType.irisPattern':
        return BiometricTemplateType.irisPattern;
      case 'BiometricTemplateType.voicePrint':
        return BiometricTemplateType.voicePrint;
      default:
        return BiometricTemplateType.other;
    }
  }

  @override
  String toString() {
    return 'BiometricTemplate(userId: $userId, deviceId: $deviceId, type: $type, createdAt: $createdAt)';
  }
}
