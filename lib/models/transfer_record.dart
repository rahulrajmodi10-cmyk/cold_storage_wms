// lib/models/transfer_record.dart

import 'package:json_annotation/json_annotation.dart';

part 'transfer_record.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransferRecord {
  final int? id;
  final int itemId;
  final int? fromLocation;
  final int? toLocation;
  final int quantity;
  final int operatorId;
  final int timestamp;
  final String reason;

  TransferRecord({
    this.id,
    required this.itemId,
    this.fromLocation,
    this.toLocation,
    required this.quantity,
    required this.operatorId,
    required this.timestamp,
    required this.reason,
  });

  factory TransferRecord.fromJson(Map<String, dynamic> json) => _$TransferRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TransferRecordToJson(this);
}