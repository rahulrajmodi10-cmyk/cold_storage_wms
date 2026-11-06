// lib/models/storage_location.dart

import 'base_model.dart';

class StorageLocation with BaseModel {
  @override
  final int? id;
  final String rackId;
  final String shelfId;
  final String binId;
  final String zone;
  final double capacity;
  final double currentUtilization;
  @override
  final int? createdAt;
  @override
  final int? updatedAt;

  StorageLocation({
    this.id,
    required this.rackId,
    required this.shelfId,
    required this.binId,
    required this.zone,
    required this.capacity,
    this.currentUtilization = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName => '$rackId-$shelfId-$binId';

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'rack_id': rackId,
      'shelf_id': shelfId,
      'bin_id': binId,
      'zone': zone,
      'capacity': capacity,
      'current_utilization': currentUtilization,
    };
  }

  factory StorageLocation.fromMap(Map<String, dynamic> m) {
    return StorageLocation(
      id: m['id'] as int?,
      rackId: m['rack_id'] as String,
      shelfId: m['shelf_id'] as String,
      binId: m['bin_id'] as String,
      zone: m['zone'] as String,
      capacity: (m['capacity'] as num).toDouble(),
      currentUtilization: (m['current_utilization'] as num).toDouble(),
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}