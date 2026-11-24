// test/camera_ai_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:cold_storage_wms/services/camera_ai_service.dart';
import 'package:cold_storage_wms/models/camera_ai_models.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late CameraAIService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE camera_devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            code TEXT,
            device_type TEXT,
            location_id INTEGER,
            ip_address TEXT,
            port INTEGER,
            username TEXT,
            password_hash TEXT,
            rtsp_url TEXT,
            resolution_width INTEGER,
            resolution_height INTEGER,
            fps INTEGER,
            model_path TEXT,
            model_version TEXT,
            confidence_threshold REAL,
            iou_threshold REAL,
            detection_classes TEXT,
            count_direction TEXT,
            roi_coordinates TEXT,
            calibration_factor REAL,
            is_active INTEGER DEFAULT 1,
            last_heartbeat INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE counting_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_number TEXT,
            camera_id INTEGER NOT NULL,
            reference_type TEXT,
            reference_id INTEGER,
            session_type TEXT,
            status TEXT DEFAULT 'IN_PROGRESS',
            ai_count INTEGER DEFAULT 0,
            manual_count INTEGER,
            verified_count INTEGER,
            discrepancy INTEGER DEFAULT 0,
            discrepancy_percent REAL DEFAULT 0,
            start_time INTEGER,
            end_time INTEGER,
            duration_seconds INTEGER,
            operator_id INTEGER,
            verified_by INTEGER,
            verified_at INTEGER,
            notes TEXT,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE detection_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            frame_timestamp INTEGER NOT NULL,
            track_id INTEGER,
            class_name TEXT,
            confidence REAL,
            bbox_x REAL,
            bbox_y REAL,
            bbox_width REAL,
            bbox_height REAL,
            centroid_x REAL,
            centroid_y REAL,
            direction TEXT,
            counted INTEGER DEFAULT 0,
            count_timestamp INTEGER,
            image_path TEXT,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE ml_models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            version TEXT,
            model_type TEXT,
            framework TEXT,
            input_width INTEGER,
            input_height INTEGER,
            input_channels INTEGER,
            classes TEXT,
            model_file_path TEXT,
            label_file_path TEXT,
            metrics_json TEXT,
            training_data_info TEXT,
            is_active INTEGER DEFAULT 1,
            deployed_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE camera_alerts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            camera_id INTEGER NOT NULL,
            alert_type TEXT,
            severity TEXT,
            message TEXT,
            session_id INTEGER,
            detection_event_id INTEGER,
            acknowledged INTEGER DEFAULT 0,
            acknowledged_by INTEGER,
            acknowledged_at INTEGER,
            resolved INTEGER DEFAULT 0,
            resolved_by INTEGER,
            resolved_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE count_verifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            verification_type TEXT,
            verifier_id INTEGER NOT NULL,
            original_count INTEGER NOT NULL,
            verified_count INTEGER NOT NULL,
            variance INTEGER NOT NULL,
            variance_percent REAL NOT NULL,
            status TEXT DEFAULT 'PENDING',
            verification_notes TEXT,
            evidence_images TEXT,
            started_at INTEGER,
            completed_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            detail TEXT,
            entity_type TEXT,
            entity_id INTEGER,
            user_id INTEGER,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
    service = CameraAIService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Camera Devices', () {
    test('create camera device', () async {
      final camera = CameraDevice(
        name: 'Camera-001',
        code: 'CAM-001',
        deviceType: 'MOBILE',
        locationId: 1,
      );

      final id = await service.createCamera(camera);
      expect(id, greaterThan(0));
    });

    test('get camera device by ID', () async {
      final camera = CameraDevice(
        name: 'Camera-001',
        code: 'CAM-001',
        deviceType: 'MOBILE',
      );
      final id = await service.createCamera(camera);

      final fetched = await service.getCamera(id);
      expect(fetched?.name, 'Camera-001');
    });

    test('update camera device', () async {
      final camera = CameraDevice(
        name: 'Camera-001',
        code: 'CAM-001',
        deviceType: 'MOBILE',
      );
      final id = await service.createCamera(camera);

      final updated = CameraDevice(
        id: id,
        name: 'Camera-001-Updated',
        code: 'CAM-001',
        deviceType: 'MOBILE',
      );
      await service.updateCamera(updated);

      final fetched = await service.getCamera(id);
      expect(fetched?.name, 'Camera-001-Updated');
    });

    test('update camera heartbeat', () async {
      final camera = CameraDevice(
        name: 'Camera-001',
        code: 'CAM-001',
        deviceType: 'MOBILE',
      );
      final id = await service.createCamera(camera);

      await service.updateCameraHeartbeat(id);

      final fetched = await service.getCamera(id);
      expect(fetched?.lastHeartbeat, greaterThan(0));
    });

    test('get all cameras', () async {
      await service.createCamera(CameraDevice(name: 'Cam-1', code: 'C1'));
      await service.createCamera(CameraDevice(name: 'Cam-2', code: 'C2'));

      final cameras = await service.getCameras();
      expect(cameras.length, 2);
    });

    test('get active cameras only', () async {
      await service.createCamera(CameraDevice(name: 'Cam-1', code: 'C1'));
      await service.createCamera(CameraDevice(
        name: 'Cam-2',
        code: 'C2',
        isActive: 0,
      ));

      final activeCameras = await service.getCameras();
      expect(activeCameras.length, 1);
    });
  });

  group('Counting Sessions', () {
    test('create counting session', () async {
      final session = CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      );

      final id = await service.createCountingSession(session);
      expect(id, greaterThan(0));
    });

    test('get counting session by ID', () async {
      final sessionId = await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      final session = await service.getCountingSession(sessionId);
      expect(session?.sessionNumber, 'S001');
    });

    test('get counting session by number', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      final session = await service.getCountingSessionByNumber('S001');
      expect(session?.sessionNumber, 'S001');
    });

    test('complete counting session', () async {
      final sessionId = await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      await service.completeCountingSession(sessionId, manualCount: 95, verifiedBy: 1);

      final session = await service.getCountingSession(sessionId);
      expect(session?.endTime, greaterThan(0));
    });

    test('start counting session for camera', () async {
      await service.createCamera(CameraDevice(name: 'Cam-1', code: 'C1'));

      final session = await service.startCountingSession(
        camera: CameraDevice(id: 1, name: 'Cam-1', code: 'C1'),
        sessionType: 'INVENTORY',
        referenceType: 'GATEPASS',
        referenceId: 123,
      );

      expect(session.id, greaterThan(0));
      expect(session.startTime, greaterThan(0));
      expect(session.status, 'IN_PROGRESS');
    });

    test('get counting sessions by status', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      await service.completeCountingSession(1, manualCount: 95, verifiedBy: 1);

      final completed = await service.getCountingSessions(status: 'COMPLETED');
      expect(completed.length, 1);
      expect(completed.first.status, 'COMPLETED');
    });
  });

  group('Detection Events', () {
    test('add detection event', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      final event = DetectionEvent(
        sessionId: 1,
        frameTimestamp: DateTime.now().millisecondsSinceEpoch,
        className: 'person',
        confidence: 0.95,
        bboxX: 100.0,
        bboxY: 150.0,
        bboxWidth: 50.0,
        bboxHeight: 180.0,
        direction: 'IN',
      );

      final id = await service.addDetectionEvent(event);
      expect(id, greaterThan(0));
    });

    test('get detection events for session', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      await service.addDetectionEvent(DetectionEvent(
        sessionId: 1,
        frameTimestamp: 1000,
        className: 'person',
        direction: 'IN',
      ));
      await service.addDetectionEvent(DetectionEvent(
        sessionId: 1,
        frameTimestamp: 2000,
        className: 'box',
        direction: 'OUT',
      ));

      final events = await service.getDetectionEvents(1);
      expect(events.length, 2);
    });

    test('add detection events batch', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      final events = [
        DetectionEvent(sessionId: 1, frameTimestamp: 1000, className: 'person'),
        DetectionEvent(sessionId: 1, frameTimestamp: 2000, className: 'person'),
      ];

      await service.addDetectionEventsBatch(events);

      final result = await service.getDetectionEvents(1);
      expect(result.length, 2);
    });

    test('get session stats', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      await service.addDetectionEvent(DetectionEvent(
        sessionId: 1,
        frameTimestamp: 1000,
        className: 'person',
        confidence: 0.95,
        direction: 'IN',
      ));
      await service.addDetectionEvent(DetectionEvent(
        sessionId: 1,
        frameTimestamp: 2000,
        className: 'box',
        confidence: 0.85,
        direction: 'OUT',
      ));

      final stats = await service.getSessionStats(1);
      expect(stats['total_detections'], 2);
      expect(stats['avg_confidence'], 0.9);
    });
  });

  group('ML Models', () {
    test('create ML model', () async {
      final model = MLModel(
        name: 'yolov8_objects',
        version: '1.0.0',
        modelFilePath: '/models/yolov8.tflite',
      );

      final id = await service.createMLModel(model);
      expect(id, greaterThan(0));
    });

    test('get ML models', () async {
      await service.createMLModel(MLModel(name: 'model1', version: '1.0', modelFilePath: '/models/m1.tflite'));
      await service.createMLModel(MLModel(name: 'model2', version: '1.0', modelFilePath: '/models/m2.tflite'));

      final models = await service.getMLModels();

      expect(models.length, 2);
    });

    test('deploy ML model', () async {
      final model = MLModel(name: 'model1', version: '1.0', modelFilePath: '/models/m1.tflite');
      final id = await service.createMLModel(model);

      await service.deployMLModel(id);

      final models = await service.getMLModels();
      final deployedModel = models.firstWhere((m) => m.id == id);
      expect(deployedModel.deployedAt, greaterThan(0));
    });

    test('get active ML model', () async {
      await service.createMLModel(MLModel(name: 'model1', version: '1.0', modelFilePath: '/models/m1.tflite'));
      await service.createMLModel(MLModel(name: 'model2', version: '1.0', modelFilePath: '/models/m2.tflite'));

      final activeModel = await service.getActiveMLModel();
      expect(activeModel, isNotNull);
      expect(activeModel?.isActive, 1);
    });
  });

  group('Camera Alerts', () {
    test('create and get alerts', () async {
      final alert = CameraAlert(
        cameraId: 1,
        alertType: 'LOW_CONFIDENCE',
        severity: 'HIGH',
        message: 'Low confidence detections detected',
      );

      final alertId = await service.createAlert(alert);
      expect(alertId, greaterThan(0));

      final alerts = await service.getAlerts(cameraId: 1, acknowledged: 0);
      expect(alerts.length, 1);
      expect(alerts.first.alertType, 'LOW_CONFIDENCE');
    });

    test('acknowledge alert', () async {
      final alert = CameraAlert(
        cameraId: 1,
        alertType: 'MISSING_DETECTION',
        severity: 'MEDIUM',
        message: 'Expected detection not found',
      );

      final alertId = await service.createAlert(alert);

      await service.acknowledgeAlert(alertId, 1);

      final alerts = await service.getAlerts(cameraId: 1, acknowledged: 1);
      expect(alerts.length, 1);
    });

    test('resolve alert', () async {
      final alert = CameraAlert(
        cameraId: 1,
        alertType: 'TEST_ALERT',
        severity: 'LOW',
        message: 'Test alert for resolution',
      );

      final alertId = await service.createAlert(alert);

      await service.resolveAlert(alertId, 1);

      final resolvedAlerts = await service.getAlerts(cameraId: 1, resolved: 1);
      expect(resolvedAlerts.first.id, alertId);
    });
  });

  group('Count Verifications', () {
    test('create count verification', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      final verification = CountVerification(
        sessionId: 1,
        verifierId: 1,
        originalCount: 100,
        verifiedCount: 95,
        variance: 5,
        variancePercent: 5.0,
      );

      final id = await service.createVerification(verification);
      expect(id, greaterThan(0));
    });

    test('get verifications for session', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      await service.createVerification(CountVerification(
        sessionId: 1,
        verifierId: 1,
        originalCount: 100,
        verifiedCount: 95,
        variance: 5,
        variancePercent: 5.0,
      ));

      final verifications = await service.getVerifications(1);
      expect(verifications.length, 1);
    });

    test('update verification status', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'S001',
        cameraId: 1,
        sessionType: 'INVENTORY',
        expectedCount: 100,
      ));

      final verificationId = await service.createVerification(CountVerification(
        sessionId: 1,
        verifierId: 1,
        originalCount: 100,
        verifiedCount: 95,
        variance: 5,
        variancePercent: 5.0,
      ));

      await service.updateVerificationStatus(verificationId, 'APPROVED');

      final verification = await service.getVerifications(1);
      expect(verification.first.status, 'APPROVED');
    });
  });
}