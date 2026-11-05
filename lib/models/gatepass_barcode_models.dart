// lib/models/gatepass_barcode_models.dart

import 'package:json_annotation/json_annotation.dart';

part 'gatepass_barcode_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GatepassType {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final String? workflowType; // SIMPLE, APPROVAL_REQUIRED, MULTI_LEVEL_APPROVAL
  final int requiresVehicle;
  final int requiresDriver;
  final int requiresSecurityCheck;
  final int validityHours;
  final String? colorCode;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  GatepassType({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.workflowType,
    this.requiresVehicle = 1,
    this.requiresDriver = 1,
    this.requiresSecurityCheck = 1,
    this.validityHours = 24,
    this.colorCode,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory GatepassType.fromJson(Map<String, dynamic> json) =>
      _$GatepassTypeFromJson(json);
  Map<String, dynamic> toJson() => _$GatepassTypeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Gatepass {
  final int? id;
  final String gatepassNumber;
  final int gatepassTypeId;
  final String?
      referenceType; // SALES_ORDER, PURCHASE_ORDER, TRANSFER, RETURN, SCRAP, OTHER
  final int? referenceId;
  final int? partyId;
  final String
      status; // DRAFT, SUBMITTED, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED, EXPIRED
  final String priority; // LOW, NORMAL, HIGH, URGENT

  // Vehicle Details
  final int? vehicleId;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? driverName;
  final String? driverPhone;
  final String? driverLicense;
  final String? driverPhotoPath;

  // Timing
  final int? requestedDate;
  final int? approvedDate;
  final int? validFrom;
  final int? validTo;
  final int? actualEntryTime;
  final int? actualExitTime;

  // Locations
  final int? entryGateId;
  final int? exitGateId;
  final String? originLocation;
  final String? destinationLocation;

  // Security
  final int? securityOfficerId;
  final String? securityCheckStatus; // PENDING, CLEARED, FLAGGED
  final String? securityNotes;
  final String? sealNumber;
  final int sealIntact;

  // QR Code
  final String? qrCodeData;
  final String? qrCodeImagePath;
  final int? qrGeneratedAt;

  // Counts
  final int totalItems;
  final double totalQuantity;
  final double totalWeight;
  final int totalPackages;

  // Verification
  final int? verifiedBy;
  final int? verifiedAt;
  final String? verificationMethod; // MANUAL, CAMERA_AI, BARCODE, WEIGHT
  final String? discrepancyNotes;

  // Approval
  final int? approvedBy;
  final int? approvedAt;
  final String? rejectionReason;

  // Completion
  final int? completedBy;
  final int? completedAt;
  final String? completionNotes;

  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  Gatepass({
    this.id,
    required this.gatepassNumber,
    required this.gatepassTypeId,
    this.referenceType,
    this.referenceId,
    this.partyId,
    this.status = 'DRAFT',
    this.priority = 'NORMAL',
    this.vehicleId,
    this.vehicleNumber,
    this.vehicleType,
    this.driverName,
    this.driverPhone,
    this.driverLicense,
    this.driverPhotoPath,
    this.requestedDate,
    this.approvedDate,
    this.validFrom,
    this.validTo,
    this.actualEntryTime,
    this.actualExitTime,
    this.entryGateId,
    this.exitGateId,
    this.originLocation,
    this.destinationLocation,
    this.securityOfficerId,
    this.securityCheckStatus,
    this.securityNotes,
    this.sealNumber,
    this.sealIntact = 1,
    this.qrCodeData,
    this.qrCodeImagePath,
    this.qrGeneratedAt,
    this.totalItems = 0,
    this.totalQuantity = 0,
    this.totalWeight = 0,
    this.totalPackages = 0,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationMethod,
    this.discrepancyNotes,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.completedBy,
    this.completedAt,
    this.completionNotes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Gatepass.fromJson(Map<String, dynamic> json) =>
      _$GatepassFromJson(json);
  Map<String, dynamic> toJson() => _$GatepassToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GatepassItem {
  final int? id;
  final int gatepassId;
  final int? itemId;
  final String? description;
  final String? hsnCode;
  final double quantity;
  final String? unit;
  final double? weightPerUnit;
  final double? totalWeight;
  final int packages;
  final String? packageType; // BOX, PALLET, CRATE, DRUM, BAG, LOOSE
  final int temperatureRequired;
  final double? minTemp;
  final double? maxTemp;
  final String? batchNumber;
  final int? expiryDate;
  final double verifiedQuantity;
  final double verifiedWeight;
  final int verifiedPackages;
  final String verificationStatus; // PENDING, VERIFIED, SHORT, EXCESS, DAMAGED
  final String? verificationNotes;

  GatepassItem({
    this.id,
    required this.gatepassId,
    this.itemId,
    this.description,
    this.hsnCode,
    required this.quantity,
    this.unit,
    this.weightPerUnit,
    this.totalWeight,
    this.packages = 1,
    this.packageType,
    this.temperatureRequired = 0,
    this.minTemp,
    this.maxTemp,
    this.batchNumber,
    this.expiryDate,
    this.verifiedQuantity = 0,
    this.verifiedWeight = 0,
    this.verifiedPackages = 0,
    this.verificationStatus = 'PENDING',
    this.verificationNotes,
  });

  factory GatepassItem.fromJson(Map<String, dynamic> json) =>
      _$GatepassItemFromJson(json);
  Map<String, dynamic> toJson() => _$GatepassItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SecurityGate {
  final int? id;
  final String code;
  final String name;
  final String? gateType; // ENTRY, EXIT, BOTH
  final String? locationDescription;
  final double? latitude;
  final double? longitude;
  final int? cameraId;
  final String? barrierType; // MANUAL, AUTOMATIC, BOOM, TURNSTILE
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  SecurityGate({
    this.id,
    required this.code,
    required this.name,
    this.gateType,
    this.locationDescription,
    this.latitude,
    this.longitude,
    this.cameraId,
    this.barrierType,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory SecurityGate.fromJson(Map<String, dynamic> json) =>
      _$SecurityGateFromJson(json);
  Map<String, dynamic> toJson() => _$SecurityGateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GatepassVehicleLog {
  final int? id;
  final int gatepassId;
  final int gateId;
  final String logType; // ENTRY, EXIT
  final String? vehicleNumber;
  final String? driverName;
  final int driverVerified;
  final String? sealNumber;
  final int sealVerified;
  final int sealIntact;
  final String? photos; // JSON array
  final int? officerId;
  final int timestamp;
  final String? notes;

  GatepassVehicleLog({
    this.id,
    required this.gatepassId,
    required this.gateId,
    required this.logType,
    this.vehicleNumber,
    this.driverName,
    this.driverVerified = 0,
    this.sealNumber,
    this.sealVerified = 0,
    this.sealIntact = 1,
    this.photos,
    this.officerId,
    required this.timestamp,
    this.notes,
  });

  factory GatepassVehicleLog.fromJson(Map<String, dynamic> json) =>
      _$GatepassVehicleLogFromJson(json);
  Map<String, dynamic> toJson() => _$GatepassVehicleLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GatepassApproval {
  final int? id;
  final int gatepassId;
  final int level;
  final String? approverRole;
  final int? approverId;
  final String status; // PENDING, APPROVED, REJECTED, DELEGATED
  final int? actionAt;
  final String? comments;
  final int? delegatedTo;

  GatepassApproval({
    this.id,
    required this.gatepassId,
    required this.level,
    this.approverRole,
    this.approverId,
    this.status = 'PENDING',
    this.actionAt,
    this.comments,
    this.delegatedTo,
  });

  factory GatepassApproval.fromJson(Map<String, dynamic> json) =>
      _$GatepassApprovalFromJson(json);
  Map<String, dynamic> toJson() => _$GatepassApprovalToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DispatchSchedule {
  final int? id;
  final String scheduleNumber;
  final int scheduleDate;
  final String? shift; // MORNING, AFTERNOON, NIGHT
  final int? gatepassId;
  final int? shipmentId;
  final int? vehicleId;
  final int? driverId;
  final int? loadingBayId;
  final int? scheduledStart;
  final int? scheduledEnd;
  final int? actualStart;
  final int? actualEnd;
  final String status; // SCHEDULED, IN_PROGRESS, COMPLETED, DELAYED, CANCELLED
  final int priority;
  final int? assignedBy;
  final int? createdAt;
  final int? updatedAt;

  DispatchSchedule({
    this.id,
    required this.scheduleNumber,
    required this.scheduleDate,
    this.shift,
    this.gatepassId,
    this.shipmentId,
    this.vehicleId,
    this.driverId,
    this.loadingBayId,
    this.scheduledStart,
    this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.status = 'SCHEDULED',
    this.priority = 0,
    this.assignedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory DispatchSchedule.fromJson(Map<String, dynamic> json) =>
      _$DispatchScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$DispatchScheduleToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LoadingBay {
  final int? id;
  final String code;
  final String name;
  final String? bayType; // LOADING, UNLOADING, BOTH
  final int dockLevel;
  final double? maxVehicleLength;
  final double? maxVehicleWeight;
  final int temperatureControlled;
  final double? minTemp;
  final double? maxTemp;
  final int? cameraId;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  LoadingBay({
    this.id,
    required this.code,
    required this.name,
    this.bayType,
    this.dockLevel = 0,
    this.maxVehicleLength,
    this.maxVehicleWeight,
    this.temperatureControlled = 0,
    this.minTemp,
    this.maxTemp,
    this.cameraId,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory LoadingBay.fromJson(Map<String, dynamic> json) =>
      _$LoadingBayFromJson(json);
  Map<String, dynamic> toJson() => _$LoadingBayToJson(this);
}

// ============================================
// Barcode/QR Code Models
// ============================================

@JsonSerializable(fieldRename: FieldRename.snake)
class BarcodeDefinition {
  final int? id;
  final String code;
  final String name;
  final String symbology; // CODE128, QR_CODE, DATA_MATRIX, EAN13, UPCA, CODE39
  final String? prefix;
  final String? suffix;
  final String? formatTemplate;
  final double? widthMm;
  final double? heightMm;
  final double? moduleWidth;
  final int includeText;
  final int? fontSize;
  final String? errorCorrection; // L, M, Q, H
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  BarcodeDefinition({
    this.id,
    required this.code,
    required this.name,
    required this.symbology,
    this.prefix,
    this.suffix,
    this.formatTemplate,
    this.widthMm,
    this.heightMm,
    this.moduleWidth,
    this.includeText = 1,
    this.fontSize,
    this.errorCorrection,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory BarcodeDefinition.fromJson(Map<String, dynamic> json) =>
      _$BarcodeDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$BarcodeDefinitionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Barcode {
  final int? id;
  final String barcodeValue;
  final int barcodeTypeId;
  final String
      entityType; // ITEM, GATEPASS, SHIPMENT, LOCATION, PALLET, BATCH, VEHICLE
  final int entityId;
  final String? labelData; // JSON
  final String? imagePath;
  final int printCount;
  final int? lastPrintedAt;
  final int? printedBy;
  final String status; // ACTIVE, VOIDED, REPLACED
  final int? expiresAt;
  final int? createdAt;
  final int? updatedAt;

  Barcode({
    this.id,
    required this.barcodeValue,
    required this.barcodeTypeId,
    required this.entityType,
    required this.entityId,
    this.labelData,
    this.imagePath,
    this.printCount = 0,
    this.lastPrintedAt,
    this.printedBy,
    this.status = 'ACTIVE',
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Barcode.fromJson(Map<String, dynamic> json) =>
      _$BarcodeFromJson(json);
  Map<String, dynamic> toJson() => _$BarcodeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BarcodeScan {
  final int? id;
  final int? scanSessionId;
  final String barcodeValue;
  final int? barcodeId;
  final String? entityType;
  final int? entityId;
  final String?
      scanType; // RECEIVING, PICKING, PACKING, DISPATCH, TRANSFER, CYCLE_COUNT, GATEPASS_VERIFY
  final int? locationId;
  final int? scannedBy;
  final String? deviceId;
  final double? latitude;
  final double? longitude;
  final double quantity;
  final String? unit;
  final String status; // SUCCESS, FAILED, DUPLICATE, NOT_FOUND, MISMATCH
  final String? errorMessage;
  final int timestamp;
  final int? createdAt;

  BarcodeScan({
    this.id,
    this.scanSessionId,
    required this.barcodeValue,
    this.barcodeId,
    this.entityType,
    this.entityId,
    this.scanType,
    this.locationId,
    this.scannedBy,
    this.deviceId,
    this.latitude,
    this.longitude,
    this.quantity = 1,
    this.unit,
    this.status = 'SUCCESS',
    this.errorMessage,
    required this.timestamp,
    this.createdAt,
  });

  factory BarcodeScan.fromJson(Map<String, dynamic> json) =>
      _$BarcodeScanFromJson(json);
  Map<String, dynamic> toJson() => _$BarcodeScanToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BatchScanSession {
  final int? id;
  final String sessionNumber;
  final String?
      sessionType; // RECEIVING, DISPATCH, TRANSFER, INVENTORY, GATEPASS
  final String? referenceType;
  final int? referenceId;
  final int? locationId;
  final int? operatorId;
  final String status; // IN_PROGRESS, COMPLETED, CANCELLED
  final int totalExpected;
  final int totalScanned;
  final int totalMatched;
  final int totalMismatched;
  final int? startedAt;
  final int? completedAt;
  final String? notes;
  final int? createdAt;
  final int? updatedAt;

  BatchScanSession({
    this.id,
    required this.sessionNumber,
    this.sessionType,
    this.referenceType,
    this.referenceId,
    this.locationId,
    this.operatorId,
    this.status = 'IN_PROGRESS',
    this.totalExpected = 0,
    this.totalScanned = 0,
    this.totalMatched = 0,
    this.totalMismatched = 0,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory BatchScanSession.fromJson(Map<String, dynamic> json) =>
      _$BatchScanSessionFromJson(json);
  Map<String, dynamic> toJson() => _$BatchScanSessionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BatchScanItem {
  final int? id;
  final int sessionId;
  final String? barcodeValue;
  final int? barcodeId;
  final int? itemId;
  final double expectedQuantity;
  final double scannedQuantity;
  final int matched;
  final String? mismatchReason; // QUANTITY, WRONG_ITEM, DAMAGED, EXPIRED
  final String status; // PENDING, SCANNED, VERIFIED, EXCEPTION
  final int? scannedAt;
  final int? verifiedBy;
  final int? verifiedAt;

  BatchScanItem({
    this.id,
    required this.sessionId,
    this.barcodeValue,
    this.barcodeId,
    this.itemId,
    required this.expectedQuantity,
    this.scannedQuantity = 0,
    this.matched = 0,
    this.mismatchReason,
    this.status = 'PENDING',
    this.scannedAt,
    this.verifiedBy,
    this.verifiedAt,
  });

  factory BatchScanItem.fromJson(Map<String, dynamic> json) =>
      _$BatchScanItemFromJson(json);
  Map<String, dynamic> toJson() => _$BatchScanItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LabelPrintJob {
  final int? id;
  final String jobNumber;
  final int barcodeDefinitionId;
  final String entityType;
  final String? entityIds; // JSON array
  final String? labelDataJson; // JSON array
  final int copies;
  final String? printerName;
  final String? printerType; // ZEBRA, DATAMAX, SATO, BROTHER, GENERIC
  final double? labelWidthMm;
  final double? labelHeightMm;
  final String status; // QUEUED, PRINTING, COMPLETED, FAILED, CANCELLED
  final int printedCount;
  final int failedCount;
  final String? errorLog;
  final int? requestedBy;
  final int? requestedAt;
  final int? startedAt;
  final int? completedAt;

  LabelPrintJob({
    this.id,
    required this.jobNumber,
    required this.barcodeDefinitionId,
    required this.entityType,
    this.entityIds,
    this.labelDataJson,
    this.copies = 1,
    this.printerName,
    this.printerType,
    this.labelWidthMm,
    this.labelHeightMm,
    this.status = 'QUEUED',
    this.printedCount = 0,
    this.failedCount = 0,
    this.errorLog,
    this.requestedBy,
    this.requestedAt,
    this.startedAt,
    this.completedAt,
  });

  factory LabelPrintJob.fromJson(Map<String, dynamic> json) =>
      _$LabelPrintJobFromJson(json);
  Map<String, dynamic> toJson() => _$LabelPrintJobToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PrinterConfig {
  final int? id;
  final String name;
  final String?
      printerType; // ZEBRA_ZPL, DATAMAX_DPL, SATO_SBPL, EPSON_ESCPOS, GENERIC
  final String? connectionType; // USB, NETWORK, BLUETOOTH, SERIAL
  final String? ipAddress;
  final int? port;
  final String? usbVidPid;
  final String? bluetoothMac;
  final String? serialPort;
  final int? baudRate;
  final double? paperWidthMm;
  final double? paperHeightMm;
  final int? printSpeed;
  final int? printDensity;
  final int isDefault;
  final int isActive;
  final String? testPrintCommand;
  final int? createdAt;
  final int? updatedAt;

  PrinterConfig({
    this.id,
    required this.name,
    this.printerType,
    this.connectionType,
    this.ipAddress,
    this.port,
    this.usbVidPid,
    this.bluetoothMac,
    this.serialPort,
    this.baudRate,
    this.paperWidthMm,
    this.paperHeightMm,
    this.printSpeed,
    this.printDensity,
    this.isDefault = 0,
    this.isActive = 1,
    this.testPrintCommand,
    this.createdAt,
    this.updatedAt,
  });

  factory PrinterConfig.fromJson(Map<String, dynamic> json) =>
      _$PrinterConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PrinterConfigToJson(this);
}
