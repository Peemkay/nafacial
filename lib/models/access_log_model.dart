// Access log types
enum AccessLogType {
  login,
  logout,
  verification,
  registration,
  modification,
  deletion,
}

// Access log status
enum AccessLogStatus {
  verified,
  unverified,
  denied,
  notFound,
  unknown,
}

class AccessLog {
  final String id;
  final String? personnelId;
  final String? personnelName;
  final String? personnelArmyNumber;
  final DateTime timestamp;
  final AccessLogStatus status;
  final AccessLogType type;
  final double confidence;
  final String? imageUrl;
  final String? location;
  final String? deviceId;
  final String? adminId;
  final String? adminName;
  final String? adminArmyNumber;
  final String? notes;
  final String? details;

  AccessLog({
    required this.id,
    this.personnelId,
    this.personnelName,
    this.personnelArmyNumber,
    required this.timestamp,
    required this.status,
    required this.type,
    required this.confidence,
    this.imageUrl,
    this.location,
    this.deviceId,
    this.adminId,
    this.adminName,
    this.adminArmyNumber,
    this.notes,
    this.details,
  });

  // Convert AccessLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personnel_id': personnelId,
      'personnel_name': personnelName,
      'personnel_army_number': personnelArmyNumber,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'confidence': confidence,
      'image_url': imageUrl,
      'location': location,
      'device_id': deviceId,
      'admin_id': adminId,
      'admin_name': adminName,
      'admin_army_number': adminArmyNumber,
      'notes': notes,
      'details': details,
    };
  }

  // Create AccessLog from JSON
  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      id: json['id'],
      personnelId: json['personnel_id'],
      personnelName: json['personnel_name'],
      personnelArmyNumber: json['personnel_army_number'],
      timestamp: DateTime.parse(json['timestamp']),
      status: _parseAccessLogStatus(json['status']),
      type: _parseAccessLogType(json['type'] ?? 'verification'),
      confidence: json['confidence'] is int
          ? (json['confidence'] as int).toDouble()
          : json['confidence'],
      imageUrl: json['image_url'],
      location: json['location'],
      deviceId: json['device_id'],
      adminId: json['admin_id'],
      adminName: json['admin_name'],
      adminArmyNumber: json['admin_army_number'],
      notes: json['notes'],
      details: json['details'],
    );
  }

  // Parse access log status from string
  static AccessLogStatus _parseAccessLogStatus(String statusStr) {
    return AccessLogStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusStr,
      orElse: () => AccessLogStatus.unknown,
    );
  }

  // Parse access log type from string
  static AccessLogType _parseAccessLogType(String typeStr) {
    return AccessLogType.values.firstWhere(
      (t) => t.toString().split('.').last == typeStr,
      orElse: () => AccessLogType.verification,
    );
  }

  // Create a copy of the AccessLog with modified fields
  AccessLog copyWith({
    String? id,
    String? personnelId,
    String? personnelName,
    String? personnelArmyNumber,
    DateTime? timestamp,
    AccessLogStatus? status,
    AccessLogType? type,
    double? confidence,
    String? imageUrl,
    String? location,
    String? deviceId,
    String? adminId,
    String? adminName,
    String? adminArmyNumber,
    String? notes,
    String? details,
  }) {
    return AccessLog(
      id: id ?? this.id,
      personnelId: personnelId ?? this.personnelId,
      personnelName: personnelName ?? this.personnelName,
      personnelArmyNumber: personnelArmyNumber ?? this.personnelArmyNumber,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      deviceId: deviceId ?? this.deviceId,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      adminArmyNumber: adminArmyNumber ?? this.adminArmyNumber,
      notes: notes ?? this.notes,
      details: details ?? this.details,
    );
  }
}

// This enum is now defined at the top of the file
