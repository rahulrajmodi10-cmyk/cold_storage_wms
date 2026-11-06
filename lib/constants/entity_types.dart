// lib/constants/entity_types.dart

/// Centralized entity type strings used across the application
/// for database references, audit logs, and cross-service relationships

class EntityTypes {
  // Inventory
  static const String inventoryItem = 'INVENTORY_ITEM';
  static const String storageLocation = 'STORAGE_LOCATION';
  static const String temperatureLog = 'TEMPERATURE_LOG';
  static const String transferRecord = 'TRANSFER_RECORD';

  // Finance
  static const String chartOfAccount = 'CHART_OF_ACCOUNT';
  static const String party = 'PARTY';
  static const String invoice = 'INVOICE';
  static const String invoiceItem = 'INVOICE_ITEM';
  static const String payment = 'PAYMENT';
  static const String paymentAllocation = 'PAYMENT_ALLOCATION';
  static const String journalEntry = 'JOURNAL_ENTRY';
  static const String journalEntryLine = 'JOURNAL_ENTRY_LINE';
  static const String gstReturn = 'GST_RETURN';
  static const String financialPeriod = 'FINANCIAL_PERIOD';
  static const String budget = 'BUDGET';
  static const String budgetLine = 'BUDGET_LINE';
  static const String asset = 'ASSET';
  static const String expenseClaim = 'EXPENSE_CLAIM';
  static const String purchaseOrder = 'PURCHASE_ORDER';
  static const String purchaseOrderItem = 'PURCHASE_ORDER_ITEM';
  static const String salesOrder = 'SALES_ORDER';
  static const String salesOrderItem = 'SALES_ORDER_ITEM';
  static const String accountsReceivable = 'ACCOUNTS_RECEIVABLE';
  static const String accountsPayable = 'ACCOUNTS_PAYABLE';

  // Logistics
  static const String carrier = 'CARRIER';
  static const String vehicle = 'VEHICLE';
  static const String route = 'ROUTE';
  static const String routeStop = 'ROUTE_STOP';
  static const String shipment = 'SHIPMENT';
  static const String shipmentItem = 'SHIPMENT_ITEM';
  static const String shipmentTracking = 'SHIPMENT_TRACKING';
  static const String loadPlan = 'LOAD_PLAN';
  static const String loadPlanItem = 'LOAD_PLAN_ITEM';
  static const String freightRate = 'FREIGHT_RATE';
  static const String freightBill = 'FREIGHT_BILL';
  static const String vehicleMaintenance = 'VEHICLE_MAINTENANCE';

  // Camera AI
  static const String cameraDevice = 'CAMERA_DEVICE';
  static const String countingSession = 'COUNTING_SESSION';
  static const String detectionEvent = 'DETECTION_EVENT';
  static const String countVerification = 'COUNT_VERIFICATION';
  static const String cameraCalibration = 'CAMERA_CALIBRATION';
  static const String mlModel = 'ML_MODEL';
  static const String cameraAlert = 'CAMERA_ALERT';

  // Gatepass & Barcode
  static const String gatepassType = 'GATEPASS_TYPE';
  static const String gatepass = 'GATEPASS';
  static const String gatepassItem = 'GATEPASS_ITEM';
  static const String securityGate = 'SECURITY_GATE';
  static const String gatepassVehicleLog = 'GATEPASS_VEHICLE_LOG';
  static const String gatepassApproval = 'GATEPASS_APPROVAL';
  static const String dispatchSchedule = 'DISPATCH_SCHEDULE';
  static const String loadingBay = 'LOADING_BAY';
  static const String barcodeDefinition = 'BARCODE_DEFINITION';
  static const String barcode = 'BARCODE';
  static const String barcodeScan = 'BARCODE_SCAN';
  static const String batchScanSession = 'BATCH_SCAN_SESSION';
  static const String batchScanItem = 'BATCH_SCAN_ITEM';
  static const String labelPrintJob = 'LABEL_PRINT_JOB';
  static const String printerConfig = 'PRINTER_CONFIG';

  // User & Auth
  static const String user = 'USER';
  static const String role = 'ROLE';
  static const String permission = 'PERMISSION';
  static const String auditLog = 'AUDIT_LOG';

  /// All entity types as a list for iteration/validation
  static const List<String> all = [
    inventoryItem,
    storageLocation,
    temperatureLog,
    transferRecord,
    chartOfAccount,
    party,
    invoice,
    invoiceItem,
    payment,
    paymentAllocation,
    journalEntry,
    journalEntryLine,
    gstReturn,
    financialPeriod,
    budget,
    budgetLine,
    asset,
    expenseClaim,
    purchaseOrder,
    purchaseOrderItem,
    salesOrder,
    salesOrderItem,
    accountsReceivable,
    accountsPayable,
    carrier,
    vehicle,
    route,
    routeStop,
    shipment,
    shipmentItem,
    shipmentTracking,
    loadPlan,
    loadPlanItem,
    freightRate,
    freightBill,
    vehicleMaintenance,
    cameraDevice,
    countingSession,
    detectionEvent,
    countVerification,
    cameraCalibration,
    mlModel,
    cameraAlert,
    gatepassType,
    gatepass,
    gatepassItem,
    securityGate,
    gatepassVehicleLog,
    gatepassApproval,
    dispatchSchedule,
    loadingBay,
    barcodeDefinition,
    barcode,
    barcodeScan,
    batchScanSession,
    batchScanItem,
    labelPrintJob,
    printerConfig,
    user,
    role,
    permission,
    auditLog,
  ];

