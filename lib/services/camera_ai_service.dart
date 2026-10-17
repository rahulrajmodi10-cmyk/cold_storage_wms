// lib/services/camera_ai_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import '../models/camera_ai_models.dart';
import 'audit_service.dart';

class CameraAIService {
  final Database db;
  final AuditService auditService;

  CameraAIService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  // ============ Camera Devices ============

  Future<int> createCamera(CameraDevice camera, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = camera.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('camera_devices', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_camera',
        detail: 'Created camera ${camera.code} - ${camera.name}',
        entityType: 'camera_devices',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<CameraDevice?> getCamera(int id) async {
    final maps = await db.query('camera_devices', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CameraDevice.fromMap(maps.first);
  }

  Future<List<CameraDevice>> getCameras({bool activeOnly = true, int? locationId}) async {
    return _getCameras(activeOnly: activeOnly, locationId: locationId);
  }

  Future<List<CameraDevice>> _getCameras({bool activeOnly = true, int? locationId}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (activeOnly) {
      where.add('is_active = 1');
    }
    if (locationId != null) {
      where.add('location_id = ?');
      args.add(locationId);
    }
    final maps = await db.query('camera_devices', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'name');
    return maps.map((m) => CameraDevice.fromMap(m)).toList();
  }

  Future<int> updateCamera(CameraDevice camera, {int? userId}) async {
    final map = camera.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('camera_devices', map, where: 'id = ?', whereArgs: [camera.id]);
      if (count == 0) throw StateError('Camera not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_camera',
        detail: 'Updated camera ${camera.code}',
        entityType: 'camera_devices',
        entityId: camera.id,
        userId: userId,
      );
    });
    return camera.id!;
  }

  Future<int> updateCameraHeartbeat(int cameraId, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('camera_devices', {
        'last_heartbeat': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [cameraId]);
      if (count == 0) throw StateError('Camera not found');
      await auditService.logInTransaction(
        txn,
        action: 'camera_heartbeat',
        detail: 'Camera heartbeat updated',
        entityType: 'camera_devices',
        entityId: cameraId,
        userId: userId,
      );
    });
    return cameraId;
  }

  // ============ Counting Sessions ============

