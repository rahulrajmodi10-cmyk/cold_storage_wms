// lib/services/route_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/logistics_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class RouteService extends BaseRepository<Route> {
  final Database db;
  final AuditService auditService;

  RouteService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'routes',
          entityType: EntityTypes.route,
          fromMap: (m) => Route.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Route entity) => entity.toMap();

  @override
  int? getId(Route entity) => entity.id;

  @override
  Route setId(Route entity, int id) => entity..id = id;

  Future<Route?> getRoute(int id) async => getById(id);

  Future<List<Route>> getRoutes({bool activeOnly = true}) async {
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

  Future<int> createRoute(Route route, {int? userId}) async {
    return await create(route,
        action: 'create_route',
        detail: 'Created route ${route.name}',
        userId: userId);
  }

  Future<int> updateRoute(Route route, {int? userId}) async {
    return await update(route,
        action: 'update_route',
        detail: 'Updated route ${route.name}',
        userId: userId);
  }
}

class RouteStopService extends BaseRepository<RouteStop> {
  final Database db;
  final AuditService auditService;

  RouteStopService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'route_stops',
          entityType: EntityTypes.routeStop,
          fromMap: (m) => RouteStop.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(RouteStop entity) => entity.toMap();

  @override
  int? getId(RouteStop entity) => entity.id;

  @override
  RouteStop setId(RouteStop entity, int id) => entity..id = id;

  Future<List<RouteStop>> getRouteStops(int routeId) async {
    final query = QueryBuilder.where().eq('route_id', routeId).orderBy('stop_order');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addRouteStop(RouteStop stop, {int? userId}) async {
    return await create(stop,
        action: 'add_route_stop',
        detail: 'Added stop to route ${stop.routeId}',
        userId: userId);
  }
}