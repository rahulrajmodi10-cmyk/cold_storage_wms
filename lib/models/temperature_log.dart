// lib/models/temperature_log.dart

import 'package:json_annotation/json_annotation.dart';

part 'temperature_log.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory TemperatureLog.fromJson(Map<String, dynamic> json) => _$TemperatureLogFromJson(json);
  Map<String, dynamic> toJson() => _$TemperatureLogToJson(this);
}