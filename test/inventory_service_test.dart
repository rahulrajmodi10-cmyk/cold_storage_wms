// test/inventory_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/inventory_service.dart';
import '../lib/models/inventory_item.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late InventoryService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE inventory_item (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sku TEXT UNIQUE,
            name TEXT,
            category TEXT,
            quantity INTEGER DEFAULT 0,
            unit TEXT,
            location_id INTEGER,
            expiry_date INTEGER,
            min_temp REAL,
            max_temp REAL,
            current_temp REAL,
            humidity REAL,
            status TEXT,
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
    service = InventoryService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create and read item', () async {
    final item = InventoryItem(
      sku: 'SKU001',
      name: 'Apples',
      category: 'Produce',
      quantity: 100,
      unit: 'kg',
    );
    final id = await service.createItem(item);
    expect(id, greaterThan(0));

    final retrieved = await service.getItemById(id);
    expect(retrieved, isNotNull);
    expect(retrieved!.sku, 'SKU001');
    expect(retrieved.name, 'Apples');
    expect(retrieved.quantity, 100);
    expect(retrieved.status, 'IN_STOCK');
  });

  test('update item', () async {
    final id = await service.createItem(InventoryItem(
      sku: 'SKU002',
      name: 'Bananas',
      category: 'Produce',
      quantity: 50,
      unit: 'kg',
    ));

    await service.updateItem(InventoryItem(
      id: id,
      sku: 'SKU002',
      name: 'Bananas',
      category: 'Produce',
      quantity: 60,
      unit: 'kg',
      status: 'IN_STOCK',
    ));

    final updated = await service.getItemById(id);
    expect(updated!.quantity, 60);
  });

  test('delete item', () async {
    final id = await service.createItem(InventoryItem(
      sku: 'SKU003',
      name: 'Oranges',
      category: 'Produce',
      quantity: 30,
      unit: 'kg',
    ));

    await service.deleteItem(id);
    final deleted = await service.getItemById(id);
    expect(deleted, isNull);
  });

  test('search items', () async {
    await service.createItem(InventoryItem(sku: 'A001', name: 'Apple', category: 'Produce', quantity: 10, unit: 'kg'));
    await service.createItem(InventoryItem(sku: 'B001', name: 'Banana', category: 'Produce', quantity: 20, unit: 'kg'));
    await service.createItem(InventoryItem(sku: 'M001', name: 'Milk', category: 'Dairy', quantity: 5, unit: 'L'));

    var results = await service.searchItems(query: 'Apple');
    expect(results.length, 1);
    expect(results.first.sku, 'A001');

    results = await service.searchItems(category: 'Produce');
    expect(results.length, 2);

    results = await service.searchItems(status: 'IN_STOCK');
    expect(results.length, 3);
  });

  test('change quantity', () async {
    final id = await service.createItem(InventoryItem(
      sku: 'SKU004',
      name: 'Grapes',
      category: 'Produce',
      quantity: 100,
      unit: 'kg',
    ));

    await service.changeQuantity(id, -30, operatorId: 1);
    var item = await service.getItemById(id);
    expect(item!.quantity, 70);

    await service.changeQuantity(id, 20, operatorId: 1);
    item = await service.getItemById(id);
    expect(item!.quantity, 90);
  });

  test('negative quantity throws', () async {
    final id = await service.createItem(InventoryItem(
      sku: 'SKU005',
      name: 'Test',
      category: 'Test',
      quantity: 10,
      unit: 'kg',
    ));

    expect(() => service.changeQuantity(id, -20, operatorId: 1), throwsArgumentError);
  });
}