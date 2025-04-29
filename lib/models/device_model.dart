import 'package:flutter/material.dart';

enum DeviceType {
  scanner,
  camera,
  reader,
  terminal,
  other
}

enum DeviceStatus {
  active,
  inactive,
  maintenance,
  error
}

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final DateTime lastSync;
  final String? location;
  final String? serialNumber;
  final String? firmwareVersion;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lastSync,
    this.location,
    this.serialNumber,
    this.firmwareVersion,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceStatus? status,
    DateTime? lastSync,
    String? location,
    String? serialNumber,
    String? firmwareVersion,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}
