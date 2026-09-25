// test/location_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/location_service.dart';
import '../lib/models/storage_location.dart';
import 'package:path/path.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late LocationService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE storage_location (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rack_id TEXT,
            shelf_id TEXT,
            bin_id TEXT,
            zone TEXT,
            capacity REAL,
            current_utilization REAL
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
    service = LocationService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create and read location', () async {
    final loc = StorageLocation(
      rackId: 'A', shelfId: '1', binId: '01', zone: 'FROZEN',
      capacity: 1000, currentUtilization: 0,
    );
    final id = await service.createLocation(loc);
    expect(id, greaterThan(0));

    final retrieved = await service.getLocation(id);
    expect(retrieved, isNotNull);
    expect(retrieved!.rackId, 'A');
    expect(retrieved.capacity, 1000);
  });

  test('list locations with zone filter', () async {
    await service.createLocation(StorageLocation(rackId: 'A', shelfId: '1', binId: '01', zone: 'FROZEN', capacity: 100, currentUtilization: 0));
    await service.createLocation(StorageLocation(rackId: 'B', shelfId: '1', binId: '01', zone: 'CHILLED', capacity: 100, currentUtilization: 0));
    await service.createLocation(StorageLocation(rackId: 'A', shelfId: '2', binId: '01', zone: 'FROZEN', capacity: 100, currentUtilization: 0));

    var all = await service.listLocations();
    expect(all.length, 3);

    var frozen = await service.listLocations(zone: 'FROZEN');
    expect(frozen.length, 2);
  });

  test('update utilization', () async {
    final id = await service.createLocation(StorageLocation(
      rackId: 'A', shelfId: '1', binId: '01', zone: 'FROZEN',
      capacity: 1000, currentUtilization: 100,
    ));

    await service.updateUtilization(id, 250);
    final loc = await service.getLocation(id);
    expect(loc!.currentUtilization, 250);
  });

  test('capacity validation', () async {
    final loc = StorageLocation(
      rackId: 'A', shelfId: '1', binId: '01', zone: 'FROZEN',
      capacity: -100, currentUtilization: 0,
    );
    expect(() => service.createLocation(loc), throwsArgumentError);
  });
}