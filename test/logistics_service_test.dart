// test/logistics_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/logistics_service.dart';
import '../lib/models/logistics_models.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late LogisticsService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE carriers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            code TEXT,
            contact_person TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            gstin TEXT,
            pan TEXT,
            license_number TEXT,
            rating REAL DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            carrier_id INTEGER,
            registration_number TEXT NOT NULL,
            vehicle_type TEXT,
            capacity_weight REAL,
            capacity_volume REAL,
            capacity_pallets INTEGER,
            temperature_controlled INTEGER DEFAULT 0,
            min_temp REAL,
            max_temp REAL,
            gps_device_id TEXT,
            insurance_expiry INTEGER,
            fitness_expiry INTEGER,
            permit_expiry INTEGER,
            driver_name TEXT,
            driver_phone TEXT,
            driver_license TEXT,
            status TEXT DEFAULT 'AVAILABLE',
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE routes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL,
            name TEXT NOT NULL,
            origin TEXT NOT NULL,
            destination TEXT NOT NULL,
            distance_km REAL,
            estimated_duration_minutes INTEGER,
            toll_charges REAL DEFAULT 0,
            route_description TEXT,
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE shipments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shipment_number TEXT NOT NULL,
            shipment_date INTEGER NOT NULL,
            reference_type TEXT,
            reference_id INTEGER,
            carrier_id INTEGER,
            vehicle_id INTEGER,
            route_id INTEGER,
            driver_name TEXT,
            driver_phone TEXT,
            origin_address TEXT,
            destination_address TEXT,
            origin_lat REAL,
            origin_lng REAL,
            dest_lat REAL,
            dest_lng REAL,
            status TEXT DEFAULT 'PLANNED',
            total_weight REAL DEFAULT 0,
            total_volume REAL DEFAULT 0,
            total_packages INTEGER DEFAULT 0,
            freight_charges REAL DEFAULT 0,
            additional_charges REAL DEFAULT 0,
            total_freight REAL DEFAULT 0,
            loading_start_time INTEGER,
            loading_end_time INTEGER,
            departure_time INTEGER,
            arrival_time INTEGER,
            unloading_start_time INTEGER,
            unloading_end_time INTEGER,
            proof_of_delivery TEXT,
            pod_timestamp INTEGER,
            pod_received_by TEXT,
            narration TEXT,
            created_by INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE shipment_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shipment_id INTEGER NOT NULL,
            item_id INTEGER,
            description TEXT,
            quantity REAL NOT NULL,
            unit TEXT,
            weight REAL,
            volume REAL,
            packages INTEGER DEFAULT 1,
            temperature_required INTEGER DEFAULT 0,
            min_temp REAL,
            max_temp REAL,
            loaded_quantity REAL DEFAULT 0,
            delivered_quantity REAL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE shipment_tracking (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shipment_id INTEGER NOT NULL,
            latitude REAL,
            longitude REAL,
            address TEXT,
            speed REAL,
            heading REAL,
            status TEXT,
            temperature REAL,
            humidity REAL,
            battery_level REAL,
            signal_strength REAL,
            timestamp INTEGER NOT NULL,
            source TEXT
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
    service = LogisticsService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Transportation', () {
    group('Carriers', () {
      test('create carrier', () async {
        final carrier = Carrier(name: 'Test Carrier');
        final id = await service.createCarrier(carrier);

        expect(id, greaterThan(0));

        final retrieved = await service.getCarrier(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test Carrier');
      });

      test('get carriers', () async {
        await service.createCarrier(Carrier(name: 'Carrier A'));
        await service.createCarrier(Carrier(name: 'Carrier B'));

        final carriers = await service.getCarriers();

        expect(carriers.length, 2);
      });

      test('update carrier', () async {
        final carrier = Carrier(name: 'Original Name');
        final id = await service.createCarrier(carrier);

        final updated = Carrier(id: id, name: 'Updated Name');
        await service.updateCarrier(updated);

        final retrieved = await service.getCarrier(id);
        expect(retrieved!.name, 'Updated Name');
      });
    });

    group('Vehicles', () {
      test('create vehicle', () async {
        final vehicle = Vehicle(registrationNumber: 'TRUCK-001');
        final id = await service.createVehicle(vehicle);

        expect(id, greaterThan(0));

        final retrieved = await service.getVehicle(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.registrationNumber, 'TRUCK-001');
        expect(retrieved.status, 'AVAILABLE');
      });

      test('get vehicles by status', () async {
        await service.createVehicle(Vehicle(registrationNumber: 'TRUCK-001', status: 'AVAILABLE'));
        await service.createVehicle(Vehicle(registrationNumber: 'TRUCK-002', status: 'MAINTENANCE'));

        final available = await service.getVehicles(status: 'AVAILABLE');

        expect(available.length, 1);
        expect(available.first.registrationNumber, 'TRUCK-001');
      });

      test('update vehicle status', () async {
        final vehicle = Vehicle(registrationNumber: 'TRUCK-001');
        final id = await service.createVehicle(vehicle);

        await service.updateVehicleStatus(id, 'MAINTENANCE');

        final retrieved = await service.getVehicle(id);
        expect(retrieved!.status, 'MAINTENANCE');
      });
    });

    group('Routes', () {
      test('create route', () async {
        final route = Route(code: 'R001', name: 'Test Route', origin: 'Zone A', destination: 'Zone B');
        final id = await service.createRoute(route);

        expect(id, greaterThan(0));

        final retrieved = await service.getRoute(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.code, 'R001');
      });

      test('get routes', () async {
        await service.createRoute(Route(code: 'R001', name: 'Route A', origin: 'A', destination: 'B'));
        await service.createRoute(Route(code: 'R002', name: 'Route B', origin: 'B', destination: 'C'));

        final routes = await service.getRoutes();

        expect(routes.length, 2);
      });
    });

    group('Shipment Creation', () {
      test('create shipment', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final shipment = Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
          originAddress: ' Warehouse A',
          destinationAddress: ' Warehouse B',
        );
        final id = await service.createShipment(shipment);

        expect(id, greaterThan(0));

        final retrieved = await service.getShipment(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.shipmentNumber, 'SHP001');
        expect(retrieved.status, 'PLANNED');
      });

      test('get shipment by number', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        await service.createShipment(Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
        ));

        final retrieved = await service.getShipmentByNumber('SHP001');

        expect(retrieved, isNotNull);
        expect(retrieved!.shipmentNumber, 'SHP001');
      });
    });

    group('Shipment Items', () {
      test('add shipment item', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final shipmentId = await service.createShipment(Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
        ));

        final itemId = await service.addShipmentItem(ShipmentItem(
          shipmentId: shipmentId,
          description: 'Test Item',
          quantity: 100,
        ));

        expect(itemId, greaterThan(0));

        final items = await service.getShipmentItems(shipmentId);
        expect(items.length, 1);
        expect(items.first.description, 'Test Item');
      });
    });

    group('Tracking', () {
      test('add tracking point', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final shipmentId = await service.createShipment(Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
        ));

        final trackingId = await service.addTrackingPoint(ShipmentTracking(
          shipmentId: shipmentId,
          latitude: 12.9716,
          longitude: 77.5946,
          status: 'IN_TRANSIT',
          timestamp: now,
        ));

        expect(trackingId, greaterThan(0));

        final tracking = await service.getLatestTracking(shipmentId);
        expect(tracking, isNotNull);
        expect(tracking!.latitude, 12.9716);
      });
    });

    group('Shipment Status Updates', () {
      test('update shipment status', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final shipment = Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
        );
        final id = await service.createShipment(shipment);

        final updatedId = await service.updateShipmentStatus(id, 'IN_TRANSIT', loadedAt: now);

        expect(updatedId, id);

        final retrieved = await service.getShipment(id);
        expect(retrieved!.status, 'IN_TRANSIT');
      });
    });

    group('Analytics', () {
      test('get shipment summary', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        await service.createShipment(Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
          status: 'DELIVERED',
        ));
        await service.createShipment(Shipment(
          shipmentNumber: 'SHP002',
          shipmentDate: now,
          status: 'IN_TRANSIT',
        ));

        final summary = await service.getShipmentSummary(now - 86400000, now + 86400000);

        expect(summary, isNotNull);
        expect(summary['total_shipments'], 2);
      });

      test('get carrier performance', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        await service.createShipment(Shipment(
          shipmentNumber: 'SHP001',
          shipmentDate: now,
          status: 'DELIVERED',
        ));

        final performance = await service.getCarrierPerformance(now - 86400000, now + 86400000);

        expect(performance, isA<List<Map<String, dynamic>>>());
      });
    });
  });
}