// lib/providers.dart
// Riverpod state management providers for Cold Storage WMS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'services/inventory_service.dart';
import 'services/location_service.dart';
import 'services/temperature_service.dart';
import 'services/finance_service.dart';
import 'services/logistics_service.dart';
import 'services/camera_ai_service.dart';
import 'services/gatepass_barcode_service.dart';
import 'services/receiving_service.dart';
import 'services/picking_service.dart';
import 'services/dispatch_service.dart';
import 'services/sla_service.dart';
import 'services/audit_service.dart';
import 'services/auth_service.dart';

// Database provider - holds the database connection
final databaseProvider = Provider<Database>((ref) {
  throw Exception('Database not initialized. Call initializeDatabaseProvider first.');
});

// Service providers - each service is created with the database from the provider
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryService(db);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final db = ref.watch(databaseProvider);
  return LocationService(db);
});

final temperatureServiceProvider = Provider<TemperatureService>((ref) {
  final db = ref.watch(databaseProvider);
  return TemperatureService(db);
});

final financeServiceProvider = Provider<FinanceService>((ref) {
  final db = ref.watch(databaseProvider);
  return FinanceService(db);
});

final logisticsServiceProvider = Provider<LogisticsService>((ref) {
  final db = ref.watch(databaseProvider);
  return LogisticsService(db);
});

final cameraAiServiceProvider = Provider<CameraAIService>((ref) {
  final db = ref.watch(databaseProvider);
  return CameraAIService(db);
});

final gatepassBarcodeServiceProvider = Provider<GatepassBarcodeService>((ref) {
  final db = ref.watch(databaseProvider);
  return GatepassBarcodeService(db);
});

final receivingServiceProvider = Provider<ReceivingService>((ref) {
  final db = ref.watch(databaseProvider);
  return ReceivingService(db);
});

final pickingServiceProvider = Provider<PickingService>((ref) {
  final db = ref.watch(databaseProvider);
  return PickingService(db);
});

final dispatchServiceProvider = Provider<DispatchService>((ref) {
  final db = ref.watch(databaseProvider);
  return DispatchService(db);
});

final slaServiceProvider = Provider<SLAService>((ref) {
  final db = ref.watch(databaseProvider);
  return SLAService(db);
});

final auditServiceProvider = Provider<AuditService>((ref) {
  final db = ref.watch(databaseProvider);
  return AuditService(db);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final db = ref.watch(databaseProvider);
  final auditService = ref.watch(auditServiceProvider);
  return AuthService(db, auditService: auditService);
});

// Current user state provider
class UserState {
  final int userId;
  final String username;
  final String role;
  final bool isLoggedIn;

  const UserState({
    required this.userId,
    required this.username,
    required this.role,
    required this.isLoggedIn,
  });

  UserState copyWith({
    int? userId,
    String? username,
    String? role,
    bool? isLoggedIn,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

final userStateProvider = StateProvider<UserState>((ref) {
  return const UserState(userId: 0, username: '', role: '', isLoggedIn: false);
});

// Background monitoring controller
final temperatureMonitoringProvider = StateProvider<bool>((ref) {
  return false;
});