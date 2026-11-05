// lib/models/storage_location.dart

import 'package:json_annotation/json_annotation.dart';

part 'storage_location.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StorageLocation {
  final int? id;
  final String rackId;
  final String shelfId;
  final String binId;
  final String zone;
  final double capacity;
  final double currentUtilization;

  StorageLocation({
    this.id,
    required this.rackId,
    required this.shelfId,
    required this.binId,
    required this.zone,
    required this.capacity,
    this.currentUtilization = 0.0,
  });

  String get displayName => '$rackId-$shelfId-$binId';

  factory StorageLocation.fromJson(Map<String, dynamic> json) => _$StorageLocationFromJson(json);
  Map<String, dynamic> toJson() => _$StorageLocationToJson(this);
}