// lib/services/carrier_vehicle_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/logistics_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class CarrierService extends BaseRepository<Carrier> {
  final Database db;
  final AuditService auditService;

  CarrierService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'carriers',
          entityType: EntityTypes.carrier,
          fromMap: (m) => Carrier.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Carrier entity) => entity.toMap();

  @override
  int? getId(Carrier entity) => entity.id;

  @override
  Carrier setId(Carrier entity, int id) => entity..id = id;

  Future<Carrier?> getCarrier(int id) async => getById(id);

  Future<List<Carrier>> getCarriers({bool activeOnly = true}) async {
    final query = QueryBuilder.where();
    if (activeOnly) query.eq('is_active', 1);
    query.orderBy('name');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createCarrier(Carrier carrier, {int? userId}) async {
    return await create(carrier,
        action: 'create_carrier',
        detail: 'Created carrier ${carrier.name}',
        userId: userId);
  }

  Future<int> updateCarrier(Carrier carrier, {int? userId}) async {
    return await update(carrier,
        action: 'update_carrier',
        detail: 'Updated carrier ${carrier.name}',
        userId: userId);
  }
}

class VehicleService extends BaseRepository<Vehicle> {
  final Database db;
  final AuditService auditService;

  VehicleService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'vehicles',
          entityType: EntityTypes.vehicle,
          fromMap: (m) => Vehicle.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Vehicle entity) => entity.toMap();

  @override
  int? getId(Vehicle entity) => entity.id;

  @override
  Vehicle setId(Vehicle entity, int id) => entity..id = id;

  Future<Vehicle?> getVehicle(int id) async => getById(id);

  Future<Vehicle?> getVehicleByRegistration(String registrationNumber) async {
    final query = QueryBuilder.where().eq('registration_number', registrationNumber);
    final queryMap = query.build();
    final results = await list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Vehicle>> getVehicles({
    String? status,
    int? carrierId,
    bool activeOnly = true,
  }) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (carrierId != null) query.eq('carrier_id', carrierId);
    if (activeOnly) query.eq('is_active', 1);
    query.orderBy('registration_number');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createVehicle(Vehicle vehicle, {int? userId}) async {
    return await create(vehicle,
        action: 'create_vehicle',
        detail: 'Created vehicle ${vehicle.registrationNumber}',
        userId: userId);
  }

  Future<int> updateVehicle(Vehicle vehicle, {int? userId}) async {
    return await update(vehicle,
        action: 'update_vehicle',
        detail: 'Updated vehicle ${vehicle.registrationNumber}',
        userId: userId);
  }

  Future<int> updateVehicleStatus(int id, String status, {int? userId}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Vehicle not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_vehicle_status',
        detail: 'Vehicle status changed to $status',
        entityType: EntityTypes.vehicle,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}