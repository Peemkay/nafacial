import '../services/database_sync_service.dart';

class ChangeLog {
  final String id;
  final String entityType; // 'personnel', 'access_log', etc.
  final String entityId;
  final ChangeType changeType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String adminId;
  final String adminName;
  final String adminArmyNumber;
  final String deviceId;

  ChangeLog({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.data,
    required this.timestamp,
    required this.adminId,
    required this.adminName,
    required this.adminArmyNumber,
    required this.deviceId,
  });

  // Convert ChangeLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'change_type': changeType.toString().split('.').last,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'admin_id': adminId,
      'admin_name': adminName,
      'admin_army_number': adminArmyNumber,
      'device_id': deviceId,
    };
  }

  // Create ChangeLog from JSON
  factory ChangeLog.fromJson(Map<String, dynamic> json) {
    return ChangeLog(
      id: json['id'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      changeType: _parseChangeType(json['change_type']),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      adminId: json['admin_id'],
      adminName: json['admin_name'],
      adminArmyNumber: json['admin_army_number'],
      deviceId: json['device_id'],
    );
  }

  // Parse change type from string
  static ChangeType _parseChangeType(String changeTypeStr) {
    switch (changeTypeStr) {
      case 'create':
        return ChangeType.create;
      case 'update':
        return ChangeType.update;
      case 'delete':
        return ChangeType.delete;
      default:
        return ChangeType.update;
    }
  }

  // Get a human-readable description of the change
  String getChangeDescription() {
    String action;
    switch (changeType) {
      case ChangeType.create:
        action = 'created';
        break;
      case ChangeType.update:
        action = 'updated';
        break;
      case ChangeType.delete:
        action = 'deleted';
        break;
    }

    String entityName;
    switch (entityType) {
      case 'personnel':
        entityName = 'personnel record';
        break;
      case 'access_log':
        entityName = 'access log';
        break;
      default:
        entityName = entityType;
    }

    return '$adminName ($adminArmyNumber) $action $entityName';
  }

  // Get the fields that were changed (for update operations)
  List<String> getChangedFields() {
    if (changeType != ChangeType.update || !data.containsKey('changes')) {
      return [];
    }

    return (data['changes'] as Map<String, dynamic>).keys.toList();
  }
}
