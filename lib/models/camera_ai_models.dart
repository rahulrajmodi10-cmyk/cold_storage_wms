// lib/models/camera_ai_models.dart

import 'package:json_annotation/json_annotation.dart';

part 'camera_ai_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CameraDevice {
  final int? id;
  final String name;
  final String code;
  final String? deviceType; // FIXED, MOBILE, HANDHELD, DRONE
  final int? locationId;
  final String? ipAddress;
  final int? port;
  final String? username;
  final String? passwordHash;
  final String? rtspUrl;
  final int resolutionWidth;
  final int resolutionHeight;
  final int fps;
  final String? modelPath;
  final String? modelVersion;
  final double confidenceThreshold;
  final double iouThreshold;
  final String? detectionClasses; // JSON array
  final String? countDirection; // IN, OUT, BOTH
  final String? roiCoordinates; // JSON polygon
  final double calibrationFactor;
  final int isActive;
  final int? lastHeartbeat;
  final int? createdAt;
  final int? updatedAt;

  CameraDevice({
    this.id,
    required this.name,
    required this.code,
    this.deviceType,
    this.locationId,
    this.ipAddress,
    this.port,
    this.username,
    this.passwordHash,
    this.rtspUrl,
    this.resolutionWidth = 1920,
    this.resolutionHeight = 1080,
    this.fps = 30,
    this.modelPath,
    this.modelVersion,
    this.confidenceThreshold = 0.5,
    this.iouThreshold = 0.45,
    this.detectionClasses,
    this.countDirection,
    this.roiCoordinates,
    this.calibrationFactor = 1.0,
    this.isActive = 1,
    this.lastHeartbeat,
    this.createdAt,
    this.updatedAt,
  });

  factory CameraDevice.fromJson(Map<String, dynamic> json) => _$CameraDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$CameraDeviceToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CountingSession {
  final int? id;
  final String sessionNumber;
  final int cameraId;
  final String? referenceType; // GATEPASS, SHIPMENT, RECEIVING, INVENTORY_CHECK
  final int? referenceId;
  final String sessionType; // LOADING, UNLOADING, TRANSFER, CYCLE_COUNT
  final String status; // IN_PROGRESS, COMPLETED, VERIFIED, DISPUTED, CANCELLED
  final int? expectedCount;
  final int aiCount;
  final int? manualCount;
  final int? verifiedCount;
  final int discrepancy;
  final double discrepancyPercent;
  final int? startTime;
  final int? endTime;
  final int? durationSeconds;
  final int? operatorId;
  final int? verifiedBy;
  final int? verifiedAt;
  final String? notes;
  final int? createdAt;
  final int? updatedAt;

  CountingSession({
    this.id,
    required this.sessionNumber,
    required this.cameraId,
    this.referenceType,
    this.referenceId,
    required this.sessionType,
    this.status = 'IN_PROGRESS',
    this.expectedCount,
    this.aiCount = 0,
    this.manualCount,
    this.verifiedCount,
    this.discrepancy = 0,
    this.discrepancyPercent = 0,
    this.startTime,
    this.endTime,
    this.durationSeconds,
    this.operatorId,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory CountingSession.fromJson(Map<String, dynamic> json) => _$CountingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$CountingSessionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DetectionEvent {
  final int? id;
  final int sessionId;
  final int frameTimestamp;
  final int? trackId;
  final String? className;
  final double? confidence;
  final double? bboxX;
  final double? bboxY;
  final double? bboxWidth;
  final double? bboxHeight;
  final double? centroidX;
  final double? centroidY;
  final String? direction; // IN, OUT, UNKNOWN
  final int counted;
  final int? countTimestamp;
  final String? imagePath;
  final int? createdAt;

  DetectionEvent({
    this.id,
    required this.sessionId,
    required this.frameTimestamp,
    this.trackId,
    this.className,
    this.confidence,
    this.bboxX,
    this.bboxY,
    this.bboxWidth,
    this.bboxHeight,
    this.centroidX,
    this.centroidY,
    this.direction,
    this.counted = 0,
    this.countTimestamp,
    this.imagePath,
    this.createdAt,
  });

  factory DetectionEvent.fromJson(Map<String, dynamic> json) => _$DetectionEventFromJson(json);
  Map<String, dynamic> toJson() => _$DetectionEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CountVerification {
  final int? id;
  final int sessionId;
  final String? verificationType; // MANUAL_RECOUNT, SUPERVISOR_APPROVAL, WEIGHT_BASED, BARCODE_MATCH
  final int verifierId;
  final int originalCount;
  final int verifiedCount;
  final int variance;
  final double variancePercent;
  final String status; // PENDING, APPROVED, REJECTED, NEEDS_RECOUNT
  final String? verificationNotes;
  final String? evidenceImages; // JSON array
  final int? startedAt;
  final int? completedAt;
  final int? createdAt;

  CountVerification({
    this.id,
    required this.sessionId,
    this.verificationType,
    required this.verifierId,
    required this.originalCount,
    required this.verifiedCount,
    required this.variance,
    required this.variancePercent,
    this.status = 'PENDING',
    this.verificationNotes,
    this.evidenceImages,
    this.startedAt,
    this.completedAt,
    this.createdAt,
  });

  factory CountVerification.fromJson(Map<String, dynamic> json) => _$CountVerificationFromJson(json);
  Map<String, dynamic> toJson() => _$CountVerificationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CameraCalibration {
  final int? id;
  final int cameraId;
  final String? calibrationType; // DISTANCE, COUNT_LINE, ROI, LENS
  final String? referenceObject;
  final double? referenceSize;
  final double? pixelMeasurement;
  final double? calibrationFactor;
  final double? accuracyPercent;
  final int? calibratedBy;
  final int? calibratedAt;
  final int isActive;
  final String? notes;

  CameraCalibration({
    this.id,
    required this.cameraId,
    this.calibrationType,
    this.referenceObject,
    this.referenceSize,
    this.pixelMeasurement,
    this.calibrationFactor,
    this.accuracyPercent,
    this.calibratedBy,
    this.calibratedAt,
    this.isActive = 1,
    this.notes,
  });

  factory CameraCalibration.fromJson(Map<String, dynamic> json) => _$CameraCalibrationFromJson(json);
  Map<String, dynamic> toJson() => _$CameraCalibrationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MLModel {
  final int? id;
  final String name;
  final String version;
  final String? modelType; // YOLO, SSD, EFFICIENTDET, CUSTOM
  final String? framework; // TFLITE, ONNX, PYTORCH
  final int? inputWidth;
  final int? inputHeight;
  final int inputChannels;
  final String? classes; // JSON array
  final String? modelFilePath;
  final String? labelFilePath;
  final String? metricsJson;
  final String? trainingDataInfo;
  final int isActive;
  final int? deployedAt;
  final int? createdAt;
  final int? updatedAt;

  MLModel({
    this.id,
    required this.name,
    required this.version,
    this.modelType,
    this.framework,
    this.inputWidth,
    this.inputHeight,
    this.inputChannels = 3,
    this.classes,
    this.modelFilePath,
    this.labelFilePath,
    this.metricsJson,
    this.trainingDataInfo,
    this.isActive = 1,
    this.deployedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory MLModel.fromJson(Map<String, dynamic> json) => _$MLModelFromJson(json);
  Map<String, dynamic> toJson() => _$MLModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CameraAlert {
  final int? id;
  final int cameraId;
  final String? alertType; // DISCREPANCY, CAMERA_OFFLINE, LOW_CONFIDENCE, OBSTRUCTION, TAMPERING
  final String? severity; // LOW, MEDIUM, HIGH, CRITICAL
  final String? message;
  final int? sessionId;
  final int? detectionEventId;
  final int acknowledged;
  final int? acknowledgedBy;
  final int? acknowledgedAt;
  final int resolved;
  final int? resolvedBy;
  final int? resolvedAt;
  final int? createdAt;

  CameraAlert({
    this.id,
    required this.cameraId,
    this.alertType,
    this.severity,
    this.message,
    this.sessionId,
    this.detectionEventId,
    this.acknowledged = 0,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.resolved = 0,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
  });

  factory CameraAlert.fromJson(Map<String, dynamic> json) => _$CameraAlertFromJson(json);
  Map<String, dynamic> toJson() => _$CameraAlertToJson(this);
}