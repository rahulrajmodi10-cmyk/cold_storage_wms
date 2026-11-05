// lib/models/inventory_item.dart

import 'package:json_annotation/json_annotation.dart';

part 'inventory_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InventoryItem {
  final int? id;
  final String sku;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int? locationId;
  final int? expiryDate; // epoch ms
  final double? minTemp;
  final double? maxTemp;
  final double? currentTemp;
  final double? humidity;
  final String status;
  final int? createdAt;
  final int? updatedAt;

  InventoryItem({
    this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.locationId,
    this.expiryDate,
    this.minTemp,
    this.maxTemp,
    this.currentTemp,
    this.humidity,
    this.status = 'IN_STOCK',
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);
}
