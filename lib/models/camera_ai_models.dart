// lib/models/camera_ai_models.dart

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'device_type': deviceType,
      'location_id': locationId,
      'ip_address': ipAddress,
      'port': port,
      'username': username,
      'password_hash': passwordHash,
      'rtsp_url': rtspUrl,
      'resolution_width': resolutionWidth,
      'resolution_height': resolutionHeight,
      'fps': fps,
      'model_path': modelPath,
      'model_version': modelVersion,
      'confidence_threshold': confidenceThreshold,
      'iou_threshold': iouThreshold,
      'detection_classes': detectionClasses,
      'count_direction': countDirection,
      'roi_coordinates': roiCoordinates,
      'calibration_factor': calibrationFactor,
      'is_active': isActive,
      'last_heartbeat': lastHeartbeat,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CameraDevice.fromMap(Map<String, dynamic> m) {
    return CameraDevice(
      id: m['id'] as int?,
      name: m['name'] as String,
      code: m['code'] as String,
      deviceType: m['device_type'] as String?,
      locationId: m['location_id'] as int?,
      ipAddress: m['ip_address'] as String?,
      port: m['port'] as int?,
      username: m['username'] as String?,
      passwordHash: m['password_hash'] as String?,
      rtspUrl: m['rtsp_url'] as String?,
      resolutionWidth: m['resolution_width'] as int? ?? 1920,
      resolutionHeight: m['resolution_height'] as int? ?? 1080,
      fps: m['fps'] as int? ?? 30,
      modelPath: m['model_path'] as String?,
      modelVersion: m['model_version'] as String?,
      confidenceThreshold: (m['confidence_threshold'] as num?)?.toDouble() ?? 0.5,
      iouThreshold: (m['iou_threshold'] as num?)?.toDouble() ?? 0.45,
      detectionClasses: m['detection_classes'] as String?,
      countDirection: m['count_direction'] as String?,
      roiCoordinates: m['roi_coordinates'] as String?,
      calibrationFactor: (m['calibration_factor'] as num?)?.toDouble() ?? 1.0,
      isActive: m['is_active'] as int? ?? 1,
      lastHeartbeat: m['last_heartbeat'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_number': sessionNumber,
      'camera_id': cameraId,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'session_type': sessionType,
      'status': status,
      'expected_count': expectedCount,
      'ai_count': aiCount,
      'manual_count': manualCount,
      'verified_count': verifiedCount,
      'discrepancy': discrepancy,
      'discrepancy_percent': discrepancyPercent,
      'start_time': startTime,
      'end_time': endTime,
      'duration_seconds': durationSeconds,
      'operator_id': operatorId,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CountingSession.fromMap(Map<String, dynamic> m) {
    return CountingSession(
      id: m['id'] as int?,
      sessionNumber: m['session_number'] as String,
      cameraId: m['camera_id'] as int,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      sessionType: m['session_type'] as String,
      status: m['status'] as String? ?? 'IN_PROGRESS',
      expectedCount: m['expected_count'] as int?,
      aiCount: m['ai_count'] as int? ?? 0,
      manualCount: m['manual_count'] as int?,
      verifiedCount: m['verified_count'] as int?,
      discrepancy: m['discrepancy'] as int? ?? 0,
      discrepancyPercent: (m['discrepancy_percent'] as num?)?.toDouble() ?? 0,
      startTime: m['start_time'] as int?,
      endTime: m['end_time'] as int?,
      durationSeconds: m['duration_seconds'] as int?,
      operatorId: m['operator_id'] as int?,
      verifiedBy: m['verified_by'] as int?,
      verifiedAt: m['verified_at'] as int?,
      notes: m['notes'] as String?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'frame_timestamp': frameTimestamp,
      'track_id': trackId,
      'class_name': className,
      'confidence': confidence,
      'bbox_x': bboxX,
      'bbox_y': bboxY,
      'bbox_width': bboxWidth,
      'bbox_height': bboxHeight,
      'centroid_x': centroidX,
      'centroid_y': centroidY,
      'direction': direction,
      'counted': counted,
      'count_timestamp': countTimestamp,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory DetectionEvent.fromMap(Map<String, dynamic> m) {
    return DetectionEvent(
      id: m['id'] as int?,
      sessionId: m['session_id'] as int,
      frameTimestamp: m['frame_timestamp'] as int,
      trackId: m['track_id'] as int?,
      className: m['class_name'] as String?,
      confidence: (m['confidence'] as num?)?.toDouble(),
      bboxX: (m['bbox_x'] as num?)?.toDouble(),
      bboxY: (m['bbox_y'] as num?)?.toDouble(),
      bboxWidth: (m['bbox_width'] as num?)?.toDouble(),
      bboxHeight: (m['bbox_height'] as num?)?.toDouble(),
      centroidX: (m['centroid_x'] as num?)?.toDouble(),
      centroidY: (m['centroid_y'] as num?)?.toDouble(),
      direction: m['direction'] as String?,
      counted: m['counted'] as int? ?? 0,
      countTimestamp: m['count_timestamp'] as int?,
      imagePath: m['image_path'] as String?,
      createdAt: m['created_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'verification_type': verificationType,
      'verifier_id': verifierId,
      'original_count': originalCount,
      'verified_count': verifiedCount,
      'variance': variance,
      'variance_percent': variancePercent,
      'status': status,
      'verification_notes': verificationNotes,
      'evidence_images': evidenceImages,
      'started_at': startedAt,
      'completed_at': completedAt,
      'created_at': createdAt,
    };
  }

  factory CountVerification.fromMap(Map<String, dynamic> m) {
    return CountVerification(
      id: m['id'] as int?,
      sessionId: m['session_id'] as int,
      verificationType: m['verification_type'] as String?,
      verifierId: m['verifier_id'] as int,
      originalCount: m['original_count'] as int,
      verifiedCount: m['verified_count'] as int,
      variance: m['variance'] as int,
      variancePercent: (m['variance_percent'] as num?)?.toDouble() ?? 0,
      status: m['status'] as String? ?? 'PENDING',
      verificationNotes: m['verification_notes'] as String?,
      evidenceImages: m['evidence_images'] as String?,
      startedAt: m['started_at'] as int?,
      completedAt: m['completed_at'] as int?,
      createdAt: m['created_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'camera_id': cameraId,
      'calibration_type': calibrationType,
      'reference_object': referenceObject,
      'reference_size': referenceSize,
      'pixel_measurement': pixelMeasurement,
      'calibration_factor': calibrationFactor,
      'accuracy_percent': accuracyPercent,
      'calibrated_by': calibratedBy,
      'calibrated_at': calibratedAt,
      'is_active': isActive,
      'notes': notes,
    };
  }

  factory CameraCalibration.fromMap(Map<String, dynamic> m) {
    return CameraCalibration(
      id: m['id'] as int?,
      cameraId: m['camera_id'] as int,
      calibrationType: m['calibration_type'] as String?,
      referenceObject: m['reference_object'] as String?,
      referenceSize: (m['reference_size'] as num?)?.toDouble(),
      pixelMeasurement: (m['pixel_measurement'] as num?)?.toDouble(),
      calibrationFactor: (m['calibration_factor'] as num?)?.toDouble(),
      accuracyPercent: (m['accuracy_percent'] as num?)?.toDouble(),
      calibratedBy: m['calibrated_by'] as int?,
      calibratedAt: m['calibrated_at'] as int?,
      isActive: m['is_active'] as int? ?? 1,
      notes: m['notes'] as String?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'model_type': modelType,
      'framework': framework,
      'input_width': inputWidth,
      'input_height': inputHeight,
      'input_channels': inputChannels,
      'classes': classes,
      'model_file_path': modelFilePath,
      'label_file_path': labelFilePath,
      'metrics_json': metricsJson,
      'training_data_info': trainingDataInfo,
      'is_active': isActive,
      'deployed_at': deployedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MLModel.fromMap(Map<String, dynamic> m) {
    return MLModel(
      id: m['id'] as int?,
      name: m['name'] as String,
      version: m['version'] as String,
      modelType: m['model_type'] as String?,
      framework: m['framework'] as String?,
      inputWidth: m['input_width'] as int?,
      inputHeight: m['input_height'] as int?,
      inputChannels: m['input_channels'] as int? ?? 3,
      classes: m['classes'] as String?,
      modelFilePath: m['model_file_path'] as String?,
      labelFilePath: m['label_file_path'] as String?,
      metricsJson: m['metrics_json'] as String?,
      trainingDataInfo: m['training_data_info'] as String?,
      isActive: m['is_active'] as int? ?? 1,
      deployedAt: m['deployed_at'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'camera_id': cameraId,
      'alert_type': alertType,
      'severity': severity,
      'message': message,
      'session_id': sessionId,
      'detection_event_id': detectionEventId,
      'acknowledged': acknowledged,
      'acknowledged_by': acknowledgedBy,
      'acknowledged_at': acknowledgedAt,
      'resolved': resolved,
      'resolved_by': resolvedBy,
      'resolved_at': resolvedAt,
      'created_at': createdAt,
    };
  }

  factory CameraAlert.fromMap(Map<String, dynamic> m) {
    return CameraAlert(
      id: m['id'] as int?,
      cameraId: m['camera_id'] as int,
      alertType: m['alert_type'] as String?,
      severity: m['severity'] as String?,
      message: m['message'] as String?,
      sessionId: m['session_id'] as int?,
      detectionEventId: m['detection_event_id'] as int?,
      acknowledged: m['acknowledged'] as int? ?? 0,
      acknowledgedBy: m['acknowledged_by'] as int?,
      acknowledgedAt: m['acknowledged_at'] as int?,
      resolved: m['resolved'] as int? ?? 0,
      resolvedBy: m['resolved_by'] as int?,
      resolvedAt: m['resolved_at'] as int?,
      createdAt: m['created_at'] as int?,
    );
  }
}