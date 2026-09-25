// lib/models/transfer_record.dart

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'from_location': fromLocation,
      'to_location': toLocation,
      'quantity': quantity,
      'operator_id': operatorId,
      'timestamp': timestamp,
      'reason': reason,
    };
  }

  factory TransferRecord.fromMap(Map<String, dynamic> m) {
    return TransferRecord(
      id: m['id'] as int?,
      itemId: m['item_id'] as int,
      fromLocation: m['from_location'] as int?,
      toLocation: m['to_location'] as int?,
      quantity: m['quantity'] as int,
      operatorId: m['operator_id'] as int,
      timestamp: m['timestamp'] as int,
      reason: m['reason'] as String,
    );
  }
}