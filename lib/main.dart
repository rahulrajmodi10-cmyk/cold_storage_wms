// lib/main.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:get_it/get_it.dart';
import 'screens/inventory_dashboard.dart';
import 'screens/item_form.dart';
import 'screens/finance_dashboard.dart';
import 'screens/logistics_dashboard.dart';
import 'screens/camera_counting_screen.dart';
import 'screens/gatepass_screen.dart';
import 'screens/barcode_scanner_screen.dart';
import 'services/inventory_service.dart';
import 'services/location_service.dart';
import 'services/temperature_service.dart';
import 'services/receiving_service.dart';
import 'services/picking_service.dart';
import 'services/dispatch_service.dart';
import 'services/sla_service.dart';
import 'services/chart_of_accounts_service.dart';
import 'services/party_service.dart';
import 'services/tax_rate_service.dart';
import 'services/invoice_service.dart';
import 'services/payment_service.dart';
import 'services/accounts_receivable_payable_service.dart';
import 'services/journal_entry_service.dart';
import 'services/gst_return_service.dart';
import 'services/purchase_order_service.dart';
import 'services/sales_order_service.dart';
import 'services/financial_report_service.dart';
import 'services/finance_service.dart';
import 'services/carrier_vehicle_service.dart';
import 'services/route_service.dart';
import 'services/shipment_service.dart';
import 'services/freight_service.dart';
import 'services/logistics_analytics_service.dart';
import 'services/gatepass_service.dart';
import 'services/gatepass_item_service.dart';
import 'services/security_gate_service.dart';
import 'services/gatepass_vehicle_log_service.dart';
import 'services/gatepass_approval_service.dart';
import 'services/dispatch_schedule_service.dart';
import 'services/loading_bay_service.dart';
import 'services/gatepass_type_service.dart';
import 'services/barcode_definition_service.dart';
import 'services/barcode_service.dart';
import 'services/barcode_scan_service.dart';
import 'services/batch_scan_session_service.dart';
import 'services/batch_scan_item_service.dart';
import 'services/label_print_service.dart';
import 'services/printer_config_service.dart';
import 'services/gatepass_analytics_service.dart';
import 'services/camera_ai_service.dart';
import 'db/migrations/migration_registry.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await _initDatabase();
  _setupServiceLocator(db);
  runApp(const ColdStorageWMS());
}

Future<Database> _initDatabase() async {
  final path = join(await getDatabasesPath(), 'wms.db');
  return await openDatabase(
    path,
    version: MigrationRegistry.currentVersion,
    onCreate: (db, version) async {
      await MigrationRegistry.runMigrationsUpTo(db, version);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await MigrationRegistry.runMigrationsFromTo(db, oldVersion, newVersion);
    },
  );
}

void _setupServiceLocator(Database db) {
  // Register database
  getIt.registerSingleton<Database>(db);

  // Register services as singletons
  getIt.registerSingleton<InventoryService>(InventoryService(db));
  getIt.registerSingleton<LocationService>(LocationService(db));
  getIt.registerSingleton<TemperatureService>(TemperatureService(db));
  getIt.registerSingleton<ReceivingService>(ReceivingService(db));
  getIt.registerSingleton<PickingService>(PickingService(db));
  getIt.registerSingleton<DispatchService>(DispatchService(db));
  getIt.registerSingleton<SLAService>(SLAService(db, interval: const Duration(minutes: 1)));

  // Finance services (decomposed from FinanceService)
  getIt.registerSingleton<ChartOfAccountsService>(ChartOfAccountsService(db));
  getIt.registerSingleton<PartyService>(PartyService(db));
  getIt.registerSingleton<TaxRateService>(TaxRateService(db));
  getIt.registerSingleton<InvoiceService>(InvoiceService(db));
  getIt.registerSingleton<InvoiceItemService>(InvoiceItemService(db));
  getIt.registerSingleton<PaymentService>(PaymentService(db));
  getIt.registerSingleton<AccountsReceivableService>(AccountsReceivableService(db));
  getIt.registerSingleton<AccountsPayableService>(AccountsPayableService(db));
  getIt.registerSingleton<JournalEntryService>(JournalEntryService(db));
  getIt.registerSingleton<JournalEntryLineService>(JournalEntryLineService(db));
  getIt.registerSingleton<FinanceService>(FinanceService(db));
  getIt.registerSingleton<GSTReturnService>(GSTReturnService(db));
  getIt.registerSingleton<PurchaseOrderService>(PurchaseOrderService(db));
  getIt.registerSingleton<PurchaseOrderItemService>(PurchaseOrderItemService(db));
  getIt.registerSingleton<SalesOrderService>(SalesOrderService(db));
  getIt.registerSingleton<SalesOrderItemService>(SalesOrderItemService(db));
  getIt.registerSingleton<FinancialReportService>(FinancialReportService(db));

  // Logistics services (decomposed from LogisticsService)
  getIt.registerSingleton<CarrierService>(CarrierService(db));
  getIt.registerSingleton<VehicleService>(VehicleService(db));
  getIt.registerSingleton<RouteService>(RouteService(db));
  getIt.registerSingleton<RouteStopService>(RouteStopService(db));
  getIt.registerSingleton<ShipmentService>(ShipmentService(db));
  getIt.registerSingleton<ShipmentItemService>(ShipmentItemService(db));
  getIt.registerSingleton<ShipmentTrackingService>(ShipmentTrackingService(db));
  getIt.registerSingleton<FreightRateService>(FreightRateService(db));
  getIt.registerSingleton<FreightBillService>(FreightBillService(db));
  getIt.registerSingleton<LoadPlanService>(LoadPlanService(db));
  getIt.registerSingleton<LoadPlanItemService>(LoadPlanItemService(db));
  getIt.registerSingleton<VehicleMaintenanceService>(VehicleMaintenanceService(db));
  getIt.registerSingleton<LogisticsAnalyticsService>(LogisticsAnalyticsService(db));

  // Gatepass services (decomposed from GatepassBarcodeService)
  getIt.registerSingleton<GatepassTypeService>(GatepassTypeService(db));
  getIt.registerSingleton<GatepassService>(GatepassService(db));
  getIt.registerSingleton<GatepassItemService>(GatepassItemService(db));
  getIt.registerSingleton<SecurityGateService>(SecurityGateService(db));
  getIt.registerSingleton<GatepassVehicleLogService>(GatepassVehicleLogService(db));
  getIt.registerSingleton<GatepassApprovalService>(GatepassApprovalService(db));
  getIt.registerSingleton<DispatchScheduleService>(DispatchScheduleService(db));
  getIt.registerSingleton<LoadingBayService>(LoadingBayService(db));

  // Barcode services (decomposed from GatepassBarcodeService)
  getIt.registerSingleton<BarcodeDefinitionService>(BarcodeDefinitionService(db));
  getIt.registerSingleton<BarcodeService>(BarcodeService(db));
  getIt.registerSingleton<BarcodeScanService>(BarcodeScanService(db));
  getIt.registerSingleton<BatchScanSessionService>(BatchScanSessionService(db));
  getIt.registerSingleton<BatchScanItemService>(BatchScanItemService(db));
  getIt.registerSingleton<LabelPrintJobService>(LabelPrintJobService(db));
  getIt.registerSingleton<PrinterConfigService>(PrinterConfigService(db));
  getIt.registerSingleton<GatepassAnalyticsService>(GatepassAnalyticsService(db));

  getIt.registerSingleton<CameraAIService>(CameraAIService(db));
}

