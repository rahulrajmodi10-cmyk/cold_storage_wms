// test/camera_ai_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/camera_ai_service.dart';

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
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'ACTIVE'
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
            status TEXT NOT NULL DEFAULT 'ACTIVE',
            total_expected INTEGER DEFAULT 0,
            total_scanned INTEGER DEFAULT 0,
            total_matched INTEGER DEFAULT 0,
            total_mismatched INTEGER DEFAULT 0,
            started_at INTEGER,
            completed_at INTEGER,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE count_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            object_type TEXT NOT NULL,
            count INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ai_models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            version TEXT NOT NULL,
            path TEXT NOT NULL,
            active INTEGER DEFAULT 1,
            loaded INTEGER DEFAULT 0
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
    test('add camera device', () async {
      final id = await service.addCameraDevice(
        name: 'Camera-001',
        type: 'AI_OBJECT_DETECTION',
      );

      expect(id, greaterThan(0));

      final camera = await db.query('camera_devices', where: 'id = ?', whereArgs: [id]);
      expect(camera.first['name'], 'Camera-001');
      expect(camera.first['status'], 'ACTIVE');
    });

    test('get cameras by type', () async {
      await db.insert('camera_devices', {'name': 'AI-Cam-1', 'type': 'OBJECT_DETECTION', 'status': 'ACTIVE'});
      await db.insert('camera_devices', {'name': 'OCR-Cam-1', 'type': 'OCR', 'status': 'ACTIVE'});

      final detectionCams = await service.getCameras(type: 'OBJECT_DETECTION');

      expect(detectionCams.length, 1);
      expect(detectionCams.first['name'], 'AI-Cam-1');
    });

    test('get cameras by status', () async {
      await db.insert('camera_devices', {'name': 'Camera-001', 'type': 'OBJECT_DETECTION', 'status': 'ACTIVE'});
      await db.insert('camera_devices', {'name': 'Camera-002', 'type': 'OBJECT_DETECTION', 'status': 'INACTIVE'});

      final activeCams = await service.getCameras(status: 'ACTIVE');

      expect(activeCams.length, 1);
    });

    test('update camera status', () async {
      final id = await db.insert('camera_devices', {
        'name': 'Camera-003',
        'type': 'OBJECT_DETECTION',
        'status': 'ACTIVE',
      });

      await service.updateCameraStatus(id, 'INACTIVE');

      final camera = await db.query('camera_devices', where: 'id = ?', whereArgs: [id]);
      expect(camera.first['status'], 'INACTIVE');
    });
  });

  group('Counting Sessions', () {
    test('create counting session', () async {
      final id = await service.createCountingSession(
        sessionType: 'LOADING',
        referenceType: 'gatepass',
        referenceId: 1,
        locationId: 1,
        operatorId: 1,
        totalExpected: 100,
      );

      expect(id, greaterThan(0));

      final session = await db.query('counting_sessions', where: 'id = ?', whereArgs: [id]);
      expect(session.first['status'], 'ACTIVE');
      expect(session.first['total_expected'], 100);
    });

    test('get counting sessions by status', () async {
      await db.insert('counting_sessions', {
        'session_number': 'CS001',
        'session_type': 'LOADING',
        'status': 'ACTIVE',
        'total_expected': 100,
      });
      await db.insert('counting_sessions', {
        'session_number': 'CS002',
        'session_type': 'UNLOADING',
        'status': 'COMPLETED',
        'total_expected': 50,
      });

      final activeSessions = await service.getCountingSessions(status: 'ACTIVE');

      expect(activeSessions.length, 1);
    });

    test('complete counting session', () async {
      final id = await service.createCountingSession(
        sessionType: 'LOADING',
        totalExpected: 100,
      );

      await service.completeCountingSession(id);

      final session = await db.query('counting_sessions', where: 'id = ?', whereArgs: [id]);
      expect(session.first['status'], 'COMPLETED');
      expect(session.first['completed_at'], isNotNull);
    });

    test('record count result', () async {
      final sessionId = await service.createCountingSession(sessionType: 'LOADING');

      await service.recordCountResult(sessionId, 'ITEM', 5, DateTime.now().millisecondsSinceEpoch);

      final events = await db.query('count_events', where: 'session_id = ?', whereArgs: [sessionId]);
      expect(events.length, 1);
      expect(events.first['count'], 5);
    });

    test('get session statistics', () async {
      final sessionId = await service.createCountingSession(
        sessionType: 'LOADING',
        totalExpected: 100,
      );

      await service.recordCountResult(sessionId, 'ITEM', 95);
      await service.recordCountResult(sessionId, 'ITEM', 5);

      final stats = await service.getSessionStatistics(sessionId);

      expect(stats['totalScanned'], 100);
      expect(stats['totalMatched'], 100);
      expect(stats['totalMismatched'], 0);
    });

    test('validate count match', () async {
      final sessionId = await service.createCountingSession(
        sessionType: 'LOADING',
        totalExpected: 100,
      );

      await service.recordCountResult(sessionId, 'ITEM', 100);

      final isValid = await service.validateCountMatch(sessionId, 100);
      expect(isValid, isTrue);

      final isNotValid = await service.validateCountMatch(sessionId, 95);
      expect(isNotValid, isFalse);
    });
  });

  group('AI Models', () {
    test('add AI model', () async {
      final id = await db.insert('ai_models', {
        'name': 'yolov8_objects',
        'version': '1.0.0',
        'path': '/models/yolov8.tflite',
        'active': 1,
        'loaded': 0,
      });

      expect(id, greaterThan(0));
    });

    test('get active models', () async {
      await db.insert('ai_models', {'name': 'model1', 'version': '1.0', 'path': '/models/m1.tflite', 'active': 1});
      await db.insert('ai_models', {'name': 'model2', 'version': '1.0', 'path': '/models/m2.tflite', 'active': 0});

      final models = await service.getAiModels();

      expect(models.length, 1);
      expect(models.first['name'], 'model1');
    });

    test('mark model as loaded', () async {
      final id = await db.insert('ai_models', {
        'name': 'model1',
        'version': '1.0',
        'path': '/models/m1.tflite',
        'active': 1,
        'loaded': 0,
      });

      await service.markModelLoaded(id, true);

      final model = await db.query('ai_models', where: 'id = ?', whereArgs: [id]);
      expect(model.first['loaded'], 1);
    });
  });
}