  Future<int> createCountingSession(CountingSession session, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = session.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('counting_sessions', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_counting_session',
        detail: 'Created counting session ${session.sessionNumber}',
        entityType: 'counting_sessions',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<CountingSession?> getCountingSession(int id) async {
    final maps = await db.query('counting_sessions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CountingSession.fromMap(maps.first);
  }

  Future<CountingSession?> getCountingSessionByNumber(String sessionNumber) async {
    final maps = await db.query('counting_sessions', where: 'session_number = ?', whereArgs: [sessionNumber]);
    if (maps.isEmpty) return null;
    return CountingSession.fromMap(maps.first);
  }

  Future<List<CountingSession>> getCountingSessions({
    int? cameraId,
    String? referenceType,
    int? referenceId,
    String? status,
    int? fromDate,
    int? toDate,
  }) async {
    return _getCountingSessions(
      cameraId: cameraId,
      referenceType: referenceType,
      referenceId: referenceId,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<List<CountingSession>> _getCountingSessions({
    int? cameraId,
    String? referenceType,
    int? referenceId,
    String? status,
    int? fromDate,
    int? toDate,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (cameraId != null) {
      where.add('camera_id = ?');
      args.add(cameraId);
    }
    if (referenceType != null) {
      where.add('reference_type = ?');
      args.add(referenceType);
    }
    if (referenceId != null) {
      where.add('reference_id = ?');
      args.add(referenceId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (fromDate != null) {
      where.add('start_time >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('start_time <= ?');
      args.add(toDate);
    }
    final maps = await db.query('counting_sessions', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'start_time DESC');
    return maps.map((m) => CountingSession.fromMap(m)).toList();
  }

  Future<int> updateCountingSession(CountingSession session, {int? userId}) async {
    final map = session.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('counting_sessions', map, where: 'id = ?', whereArgs: [session.id]);
      if (count == 0) throw StateError('Counting session not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_counting_session',
        detail: 'Updated counting session ${session.sessionNumber}',
        entityType: 'counting_sessions',
        entityId: session.id,
        userId: userId,
      );
    });
    return session.id!;
  }

  Future<int> completeCountingSession(int sessionId, {int? manualCount, int? verifiedCount, int? verifiedBy, String? notes, int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final session = await getCountingSession(sessionId);
    if (session == null) return 0;

    final endTime = now;
    final durationSeconds = session.startTime != null ? ((endTime - session.startTime!) / 1000).round() : null;

    int discrepancy = 0;
    double discrepancyPercent = 0.0;

    if (verifiedCount != null) {
      discrepancy = verifiedCount - session.aiCount;
      discrepancyPercent = session.aiCount > 0 ? (discrepancy / session.aiCount * 100) : 0;
    } else if (manualCount != null) {
      discrepancy = manualCount - session.aiCount;
      discrepancyPercent = session.aiCount > 0 ? (discrepancy / session.aiCount * 100) : 0;
    }

    final map = {
      'status': 'COMPLETED',
      'end_time': endTime,
      'duration_seconds': durationSeconds,
      'manual_count': manualCount,
      'verified_count': verifiedCount ?? session.verifiedCount,
      'discrepancy': discrepancy,
      'discrepancy_percent': discrepancyPercent,
      'verified_by': verifiedBy,
      'verified_at': verifiedBy != null ? now : session.verifiedAt,
      'notes': notes ?? session.notes,
      'updated_at': now,
    };

    await db.transaction((txn) async {
      final count = await txn.update('counting_sessions', map, where: 'id = ?', whereArgs: [sessionId]);
      if (count == 0) throw StateError('Counting session not found');
      await auditService.logInTransaction(
        txn,
        action: 'complete_counting_session',
        detail: 'Completed counting session ${session.sessionNumber} (discrepancy: $discrepancy)',
        entityType: 'counting_sessions',
        entityId: sessionId,
        userId: userId ?? verifiedBy,
      );
    });
    return sessionId;
  }

  // ============ Detection Events ============

  Future<int> addDetectionEvent(DetectionEvent event, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('detection_events', event.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_detection_event',
        detail: 'Added detection event for session ${event.sessionId}',
        entityType: 'detection_events',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> addDetectionEventsBatch(List<DetectionEvent> events, {int? userId}) async {
    if (events.isEmpty) return 0;
    await db.transaction((txn) async {
      for (final event in events) {
        await txn.insert('detection_events', event.toMap());
      }
      await auditService.logInTransaction(
        txn,
        action: 'add_detection_events_batch',
        detail: 'Added ${events.length} detection events',
        entityType: 'detection_events',
        entityId: events.first.sessionId,
        userId: userId,
      );
    });
    return events.length;
  }

  Future<List<DetectionEvent>> getDetectionEvents(int sessionId) async {
    final maps = await db.query('detection_events', where: 'session_id = ?', whereArgs: [sessionId], orderBy: 'frame_timestamp');
    return maps.map((m) => DetectionEvent.fromMap(m)).toList();
  }

  Future<int> updateDetectionEventCounted(int eventId, int countTimestamp, String direction, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('detection_events', {
        'counted': 1,
        'count_timestamp': countTimestamp,
        'direction': direction,
      }, where: 'id = ?', whereArgs: [eventId]);
      if (count == 0) throw StateError('Detection event not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_detection_event_counted',
        detail: 'Marked detection event as counted ($direction)',
        entityType: 'detection_events',
        entityId: eventId,
        userId: userId,
      );
    });
    return eventId;
  }

  Future<Map<String, dynamic>> getSessionStats(int sessionId) async {
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_detections,
        SUM(CASE WHEN counted = 1 THEN 1 ELSE 0 END) as counted_detections,
        SUM(CASE WHEN direction = 'IN' AND counted = 1 THEN 1 ELSE 0 END) as in_count,
        SUM(CASE WHEN direction = 'OUT' AND counted = 1 THEN 1 ELSE 0 END) as out_count,
        AVG(confidence) as avg_confidence,
        MIN(confidence) as min_confidence,
        MAX(confidence) as max_confidence
      FROM detection_events
      WHERE session_id = ?
    ''', [sessionId]);
    return result.isNotEmpty ? result.first : {};
  }

  // ============ Count Verification ============

  Future<int> createVerification(CountVerification verification, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = verification.toMap();
    map['created_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('count_verifications', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_verification',
        detail: 'Created verification for session ${verification.sessionId}',
        entityType: 'count_verifications',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<CountVerification>> getVerifications(int sessionId) async {
    final maps = await db.query('count_verifications', where: 'session_id = ?', whereArgs: [sessionId]);
    return maps.map((m) => CountVerification.fromMap(m)).toList();
  }

  Future<int> updateVerificationStatus(int verificationId, String status, {String? notes, String? evidenceImages, int? userId}) async {
    final Map<String, dynamic> map = {'status': status};
    if (notes != null) map['verification_notes'] = notes;
    if (evidenceImages != null) map['evidence_images'] = evidenceImages;
    if (status == 'APPROVED' || status == 'REJECTED') {
      map['completed_at'] = DateTime.now().millisecondsSinceEpoch;
    }
    await db.transaction((txn) async {
      final count = await txn.update('count_verifications', map, where: 'id = ?', whereArgs: [verificationId]);
      if (count == 0) throw StateError('Verification not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_verification_status',
        detail: 'Verification status changed to $status',
        entityType: 'count_verifications',
        entityId: verificationId,
        userId: userId,
      );
    });
    return verificationId;
  }

  // ============ Camera Calibration ============

  Future<int> createCalibration(CameraCalibration calibration, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = calibration.toMap();
    map['calibrated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('camera_calibrations', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_calibration',
        detail: 'Created calibration for camera ${calibration.cameraId} (${calibration.calibrationType})',
        entityType: 'camera_calibrations',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<CameraCalibration>> getCalibrations(int cameraId, {bool activeOnly = true}) async {
    final where = <String>['camera_id = ?'];
    final args = <dynamic>[cameraId];
    if (activeOnly) where.add('is_active = 1');
    final maps = await db.query('camera_calibrations', where: where.join(' AND '), whereArgs: args, orderBy: 'calibrated_at DESC');
    return maps.map((m) => CameraCalibration.fromMap(m)).toList();
  }

  Future<CameraCalibration?> getActiveCalibration(int cameraId, String type) async {
    final maps = await db.query(
      'camera_calibrations',
      where: 'camera_id = ? AND calibration_type = ? AND is_active = 1',
      whereArgs: [cameraId, type],
      orderBy: 'calibrated_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CameraCalibration.fromMap(maps.first);
  }

  // ============ ML Models ============

  Future<int> createMLModel(MLModel model, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = model.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('ml_models', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_ml_model',
        detail: 'Created ML model ${model.name} v${model.version}',
        entityType: 'ml_models',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<MLModel?> getActiveMLModel() async {
    final maps = await db.query('ml_models', where: 'is_active = 1', orderBy: 'deployed_at DESC', limit: 1);
    if (maps.isEmpty) return null;
    return MLModel.fromMap(maps.first);
  }

  Future<List<MLModel>> getMLModels() async {
    final maps = await db.query('ml_models', orderBy: 'name, version');
    return maps.map((m) => MLModel.fromMap(m)).toList();
  }

  Future<int> deployMLModel(int modelId, {int? userId}) async {
    await db.transaction((txn) async {
      await txn.update('ml_models', {'is_active': 0});
      final count = await txn.update('ml_models', {
        'is_active': 1,
        'deployed_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [modelId]);
      if (count == 0) throw StateError('ML model not found');
      await auditService.logInTransaction(
        txn,
        action: 'deploy_ml_model',
        detail: 'Deployed ML model $modelId',
        entityType: 'ml_models',
        entityId: modelId,
        userId: userId,
      );
    });
    return modelId;
  }

  // ============ Camera Alerts ============

  Future<int> createAlert(CameraAlert alert, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = alert.toMap();
    map['created_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('camera_alerts', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_camera_alert',
        detail: 'Created alert ${alert.alertType} for camera ${alert.cameraId}',
        entityType: 'camera_alerts',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<CameraAlert>> getAlerts({
    int? cameraId,
    String? severity,
    int? acknowledged,
    int? resolved,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (cameraId != null) {
      where.add('camera_id = ?');
      args.add(cameraId);
    }
    if (severity != null) {
      where.add('severity = ?');
      args.add(severity);
    }
    if (acknowledged != null) {
      where.add('acknowledged = ?');
      args.add(acknowledged);
    }
    if (resolved != null) {
      where.add('resolved = ?');
      args.add(resolved);
    }
    final maps = await db.query('camera_alerts', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'created_at DESC');
    return maps.map((m) => CameraAlert.fromMap(m)).toList();
  }

  Future<int> acknowledgeAlert(int alertId, int acknowledgedBy, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('camera_alerts', {
        'acknowledged': 1,
        'acknowledged_by': acknowledgedBy,
        'acknowledged_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [alertId]);
      if (count == 0) throw StateError('Alert not found');
      await auditService.logInTransaction(
        txn,
        action: 'acknowledge_camera_alert',
        detail: 'Acknowledged alert $alertId',
        entityType: 'camera_alerts',
        entityId: alertId,
        userId: userId ?? acknowledgedBy,
      );
    });
    return alertId;
  }

  Future<int> resolveAlert(int alertId, int resolvedBy, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('camera_alerts', {
        'resolved': 1,
        'resolved_by': resolvedBy,
        'resolved_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [alertId]);
      if (count == 0) throw StateError('Alert not found');
      await auditService.logInTransaction(
        txn,
        action: 'resolve_camera_alert',
        detail: 'Resolved alert $alertId',
        entityType: 'camera_alerts',
        entityId: alertId,
        userId: userId ?? resolvedBy,
      );
    });
    return alertId;
  }

  // ============ AI Counting Logic (Integration with TFLite) ============

  /// Process a frame from camera and return detection results
  /// This is a placeholder - actual implementation would use tflite_flutter
  Future<List<DetectionResult>> processFrame({
    required CameraDevice camera,
    required Uint8List frameData,
    required int frameTimestamp,
    required CountingSession session,
  }) async {
    // TODO: Implement actual TFLite inference
    // This would:
    // 1. Preprocess frame (resize, normalize)
    // 2. Run inference with TFLite model
    // 3. Post-process (NMS, confidence filtering)
    // 4. Track objects across frames
    // 5. Count objects crossing count line
    // 6. Save detection events to database

    return [];
  }

  /// Start a counting session for a gatepass/shipment
  Future<CountingSession> startCountingSession({
    required CameraDevice camera,
    required String sessionType,
    String? referenceType,
    int? referenceId,
    int? expectedCount,
    int? operatorId,
    int? userId,
  }) async {
    final sessionNumber = 'CNT-${DateTime.now().millisecondsSinceEpoch}';
    final session = CountingSession(
      sessionNumber: sessionNumber,
      cameraId: camera.id!,
      referenceType: referenceType,
      referenceId: referenceId,
      sessionType: sessionType,
      expectedCount: expectedCount,
      startTime: DateTime.now().millisecondsSinceEpoch,
      operatorId: operatorId,
    );
    final id = await createCountingSession(session, userId: userId);
    return session.copyWith(id: id);
  }

  /// Real-time counting stream (for UI updates)
  Stream<int> getCountStream(int sessionId) {
    final controller = StreamController<int>.broadcast();

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final session = await getCountingSession(sessionId);
      if (session != null) {
        controller.add(session.aiCount);
        if (session.status != 'IN_PROGRESS') {
          timer.cancel();
          await controller.close();
        }
      } else {
        timer.cancel();
        await controller.close();
      }
    });

    return controller.stream;
  }

  // ============ Analytics ============
  // (Read-only methods unchanged)

  Future<Map<String, dynamic>> getCountingAccuracy(int fromDate, int toDate) async {
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_sessions,
        SUM(CASE WHEN status = 'VERIFIED' THEN 1 ELSE 0 END) as verified_sessions,
        SUM(CASE WHEN status = 'DISPUTED' THEN 1 ELSE 0 END) as disputed_sessions,
        AVG(CASE WHEN verified_count IS NOT NULL AND ai_count > 0
          THEN ABS(verified_count - ai_count) / ai_count * 100
          ELSE NULL
        END) as avg_discrepancy_percent,
        AVG(CASE WHEN verified_count IS NOT NULL AND ai_count > 0
          THEN ABS(verified_count - ai_count)
          ELSE NULL
        END) as avg_discrepancy_count
      FROM counting_sessions
      WHERE start_time BETWEEN ? AND ? AND status IN ('VERIFIED', 'DISPUTED', 'COMPLETED')
    ''', [fromDate, toDate]);
    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getCameraPerformance(int fromDate, int toDate) async {
    return await db.rawQuery('''
      SELECT
        cd.name as camera_name,
        cd.code as camera_code,
        COUNT(cs.id) as total_sessions,
        SUM(CASE WHEN cs.status = 'VERIFIED' THEN 1 ELSE 0 END) as verified_sessions,
        AVG(CASE WHEN cs.verified_count IS NOT NULL AND cs.ai_count > 0
          THEN ABS(cs.verified_count - cs.ai_count) / cs.ai_count * 100
          ELSE NULL
        END) as avg_accuracy_percent,
        AVG(cs.duration_seconds) as avg_duration_seconds
      FROM counting_sessions cs
      JOIN camera_devices cd ON cs.camera_id = cd.id
      WHERE cs.start_time BETWEEN ? AND ?
      GROUP BY cd.id
      ORDER BY total_sessions DESC
    ''', [fromDate, toDate]);
  }
}

// Extension for CountingSession copyWith
extension CountingSessionExtension on CountingSession {
  CountingSession copyWith({
    int? id,
    String? sessionNumber,
    int? cameraId,
    String? referenceType,
    int? referenceId,
    String? sessionType,
    String? status,
    int? expectedCount,
    int? aiCount,
    int? manualCount,
    int? verifiedCount,
    int? discrepancy,
    double? discrepancyPercent,
    int? startTime,
    int? endTime,
    int? durationSeconds,
    int? operatorId,
    int? verifiedBy,
    int? verifiedAt,
    String? notes,
    int? createdAt,
    int? updatedAt,
  }) {
    return CountingSession(
      id: id ?? this.id,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      cameraId: cameraId ?? this.cameraId,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      expectedCount: expectedCount ?? this.expectedCount,
      aiCount: aiCount ?? this.aiCount,
      manualCount: manualCount ?? this.manualCount,
      verifiedCount: verifiedCount ?? this.verifiedCount,
      discrepancy: discrepancy ?? this.discrepancy,
      discrepancyPercent: discrepancyPercent ?? this.discrepancyPercent,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      operatorId: operatorId ?? this.operatorId,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DetectionResult {
  final int trackId;
  final String className;
  final double confidence;
  final double bboxX;
  final double bboxY;
  final double bboxWidth;
  final double bboxHeight;
  final String? direction;

  DetectionResult({
    required this.trackId,
    required this.className,
    required this.confidence,
    required this.bboxX,
    required this.bboxY,
    required this.bboxWidth,
    required this.bboxHeight,
    this.direction,
  });
}