class ColdStorageWMS extends StatelessWidget {
  const ColdStorageWMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cold Storage WMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      InventoryDashboard(
        inventoryService: getIt<InventoryService>(),
        locationService: getIt<LocationService>(),
      ),
      FinanceDashboard(
        chartOfAccountsService: getIt<ChartOfAccountsService>(),
        financeService: getIt<FinanceService>(),
        taxRateService: getIt<TaxRateService>(),
        invoiceService: getIt<InvoiceService>(),
        paymentService: getIt<PaymentService>(),
        accountsReceivableService: getIt<AccountsReceivableService>(),
        accountsPayableService: getIt<AccountsPayableService>(),
        journalEntryService: getIt<JournalEntryService>(),
        gstReturnService: getIt<GSTReturnService>(),
        purchaseOrderService: getIt<PurchaseOrderService>(),
        salesOrderService: getIt<SalesOrderService>(),
        financialReportService: getIt<FinancialReportService>(),
      ),
      LogisticsDashboard(
        carrierService: getIt<CarrierService>(),
        vehicleService: getIt<VehicleService>(),
        shipmentService: getIt<ShipmentService>(),
        shipmentItemService: getIt<ShipmentItemService>(),
        shipmentTrackingService: getIt<ShipmentTrackingService>(),
        freightRateService: getIt<FreightRateService>(),
        freightBillService: getIt<FreightBillService>(),
        loadPlanService: getIt<LoadPlanService>(),
        loadPlanItemService: getIt<LoadPlanItemService>(),
        vehicleMaintenanceService: getIt<VehicleMaintenanceService>(),
        logisticsAnalyticsService: getIt<LogisticsAnalyticsService>(),
      ),
      CameraCountingScreen(
        cameraService: getIt<CameraAIService>(),
        gatepassService: getIt<GatepassService>(),
      ),
      GatepassScreen(
        gatepassTypeService: getIt<GatepassTypeService>(),
        gatepassService: getIt<GatepassService>(),
        gatepassItemService: getIt<GatepassItemService>(),
        securityGateService: getIt<SecurityGateService>(),
        gatepassVehicleLogService: getIt<GatepassVehicleLogService>(),
        gatepassApprovalService: getIt<GatepassApprovalService>(),
        dispatchScheduleService: getIt<DispatchScheduleService>(),
        loadingBayService: getIt<LoadingBayService>(),
        inventoryService: getIt<InventoryService>(),
        barcodeService: getIt<BarcodeService>(),
      ),
      BarcodeScannerScreen(
        barcodeDefinitionService: getIt<BarcodeDefinitionService>(),
        barcodeService: getIt<BarcodeService>(),
        barcodeScanService: getIt<BarcodeScanService>(),
        batchScanSessionService: getIt<BatchScanSessionService>(),
        batchScanItemService: getIt<BatchScanItemService>(),
        labelPrintJobService: getIt<LabelPrintJobService>(),
        printerConfigService: getIt<PrinterConfigService>(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.account_balance), label: 'Finance'),
          NavigationDestination(icon: Icon(Icons.local_shipping), label: 'Logistics'),
          NavigationDestination(icon: Icon(Icons.videocam), label: 'AI Camera'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Gatepass'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Barcode'),
        ],
      ),
    );
  }
}