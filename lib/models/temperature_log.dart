// lib/models/temperature_log.dart

import 'base_model.dart';

class TemperatureLog with BaseModel {
  @override
  final int? id;
  final int itemId;
  final int locationId;
  final double temperature;
  final double humidity;
  final int timestamp;
  final String sensorId;
  @override
  final int? createdAt;
  @override
  final int? updatedAt;

  TemperatureLog({
    this.id,
    required this.itemId,
    required this.locationId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.sensorId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'item_id': itemId,
      'location_id': locationId,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp,
      'sensor_id': sensorId,
    };
  }

  factory TemperatureLog.fromMap(Map<String, dynamic> m) {
    return TemperatureLog(
      id: m['id'] as int?,
      itemId: m['item_id'] as int,
      locationId: m['location_id'] as int,
      temperature: (m['temperature'] as num).toDouble(),
      humidity: (m['humidity'] as num).toDouble(),
      timestamp: m['timestamp'] as int,
      sensorId: m['sensor_id'] as String,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}