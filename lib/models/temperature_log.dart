// lib/models/temperature_log.dart

class TemperatureLog {
  final int? id;
  final int itemId;
  final int locationId;
  final double temperature;
  final double humidity;
  final int timestamp;
  final String sensorId;

  TemperatureLog({
    this.id,
    required this.itemId,
    required this.locationId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.sensorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    );
  }
}