  /// Map of entity type to table name (snake_case)
  static const Map<String, String> tableNames = {
    inventoryItem: 'inventory_items',
    storageLocation: 'storage_locations',
    temperatureLog: 'temperature_logs',
    transferRecord: 'transfer_records',
    chartOfAccount: 'chart_of_accounts',
    party: 'parties',
    invoice: 'invoices',
    invoiceItem: 'invoice_items',
    payment: 'payments',
    paymentAllocation: 'payment_allocations',
    journalEntry: 'journal_entries',
    journalEntryLine: 'journal_entry_lines',
    gstReturn: 'gst_returns',
    financialPeriod: 'financial_periods',
    budget: 'budgets',
    budgetLine: 'budget_lines',
    asset: 'assets',
    expenseClaim: 'expense_claims',
    purchaseOrder: 'purchase_orders',
    purchaseOrderItem: 'purchase_order_items',
    salesOrder: 'sales_orders',
    salesOrderItem: 'sales_order_items',
    accountsReceivable: 'accounts_receivable',
    accountsPayable: 'accounts_payable',
    carrier: 'carriers',
    vehicle: 'vehicles',
    route: 'routes',
    routeStop: 'route_stops',
    shipment: 'shipments',
    shipmentItem: 'shipment_items',
    shipmentTracking: 'shipment_tracking',
    loadPlan: 'load_plans',
    loadPlanItem: 'load_plan_items',
    freightRate: 'freight_rates',
    freightBill: 'freight_bills',
    vehicleMaintenance: 'vehicle_maintenance',
    cameraDevice: 'camera_devices',
    countingSession: 'counting_sessions',
    detectionEvent: 'detection_events',
    countVerification: 'count_verifications',
    cameraCalibration: 'camera_calibrations',
    mlModel: 'ml_models',
    cameraAlert: 'camera_alerts',
    gatepassType: 'gatepass_types',
    gatepass: 'gatepasses',
    gatepassItem: 'gatepass_items',
    securityGate: 'security_gates',
    gatepassVehicleLog: 'gatepass_vehicle_logs',
    gatepassApproval: 'gatepass_approvals',
    dispatchSchedule: 'dispatch_schedules',
    loadingBay: 'loading_bays',
    barcodeDefinition: 'barcode_definitions',
    barcode: 'barcodes',
    barcodeScan: 'barcode_scans',
    batchScanSession: 'batch_scan_sessions',
    batchScanItem: 'batch_scan_items',
    labelPrintJob: 'label_print_jobs',
    printerConfig: 'printer_configs',
    user: 'users',
    role: 'roles',
    permission: 'permissions',
    auditLog: 'audit_logs',
  };

  /// Get table name for an entity type
  static String? getTableName(String entityType) {
    return tableNames[entityType];
  }

  /// Check if an entity type is valid
  static bool isValid(String entityType) {
    return all.contains(entityType);
  }
}

/// Reference type strings for cross-entity references
class ReferenceTypes {
  // Inventory references
  static const String inventoryItem = 'INVENTORY_ITEM';
  static const String storageLocation = 'STORAGE_LOCATION';

  // Finance references
  static const String invoice = 'INVOICE';
  static const String payment = 'PAYMENT';
  static const String journalEntry = 'JOURNAL_ENTRY';
  static const String party = 'PARTY';

  // Logistics references
  static const String shipment = 'SHIPMENT';
  static const String carrier = 'CARRIER';
  static const String vehicle = 'VEHICLE';
  static const String route = 'ROUTE';

  // Camera AI references
  static const String countingSession = 'COUNTING_SESSION';
  static const String cameraDevice = 'CAMERA_DEVICE';
  static const String mlModel = 'ML_MODEL';

  // Gatepass references
  static const String gatepass = 'GATEPASS';
  static const String gatepassType = 'GATEPASS_TYPE';
  static const String securityGate = 'SECURITY_GATE';
  static const String loadingBay = 'LOADING_BAY';

  // Barcode references
  static const String barcode = 'BARCODE';
  static const String barcodeDefinition = 'BARCODE_DEFINITION';
  static const String batchScanSession = 'BATCH_SCAN_SESSION';

  static const List<String> all = [
    inventoryItem,
    storageLocation,
    invoice,
    payment,
    journalEntry,
    party,
    shipment,
    carrier,
    vehicle,
    route,
    countingSession,
    cameraDevice,
    mlModel,
    gatepass,
    gatepassType,
    securityGate,
    loadingBay,
    barcode,
    barcodeDefinition,
    batchScanSession,
  ];
}

/// Module identifiers for service organization
class Modules {
  static const String inventory = 'inventory';
  static const String finance = 'finance';
  static const String logistics = 'logistics';
  static const String cameraAi = 'camera_ai';
  static const String gatepass = 'gatepass';
  static const String barcode = 'barcode';
  static const String auth = 'auth';
  static const String settings = 'settings';

  static const List<String> all = [
    inventory,
    finance,
    logistics,
    cameraAi,
    gatepass,
    barcode,
    auth,
    settings,
  ];
}