class AccessLog {
  final String id;
  final String? personnelId;
  final String? personnelName;
  final String? personnelArmyNumber;
  final DateTime timestamp;
  final AccessLogStatus status;
  final double confidence;
  final String? imageUrl;
  final String? location;
  final String? deviceId;
  final String? adminId;
  final String? adminName;
  final String? adminArmyNumber;
  final String? notes;

  AccessLog({
    required this.id,
    this.personnelId,
    this.personnelName,
    this.personnelArmyNumber,
    required this.timestamp,
    required this.status,
    required this.confidence,
    this.imageUrl,
    this.location,
    this.deviceId,
    this.adminId,
    this.adminName,
    this.adminArmyNumber,
    this.notes,
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
      'confidence': confidence,
      'image_url': imageUrl,
      'location': location,
      'device_id': deviceId,
      'admin_id': adminId,
      'admin_name': adminName,
      'admin_army_number': adminArmyNumber,
      'notes': notes,
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
    );
  }

  // Parse access log status from string
  static AccessLogStatus _parseAccessLogStatus(String statusStr) {
    return AccessLogStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusStr,
      orElse: () => AccessLogStatus.unknown,
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
    double? confidence,
    String? imageUrl,
    String? location,
    String? deviceId,
    String? adminId,
    String? adminName,
    String? adminArmyNumber,
    String? notes,
  }) {
    return AccessLog(
      id: id ?? this.id,
      personnelId: personnelId ?? this.personnelId,
      personnelName: personnelName ?? this.personnelName,
      personnelArmyNumber: personnelArmyNumber ?? this.personnelArmyNumber,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      deviceId: deviceId ?? this.deviceId,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      adminArmyNumber: adminArmyNumber ?? this.adminArmyNumber,
      notes: notes ?? this.notes,
    );
  }
}

// Access log status enum
enum AccessLogStatus {
  verified,
  unverified,
  notFound,
  unknown,
}
