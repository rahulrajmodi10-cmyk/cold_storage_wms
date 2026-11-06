// lib/constants/status_enums.dart

enum InventoryStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  lowStock('LOW_STOCK'),
  outOfStock('OUT_OF_STOCK'),
  expired('EXPIRED'),
  damaged('DAMAGED'),
  quarantined('QUARANTINED'),
  reserved('RESERVED'),
  inTransit('IN_TRANSIT');

  const InventoryStatus(this.value);
  final String value;

  static InventoryStatus? fromString(String? value) {
    if (value == null) return null;
    return InventoryStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InventoryStatus.active,
    );
  }
}

enum GatepassStatus {
  draft('DRAFT'),
  submitted('SUBMITTED'),
  approved('APPROVED'),
  rejected('REJECTED'),
  active('ACTIVE'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  expired('EXPIRED');

  const GatepassStatus(this.value);
  final String value;

  static GatepassStatus? fromString(String? value) {
    if (value == null) return null;
    return GatepassStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GatepassStatus.draft,
    );
  }
}

enum GatepassPriority {
  low('LOW'),
  normal('NORMAL'),
  high('HIGH'),
  urgent('URGENT');

  const GatepassPriority(this.value);
  final String value;

  static GatepassPriority? fromString(String? value) {
    if (value == null) return null;
    return GatepassPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GatepassPriority.normal,
    );
  }
}

enum ShipmentStatus {
  planned('PLANNED'),
  scheduled('SCHEDULED'),
  inTransit('IN_TRANSIT'),
  delivered('DELIVERED'),
  partiallyDelivered('PARTIALLY_DELIVERED'),
  returned('RETURNED'),
  cancelled('CANCELLED'),
  delayed('DELAYED');

  const ShipmentStatus(this.value);
  final String value;

  static ShipmentStatus? fromString(String? value) {
    if (value == null) return null;
    return ShipmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShipmentStatus.planned,
    );
  }
}

enum FinanceInvoiceStatus {
  draft('DRAFT'),
  pending('PENDING'),
  approved('APPROVED'),
  sent('SENT'),
  paid('PAID'),
  partiallyPaid('PARTIALLY_PAID'),
  overdue('OVERDUE'),
  cancelled('CANCELLED'),
  refunded('REFUNDED');

  const FinanceInvoiceStatus(this.value);
  final String value;

  static FinanceInvoiceStatus? fromString(String? value) {
    if (value == null) return null;
    return FinanceInvoiceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FinanceInvoiceStatus.draft,
    );
  }
}

enum PaymentStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  failed('FAILED'),
  refunded('REFUNDED'),
  cancelled('CANCELLED');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus? fromString(String? value) {
    if (value == null) return null;
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum JournalEntryStatus {
  draft('DRAFT'),
  posted('POSTED'),
  reversed('REVERSED'),
  voided('VOIDED');

  const JournalEntryStatus(this.value);
  final String value;

  static JournalEntryStatus? fromString(String? value) {
    if (value == null) return null;
    return JournalEntryStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => JournalEntryStatus.draft,
    );
  }
}

enum GstReturnStatus {
  draft('DRAFT'),
  filed('FILED'),
  revised('REVISED'),
  error('ERROR');

  const GstReturnStatus(this.value);
  final String value;

  static GstReturnStatus? fromString(String? value) {
    if (value == null) return null;
    return GstReturnStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GstReturnStatus.draft,
    );
  }
}

enum CameraDeviceType {
  fixed('FIXED'),
  mobile('MOBILE'),
  handheld('HANDHELD'),
  drone('DRONE');

  const CameraDeviceType(this.value);
  final String value;

  static CameraDeviceType? fromString(String? value) {
    if (value == null) return null;
    return CameraDeviceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CameraDeviceType.fixed,
    );
  }
}

enum CountingSessionStatus {
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  verified('VERIFIED'),
  disputed('DISPUTED'),
  cancelled('CANCELLED');

  const CountingSessionStatus(this.value);
  final String value;

