// test/temperature_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:cold_storage_wms/services/temperature_service.dart';
import 'package:cold_storage_wms/models/temperature_log.dart';

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
          CREATE TABLE temperature_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_id INTEGER NOT NULL,
            location_id INTEGER,
            temperature REAL NOT NULL,
            humidity REAL,
            timestamp INTEGER NOT NULL,
            sensor_id TEXT NOT NULL,
            status TEXT DEFAULT 'OK'
          )
        ''');
        await db.execute('''
          CREATE TABLE inventory_item (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sku TEXT NOT NULL,
            min_temp REAL,
            max_temp REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE alert (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            severity TEXT NOT NULL,
            message TEXT NOT NULL,
            target_id INTEGER,
            acknowledged INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    service = TemperatureService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Temperature Logs', () {
    test('logTemperature inserts a reading', () async {
      final id = await service.logTemperature(
        TemperatureLog(
          itemId: 1,
          locationId: 1,
          temperature: 4.0,
          humidity: 65.0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          sensorId: 'SENS-001',
        ),
      );

      expect(id, greaterThan(0));

      final reading = await db.query('temperature_log', where: 'id = ?', whereArgs: [id]);
      expect(reading.first['temperature'], 4.0);
      expect(reading.first['humidity'], 65.0);
      expect(reading.first['status'], 'OK');
    });

    test('getLogsForItem returns logs for item', () async {
      await db.insert('temperature_log', {
        'item_id': 1,
        'location_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sensor_id': 'SENS-001',
      });
      await db.insert('temperature_log', {
        'item_id': 2,
        'location_id': 1,
        'temperature': 6.0,
        'humidity': 70.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sensor_id': 'SENS-002',
      });

      final logs = await service.getLogsForItem(1);

      expect(logs.length, 1);
      expect(logs.first.itemId, 1);
    });

    test('getLogsForLocation returns logs for location', () async {
      await db.insert('temperature_log', {
        'item_id': 1,
        'location_id': 1,
        'temperature': 4.0,
        'humidity': 65.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sensor_id': 'SENS-001',
      });
      await db.insert('temperature_log', {
        'item_id': 2,
        'location_id': 2,
        'temperature': 6.0,
        'humidity': 70.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sensor_id': 'SENS-002',
      });

      final logs = await service.getLogsForLocation(1);

      expect(logs.length, 1);
      expect(logs.first.locationId, 1);
    });
  });

  group('Temperature Alerts', () {
    test('creates alert when temperature below minimum', () async {
      await db.insert('inventory_item', {
        'sku': 'ITEM-001',
        'min_temp': -20.0,
        'max_temp': 4.0,
      });

      await service.logTemperature(
        TemperatureLog(
          itemId: 1,
          locationId: 1,
          temperature: -25.0,
          humidity: 65.0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          sensorId: 'SENS-001',
        ),
      );

      final alerts = await db.query('alert', where: 'type = ?', whereArgs: ['TEMP_EXCURSION_LOW']);
      expect(alerts.length, 1);
    });

    test('creates alert when temperature above maximum', () async {
      await db.insert('inventory_item', {
        'sku': 'ITEM-002',
        'min_temp': 2.0,
        'max_temp': 8.0,
      });

      await service.logTemperature(
        TemperatureLog(
          itemId: 1,
          locationId: 1,
          temperature: 15.0,
          humidity: 65.0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          sensorId: 'SENS-001',
        ),
      );

      final alerts = await db.query('alert', where: 'type = ?', whereArgs: ['TEMP_EXCURSION_HIGH']);
      expect(alerts.length, 1);
    });

    test('no alert created for temperature within range', () async {
      await db.insert('inventory_item', {
        'sku': 'ITEM-003',
        'min_temp': 2.0,
        'max_temp': 8.0,
      });

      await service.logTemperature(
        TemperatureLog(
          itemId: 1,
          locationId: 1,
          temperature: 5.0,
          humidity: 65.0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          sensorId: 'SENS-001',
        ),
      );

      final alerts = await db.query('alert');
      expect(alerts.length, 0);
    });
  });
}