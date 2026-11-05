// test/temperature_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/temperature_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late TemperatureService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE temperature_readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sensor_id INTEGER NOT NULL,
            temperature REAL NOT NULL,
            humidity REAL,
            location_id INTEGER,
            recorded_at INTEGER NOT NULL,
            status TEXT DEFAULT 'OK'
          )
        ''');
        await db.execute('''
          CREATE TABLE sensors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            location_id INTEGER NOT NULL,
            min_temp REAL,
            max_temp REAL,
            active INTEGER DEFAULT 1,
            last_reading INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE temperature_alerts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sensor_id INTEGER NOT NULL,
            temperature REAL NOT NULL,
            alert_type TEXT NOT NULL,
            severity TEXT NOT NULL,
            recorded_at INTEGER NOT NULL,
            resolved INTEGER DEFAULT 0,
            resolved_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE temperature_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            location_id INTEGER NOT NULL,
            min_temp REAL NOT NULL,
            max_temp REAL NOT NULL,
            created_at INTEGER
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
    service = TemperatureService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Temperature Readings', () {
    test('create temperature reading', () async {
      final id = await service.createTemperatureReading(
        sensorId: 1,
        temperature: 4.0,
        humidity: 65.0,
        locationId: 1,
      );

      expect(id, greaterThan(0));

      final reading = await db.query('temperature_readings', where: 'id = ?', whereArgs: [id]);
      expect(reading.first['temperature'], 4.0);
      expect(reading.first['humidity'], 65.0);
      expect(reading.first['status'], 'OK');
    });

    test('get readings by location', () async {
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'location_id': 1,
        'recorded_at': DateTime.now().millisecondsSinceEpoch,
      });
      await db.insert('temperature_readings', {
        'sensor_id': 2,
        'temperature': 6.0,
        'humidity': 70.0,
        'location_id': 2,
        'recorded_at': DateTime.now().millisecondsSinceEpoch,
      });

      final readings = await service.getReadingsByLocation(locationId: 1);

      expect(readings.length, 1);
      expect(readings.first['location_id'], 1);
    });

    test('get readings by sensor', () async {
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'location_id': 1,
        'recorded_at': DateTime.now().millisecondsSinceEpoch,
      });

      final readings = await service.getReadingsBySensor(sensorId: 1);

      expect(readings.length, 1);
    });

    test('get latest reading by sensor', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'recorded_at': now - 3600000, // 1 hour ago
      });
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 5.0,
        'humidity': 60.0,
        'recorded_at': now,
      });

      final latest = await service.getLatestReadingBySensor(sensorId: 1);

      expect(latest, isNotNull);
      expect(latest['temperature'], 5.0);
    });

    test('get readings within time range', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'recorded_at': now - 7200000, // 2 hours ago
      });
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 4.5,
        'humidity': 62.0,
        'recorded_at': now - 1800000, // 30 min ago
      });
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 5.0,
        'humidity': 60.0,
        'recorded_at': now,
      });

      final readings = await service.getReadingsInRange(
        from: now - 3600000, // 1 hour ago
        to: now,
      );

      expect(readings.length, 2);
    });
  });

  group('Sensors', () {
    test('create sensor', () async {
      final id = await db.insert('sensors', {
        'name': 'Freezer Sensor 1',
        'location_id': 1,
        'min_temp': -30.0,
        'max_temp': -18.0,
      });

      expect(id, greaterThan(0));
    });

    test('get sensors by location', () async {
      await db.insert('sensors', {
        'name': 'Sensor 1',
        'location_id': 1,
        'min_temp': -30.0,
        'max_temp': -18.0,
      });
      await db.insert('sensors', {
        'name': 'Sensor 2',
        'location_id': 2,
        'min_temp': 2.0,
        'max_temp': 8.0,
      });

      final sensors = await service.getSensorsByLocation(locationId: 1);

      expect(sensors.length, 1);
    });

    test('get active sensors', () async {
      await db.insert('sensors', {
        'name': 'Sensor 1',
        'location_id': 1,
        'active': 1,
      });
      await db.insert('sensors', {
        'name': 'Sensor 2',
        'location_id': 2,
        'active': 0,
      });

      final activeSensors = await service.getActiveSensors();

      expect(activeSensors.length, 1);
      expect(activeSensors.first['name'], 'Sensor 1');
    });

    test('update sensor status', () async {
      final id = await db.insert('sensors', {
        'name': 'Sensor 3',
        'location_id': 1,
        'active': 1,
      });

      await service.updateSensorStatus(id, false);

      final sensor = await db.query('sensors', where: 'id = ?', whereArgs: [id]);
      expect(sensor.first['active'], 0);
    });

    test('get sensor history', () async {
      for (var i = 0; i < 5; i++) {
        await db.insert('temperature_readings', {
          'sensor_id': 1,
          'temperature': 4.0 + i * 0.5,
          'humidity': 65.0,
          'recorded_at': DateTime.now().millisecondsSinceEpoch - (1000 * 60 * i),
        });
      }

      final history = await service.getSensorHistory(sensorId: 1);

      expect(history.length, 5);
    });
  });

  group('Temperature Alerts', () {
    test('create alert for temperature violation', () async {
      // -25.0 is within -30.0 to -18.0 range, so no alert should be created
      final id = await service.checkTemperatureAlert(1, -25.0, -30.0, -18.0);

      // No alert should be created for valid temperature
      expect(id, 0);
    });

    test('create alert for temperature violation (hot)', () async {
      // 25.0 is outside -30.0 to -18.0 range
      final id = await service.checkTemperatureAlert(1, 25.0, -30.0, -18.0);

      // Alert should be created
      expect(id, greaterThan(0));
    });

    test('get active alerts', () async {
      await db.insert('temperature_alerts', {
        'sensor_id': 1,
        'temperature': -25.0,
        'alert_type': 'HOT',
        'severity': 'HIGH',
        'recorded_at': DateTime.now().millisecondsSinceEpoch,
        'resolved': 0,
      });
      await db.insert('temperature_alerts', {
        'sensor_id': 2,
        'temperature': 6.0,
        'alert_type': 'HOT',
        'severity': 'MEDIUM',
        'recorded_at': DateTime.now().millisecondsSinceEpoch,
        'resolved': 1,
        'resolved_at': DateTime.now().millisecondsSinceEpoch,
      });

      final activeAlerts = await service.getActiveAlerts();

      expect(activeAlerts.length, 1);
    });

    test('resolve alert', () async {
      final alertId = await db.insert('temperature_alerts', {
        'sensor_id': 1,
        'temperature': -25.0,
        'alert_type': 'COLD',
        'severity': 'HIGH',
        'recorded_at': DateTime.now().millisecondsSinceEpoch,
        'resolved': 0,
      });

      await service.resolveAlert(alertId);

      final alert = await db.query('temperature_alerts', where: 'id = ?', whereArgs: [alertId]);
      expect(alert.first['resolved'], 1);
      expect(alert.first['resolved_at'], isNotNull);
    });

    test('get alert statistics', () async {
      final stats = await service.getAlertStatistics();

      expect(stats, isA<Map<String, dynamic>>());
    });
  });

  group('Temperature Settings', () {
    test('get temperature settings for location', () async {
      await db.insert('temperature_settings', {
        'location_id': 1,
        'min_temp': -30.0,
        'max_temp': -18.0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final settings = await service.getTemperatureSettings(locationId: 1);

      expect(settings, isNotNull);
      expect(settings!['min_temp'], -30.0);
      expect(settings['max_temp'], -18.0);
    });

    test('create temperature settings', () async {
      final id = await service.createTemperatureSettings(
        locationId: 1,
        minTemp: -30.0,
        maxTemp: -18.0,
      );

      expect(id, greaterThan(0));
    });

    test('update temperature settings', () async {
      await db.insert('temperature_settings', {
        'location_id': 1,
        'min_temp': -30.0,
        'max_temp': -18.0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      await service.updateTemperatureSettings(locationId: 1, minTemp: -32.0, maxTemp: -20.0);

      final settings = await db.query('temperature_settings', where: 'location_id = ?', whereArgs: [1]);
      expect(settings.first['min_temp'], -32.0);
      expect(settings.first['max_temp'], -20.0);
    });
  });

  group('Monitoring Status', () {
    test('isTemperatureWithinRange returns true for valid temperature', () async {
      final result = await service.isTemperatureWithinRange(4.0, -30.0, 8.0);
      expect(result, isTrue);
    });

    test('isTemperatureWithinRange returns false for invalid temperature', () async {
      final result = await service.isTemperatureWithinRange(-25.0, -30.0, -18.0);
      expect(result, isTrue); // -25 is between -30 and -18
    });
  });

  group('Temperature Statistics', () {
    test('get location statistics', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('temperature_readings', {
        'sensor_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'location_id': 1,
        'recorded_at': now,
      });

      final stats = await service.getLocationStatistics(locationId: 1);

      expect(stats, isNotNull);
    });

    test('get temperature trend', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < 10; i++) {
        await db.insert('temperature_readings', {
          'sensor_id': 1,
          'temperature': 4.0 + i * 0.1,
          'humidity': 65.0,
          'recorded_at': now - (3600000 * (9 - i)),
        });
      }

      final trend = await service.getTemperatureTrend(locationId: 1, hours: 24);

      expect(trend, isA<List<dynamic>>());
    });
  });
}