  static CountingSessionStatus? fromString(String? value) {
    if (value == null) return null;
    return CountingSessionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CountingSessionStatus.inProgress,
    );
  }
}

enum CountingSessionType {
  loading('LOADING'),
  unloading('UNLOADING'),
  transfer('TRANSFER'),
  cycleCount('CYCLE_COUNT');

  const CountingSessionType(this.value);
  final String value;

  static CountingSessionType? fromString(String? value) {
    if (value == null) return null;
    return CountingSessionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CountingSessionType.loading,
    );
  }
}

enum VerificationStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  needsRecount('NEEDS_RECOUNT');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus? fromString(String? value) {
    if (value == null) return null;
    return VerificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

enum AlertSeverity {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  const AlertSeverity(this.value);
  final String value;

  static AlertSeverity? fromString(String? value) {
    if (value == null) return null;
    return AlertSeverity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AlertSeverity.medium,
    );
  }
}

enum AlertType {
  discrepancy('DISCREPANCY'),
  cameraOffline('CAMERA_OFFLINE'),
  lowConfidence('LOW_CONFIDENCE'),
  obstruction('OBSTRUCTION'),
  tampering('TAMPERING');

  const AlertType(this.value);
  final String value;

  static AlertType? fromString(String? value) {
    if (value == null) return null;
    return AlertType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AlertType.discrepancy,
    );
  }
}

enum BarcodeSymbology {
  code128('CODE128'),
  qrCode('QR_CODE'),
  dataMatrix('DATA_MATRIX'),
  ean13('EAN13'),
  upca('UPCA'),
  code39('CODE39');

  const BarcodeSymbology(this.value);
  final String value;

  static BarcodeSymbology? fromString(String? value) {
    if (value == null) return null;
    return BarcodeSymbology.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BarcodeSymbology.code128,
    );
  }
}

enum BarcodeEntityType {
  item('ITEM'),
  gatepass('GATEPASS'),
  shipment('SHIPMENT'),
  location('LOCATION'),
  pallet('PALLET'),
  batch('BATCH'),
  vehicle('VEHICLE');

  const BarcodeEntityType(this.value);
  final String value;

  static BarcodeEntityType? fromString(String? value) {
    if (value == null) return null;
    return BarcodeEntityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BarcodeEntityType.item,
    );
  }
}

enum ScanStatus {
  success('SUCCESS'),
  failed('FAILED'),
  duplicate('DUPLICATE'),
  notFound('NOT_FOUND'),
  mismatch('MISMATCH');

  const ScanStatus(this.value);
  final String value;

  static ScanStatus? fromString(String? value) {
    if (value == null) return null;
    return ScanStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ScanStatus.success,
    );
  }
}

enum PrintJobStatus {
  queued('QUEUED'),
  printing('PRINTING'),
  completed('COMPLETED'),
  failed('FAILED'),
  cancelled('CANCELLED');

  const PrintJobStatus(this.value);
  final String value;

  static PrintJobStatus? fromString(String? value) {
    if (value == null) return null;
    return PrintJobStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PrintJobStatus.queued,
    );
  }
}

enum PrinterType {
  zebraZpl('ZEBRA_ZPL'),
  datamaxDpl('DATAMAX_DPL'),
  satoSbpl('SATO_SBPL'),
  epsonEscpos('EPSON_ESCPOS'),
  generic('GENERIC');

  const PrinterType(this.value);
  final String value;

  static PrinterType? fromString(String? value) {
    if (value == null) return null;
    return PrinterType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PrinterType.generic,
    );
  }
}

enum TransferReason {
  receipt('RECEIPT'),
  issue('ISSUE'),
  transfer('TRANSFER'),
  adjustment('ADJUSTMENT'),
  return_('RETURN'),
  waste('WASTE'),
  production('PRODUCTION'),
  sales('SALES'),
  purchase('PURCHASE'),
  other('OTHER');

  const TransferReason(this.value);
  final String value;

  static TransferReason? fromString(String? value) {
    if (value == null) return null;
    return TransferReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransferReason.transfer,
    );
  }
}