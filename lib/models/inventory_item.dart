// lib/models/inventory_item.dart

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'location_id': locationId,
      'expiry_date': expiryDate,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'current_temp': currentTemp,
      'humidity': humidity,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> m) {
    return InventoryItem(
      id: m['id'] as int?,
      sku: m['sku'] as String,
      name: m['name'] as String,
      category: m['category'] as String,
      quantity: m['quantity'] as int,
      unit: m['unit'] as String,
      locationId: m['location_id'] as int?,
      expiryDate: m['expiry_date'] as int?,
      minTemp: (m['min_temp'] as num?)?.toDouble(),
      maxTemp: (m['max_temp'] as num?)?.toDouble(),
      currentTemp: (m['current_temp'] as num?)?.toDouble(),
      humidity: (m['humidity'] as num?)?.toDouble(),
      status: m['status'] as String? ?? 'IN_STOCK',
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}
