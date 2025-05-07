import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/personnel_model.dart';

/// Represents an item in the trash
class TrashItem {
  final String id;
  final String entityType; // 'personnel', 'access_log', etc.
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime deletedAt;
  final String deletedBy; // Admin ID
  final String deletedByName; // Admin name
  final String? deletedByArmyNumber; // Admin army number
  final bool isPermanentlyDeleted;

  TrashItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.deletedAt,
    required this.deletedBy,
    required this.deletedByName,
    this.deletedByArmyNumber,
    this.isPermanentlyDeleted = false,
  });

  /// Create a TrashItem from a Personnel object
  factory TrashItem.fromPersonnel({
    required Personnel personnel,
    required String deletedBy,
    required String deletedByName,
    String? deletedByArmyNumber,
  }) {
    return TrashItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      entityType: 'personnel',
      entityId: personnel.id,
      data: personnel.toJson(),
      deletedAt: DateTime.now(),
      deletedBy: deletedBy,
      deletedByName: deletedByName,
      deletedByArmyNumber: deletedByArmyNumber,
    );
  }

  /// Convert TrashItem to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'deletedAt': deletedAt.toIso8601String(),
      'deletedBy': deletedBy,
      'deletedByName': deletedByName,
      'deletedByArmyNumber': deletedByArmyNumber,
      'isPermanentlyDeleted': isPermanentlyDeleted,
    };
  }

  /// Create a TrashItem from a map (e.g., from JSON)
  factory TrashItem.fromMap(Map<String, dynamic> map) {
    return TrashItem(
      id: map['id'],
      entityType: map['entityType'],
      entityId: map['entityId'],
      data: map['data'],
      deletedAt: DateTime.parse(map['deletedAt']),
      deletedBy: map['deletedBy'],
      deletedByName: map['deletedByName'],
      deletedByArmyNumber: map['deletedByArmyNumber'],
      isPermanentlyDeleted: map['isPermanentlyDeleted'] ?? false,
    );
  }

  /// Convert TrashItem to JSON
  String toJson() => jsonEncode(toMap());

  /// Create a TrashItem from JSON
  factory TrashItem.fromJson(String source) =>
      TrashItem.fromMap(jsonDecode(source));

  /// Create a copy of this TrashItem with the given fields replaced
  TrashItem copyWith({
    String? id,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? deletedAt,
    String? deletedBy,
    String? deletedByName,
    String? deletedByArmyNumber,
    bool? isPermanentlyDeleted,
  }) {
    return TrashItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      deletedByName: deletedByName ?? this.deletedByName,
      deletedByArmyNumber: deletedByArmyNumber ?? this.deletedByArmyNumber,
      isPermanentlyDeleted: isPermanentlyDeleted ?? this.isPermanentlyDeleted,
    );
  }

  /// Get the original Personnel object from the trash item
  Personnel? toPersonnel() {
    if (entityType != 'personnel') {
      return null;
    }

    try {
      return Personnel.fromJson(data);
    } catch (e) {
      debugPrint('Error converting trash item to personnel: $e');
      return null;
    }
  }

  /// Get a formatted string representing when this item was deleted
  String get deletedTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(deletedAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
