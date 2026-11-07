// test/camera_ai_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/camera_ai_service.dart';
import '../lib/services/audit_service.dart';
import '../lib/models/camera_ai_models.dart';
import '../lib/models/camera_ai_models.dart' as models;

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
            code TEXT,
            name TEXT,
            type TEXT,
            status TEXT DEFAULT 'ACTIVE',
            is_active INTEGER DEFAULT 1,
            location_id INTEGER,
            created_at INTEGER,
            updated_at INTEGER,
            last_heartbeat INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE counting_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_number TEXT NOT NULL UNIQUE,
            session_type TEXT NOT NULL,
            reference_type TEXT,
            reference_id INTEGER,
            location_id INTEGER,
            operator_id INTEGER,
            status TEXT NOT NULL DEFAULT 'IN_PROGRESS',
            total_expected INTEGER DEFAULT 0,
            ai_count INTEGER DEFAULT 0,
            manual_count INTEGER,
            verified_count INTEGER,
            discrepancy INTEGER DEFAULT 0,
            discrepancy_percent REAL DEFAULT 0,
            start_time INTEGER,
            end_time INTEGER,
            duration_seconds INTEGER,
            notes TEXT,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE detection_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            object_type TEXT NOT NULL,
            count INTEGER NOT NULL,
            frame_timestamp INTEGER,
            detected_at INTEGER,
            confidence REAL,
            direction TEXT,
            counted INTEGER DEFAULT 0,
            count_timestamp INTEGER,
            bounding_box TEXT,
            created_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE ai_models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            version TEXT NOT NULL,
            path TEXT NOT NULL,
            active INTEGER DEFAULT 1,
            loaded INTEGER DEFAULT 0,
            deployed_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            action TEXT,
            detail TEXT,
            timestamp INTEGER,
            entity_type TEXT,
            entity_id INTEGER
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
    test('create and get camera', () async {
      final camera = CameraDevice(
        code: 'CAM001',
        name: 'Camera-001',
        type: 'OBJECT_DETECTION',
        cameraId: 'CAM-001',
        locationId: 1,
      );

      final id = await service.createCamera(camera);
      expect(id, greaterThan(0));

      final retrieved = await service.getCamera(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.code, 'CAM001');
      expect(retrieved.name, 'Camera-001');
    });

    test('get cameras list', () async {
      await service.createCamera(CameraDevice(
        code: 'CAM001',
        name: 'AI-Cam-1',
        type: 'OBJECT_DETECTION',
        cameraId: 'CAM-001',
        locationId: 1,
      ));
      await service.createCamera(CameraDevice(
        code: 'CAM002',
        name: 'OCR-Cam-1',
        type: 'OCR',
        cameraId: 'CAM-002',
        locationId: 2,
      ));

      final cameras = await service.getCameras();

      expect(cameras.length, 2);
    });
  });

  group('Counting Sessions', () {
    test('create counting session', () async {
      final session = CountingSession(
        sessionNumber: 'CS001',
        cameraId: 1,
        sessionType: 'LOADING',
        referenceType: 'gatepass',
        referenceId: 100,
        operatorId: 1,
        expectedCount: 100,
      );

      final id = await service.createCountingSession(session);
      expect(id, greaterThan(0));

      final retrieved = await service.getCountingSession(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.status, 'IN_PROGRESS');
      expect(retrieved.expectedCount, 100);
    });

    test('get counting sessions by status', () async {
      await service.createCountingSession(CountingSession(
        sessionNumber: 'CS001',
        cameraId: 1,
        sessionType: 'LOADING',
        status: 'IN_PROGRESS',
      ));
      await service.createCountingSession(CountingSession(
        sessionNumber: 'CS002',
        cameraId: 2,
        sessionType: 'UNLOADING',
        status: 'COMPLETED',
      ));

      final activeSessions = await service.getCountingSessions(status: 'IN_PROGRESS');

      expect(activeSessions.length, greaterThanOrEqualTo(1));
    });

    test('complete counting session', () async {
      final session = CountingSession(
        sessionNumber: 'CS003',
        cameraId: 1,
        sessionType: 'LOADING',
        expectedCount: 100,
      );

      final id = await service.createCountingSession(session);

      await service.completeCountingSession(id, verifiedCount: 100);

      final retrieved = await service.getCountingSession(id);
      expect(retrieved!.status, 'COMPLETED');
      expect(retrieved.completedAt, isNotNull);
    });
  });

  group('Detection Events', () {
    test('add detection event', () async {
      final session = CountingSession(
        sessionNumber: 'CS004',
        cameraId: 1,
        sessionType: 'LOADING',
        expectedCount: 50,
      );

      final sessionId = await service.createCountingSession(session);

      final event = DetectionEvent(
        sessionId: sessionId,
        objectType: 'ITEM',
        count: 5,
        frameTimestamp: DateTime.now().millisecondsSinceEpoch,
        confidence: 0.95,
        direction: 'IN',
      );

      final eventId = await service.addDetectionEvent(event);
      expect(eventId, greaterThan(0));

      final events = await service.getDetectionEvents(sessionId);
      expect(events.length, 1);
      expect(events.first.count, 5);
    });

    test('get session stats', () async {
      final session = CountingSession(
        sessionNumber: 'CS005',
        cameraId: 1,
        sessionType: 'LOADING',
        expectedCount: 100,
      );

      final sessionId = await service.createCountingSession(session);

      final event = DetectionEvent(
        sessionId: sessionId,
        objectType: 'ITEM',
        count: 95,
        frameTimestamp: DateTime.now().millisecondsSinceEpoch,
        confidence: 0.90,
        direction: 'IN',
      );

      await service.addDetectionEvent(event);

      final stats = await service.getSessionStats(sessionId);
      expect(stats['total_detections'], 95);
    });
  });

  group('ML Models', () {
    test('add AI model', () async {
      final model = MLModel(
        name: 'yolov8_objects',
        version: '1.0.0',
        path: '/models/yolov8.tflite',
      );

      final id = await service.createMLModel(model);
      expect(id, greaterThan(0));
    });

    test('get ML models', () async {
      await service.createMLModel(MLModel(name: 'model1', version: '1.0', path: '/models/m1.tflite', active: 1));
      await service.createMLModel(MLModel(name: 'model2', version: '1.0', path: '/models/m2.tflite', active: 0));

      final models = await service.getMLModels();

      expect(models.length, 2);
    });

    test('deploy ML model', () async {
      final model = MLModel(name: 'model1', version: '1.0', path: '/models/m1.tflite');
      final id = await service.createMLModel(model);

      final deployedId = await service.deployMLModel(id);
      expect(deployedId, id);
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

      final alerts = await service.getAlerts(cameraId: 1, severity: 'HIGH');
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

  group('Verifications', () {
    test('create verification', () async {
      final session = CountingSession(
        sessionNumber: 'CS006',
        cameraId: 1,
        sessionType: 'LOADING',
        expectedCount: 100,
      );

      final sessionId = await service.createCountingSession(session);

      final verification = CountVerification(
        sessionId: sessionId,
        manualCount: 100,
        verifiedCount: 100,
      );

      final verificationId = await service.createVerification(verification);
      expect(verificationId, greaterThan(0));

      final validations = await service.getVerifications(sessionId);
      expect(validations.length, 1);
    });
  });
}