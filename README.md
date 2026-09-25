# Cold Storage Warehouse Management System (WMS)

A comprehensive Flutter-based Warehouse Management System designed for cold storage facilities with integrated Accounts, Finance, Logistics, AI Camera Counting, Gatepass Management, and Barcode/QR Code Scanning.

## 🏗️ Architecture Overview

```
cold_storage_wms/
├── lib/
│   ├── main.dart                    # App entry point with database initialization
│   ├── models/
│   │   ├── inventory_item.dart      # Core inventory models
│   │   ├── storage_location.dart    # Location management
│   │   ├── temperature_log.dart     # Temperature monitoring
│   │   ├── transfer_record.dart     # Stock transfers
│   │   ├── finance_models.dart      # Accounts, Finance, GST models
│   │   ├── logistics_models.dart    # Carriers, Vehicles, Shipments
│   │   ├── camera_ai_models.dart    # AI Camera, Counting, ML models
│   │   └── gatepass_barcode_models.dart  # Gatepass, Barcode, Printing
│   ├── services/
│   │   ├── inventory_service.dart   # Inventory CRUD operations
│   │   ├── location_service.dart    # Location management
│   │   ├── temperature_service.dart # Temperature monitoring
│   │   ├── receiving_service.dart   # Goods receiving
│   │   ├── picking_service.dart     # Order picking
│   │   ├── dispatch_service.dart    # Dispatch operations
│   │   ├── sla_service.dart         # SLA tracking
│   │   ├── finance_service.dart     # Complete finance operations
│   │   ├── logistics_service.dart   # Logistics management
│   │   ├── camera_ai_service.dart   # AI Camera counting service
│   │   └── gatepass_barcode_service.dart  # Gatepass & Barcode service
│   └── screens/
│       ├── inventory_dashboard.dart  # Inventory management UI
│       ├── item_form.dart           # Item creation/editing
│       ├── finance_dashboard.dart   # Finance dashboard with P&L, BS
│       ├── logistics_dashboard.dart # Logistics dashboard
│       ├── camera_counting_screen.dart  # AI Camera counting UI
│       ├── gatepass_screen.dart     # Gatepass management
│       └── barcode_scanner_screen.dart  # Barcode scanning & printing
├── db/
│   └── migrations/
│       ├── 001_inventory_schema.sql  # Core inventory tables
│       ├── 002_finance_schema.sql    # Finance/Accounts tables
│       ├── 003_logistics_schema.sql  # Logistics tables
│       ├── 004_camera_ai_schema.sql  # AI Camera tables
│       └── 005_gatepass_barcode_schema.sql  # Gatepass & Barcode tables
├── assets/
│   ├── images/
│   ├── models/          # TFLite models for AI
│   ├── labels/          # Label templates
│   └── fonts/
└── pubspec.yaml
```

## 📦 Modules

### 1. **Inventory Management**
- Item master (SKU, categories, units, expiry tracking)
- Multi-location storage with zone/aisle/rack/bin hierarchy
- Temperature & humidity monitoring per location
- Stock transfers between locations
- Real-time stock levels with status tracking

### 2. **Accounts & Finance**
- **Chart of Accounts** - Hierarchical account structure (Asset, Liability, Equity, Revenue, Expense)
- **Parties** - Customers & Vendors with GSTIN, PAN, credit limits, payment terms
- **Invoices** - Sales, Purchase, Credit/Debit Notes with GST calculation (CGST, SGST, IGST)
- **Payments** - Receipts & Payments with multiple modes (Cash, Bank, UPI, Card, Cheque)
- **Journal Entries** - Manual adjustments with double-entry validation
- **GST Returns** - GSTR-1, GSTR-3B preparation and filing
- **Financial Reports** - Trial Balance, Profit & Loss, Balance Sheet
- **Purchase/Sales Orders** - Complete order management

### 3. **Logistics Management**
- **Carriers** - Carrier master with ratings, documents
- **Vehicles** - Fleet management with capacity, temperature control, GPS
- **Routes** - Route planning with stops, distance, tolls
- **Shipments** - End-to-end shipment tracking with status
- **Load Planning** - 3D load optimization with weight/volume utilization
- **Freight Management** - Rate cards, freight bills, carrier payments
- **Vehicle Maintenance** - Preventive & breakdown maintenance scheduling

### 4. **AI Camera Counting** 🤖
- **Camera Devices** - IP cameras, RTSP streams, mobile cameras
- **Counting Sessions** - Loading, Unloading, Transfer, Cycle Count
- **Real-time Detection** - TensorFlow Lite integration for object detection
- **Object Tracking** - Multi-object tracking across frames
- **Count Verification** - Manual recount, supervisor approval, weight-based, barcode match
- **Camera Calibration** - Distance, count line, ROI, lens calibration
- **ML Model Registry** - Versioned model deployment (YOLO, SSD, EfficientDet)
- **Alerts** - Discrepancy, camera offline, low confidence, obstruction
- **Analytics** - Accuracy reports, camera performance metrics

### 5. **Gatepass & Dispatch**
- **Gatepass Types** - Configurable workflows (Simple, Approval, Multi-level)
- **Gatepass Management** - Full lifecycle: Draft → Submitted → Approved → Active → Completed
- **Security Gates** - Entry/Exit checkpoints with camera integration
- **Vehicle Logs** - Entry/exit tracking with seal verification
- **Approval Workflow** - Multi-level approval with delegation
- **Dispatch Scheduling** - Loading bay assignment, time slots
- **QR Codes** - Digital gatepass with QR for verification
- **Weighbridge Integration** - Gross/Tare/Net weight recording

### 6. **Barcode & QR Code System**
- **Barcode Definitions** - Code128, QR Code, DataMatrix, EAN13, UPCA, Code39
- **Label Templates** - Configurable layouts with JSON-based design
- **Barcode Generation** - Auto-generate for items, gatepasses, shipments, locations
- **Scanning** - Single scan & batch scanning sessions
- **Batch Operations** - Receiving, Dispatch, Transfer, Inventory, Gatepass verification
- **Label Printing** - ZPL/DPL/SBPL/ESCPOS printer support
- **Print Jobs** - Queued printing with status tracking
- **GS1 Support** - Application Identifiers for standardized labels

## 🗄️ Database Schema

### Core Tables (Migration 001)
- `users` - Authentication with face embeddings
- `storage_location` - Hierarchical location structure
- `inventory_item` - Stock items with temperature requirements
- `temperature_log` - IoT sensor readings
- `transfer_record` - Stock movements
- `audit_log` - System audit trail

### Finance Tables (Migration 002)
- `chart_of_accounts` - CoA with hierarchy
- `parties` - Customers/Vendors
- `tax_rates` - GST rates
- `invoices` / `invoice_items` - Complete invoicing
- `payments` / `payment_allocations` - Receipts/Payments
- `accounts_receivable` / `accounts_payable` - AR/AP
- `journal_entries` / `journal_entry_lines` - Double-entry
- `gst_returns` - GST filing
- `purchase_orders` / `sales_orders` - Order management

### Logistics Tables (Migration 003)
- `carriers` - Transport partners
- `vehicles` - Fleet
- `routes` / `route_stops` - Route planning
- `shipments` / `shipment_items` - Shipment execution
- `shipment_tracking` - GPS tracking
- `load_plans` / `load_plan_items` - Load optimization
- `freight_rates` / `freight_bills` - Freight management
- `vehicle_maintenance` - Maintenance records

### Camera AI Tables (Migration 004)
- `camera_devices` - Camera configuration
- `counting_sessions` - Counting events
- `detection_events` - Frame-level detections
- `count_verifications` - Verification workflow
- `camera_calibrations` - Calibration records
- `ml_models` - Model registry
- `camera_alerts` - Alert management

### Gatepass & Barcode Tables (Migration 005)
- `gatepass_types` - Configurable types
- `gatepass` - Enhanced gatepass
- `gatepass_items` - Line items
- `security_gates` - Checkpoints
- `gatepass_vehicle_log` - Entry/exit logs
- `gatepass_approvals` - Approval workflow
- `dispatch_schedules` - Scheduling
- `loading_bays` - Dock management
- `barcode_definitions` - Label templates
- `barcodes` - Generated barcodes
- `barcode_scans` - Scan logs
- `batch_scan_sessions` / `batch_scan_items` - Batch operations
- `label_print_jobs` - Print queue
- `printer_configs` - Printer management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0
- Android Studio / VS Code
- SQLite (via sqflite_ffi for desktop)

### Installation

```bash
# Clone the repository
cd cold_storage_wms

# Get dependencies
flutter pub get

# Generate code (for JSON serialization, Freezed, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on Android/iOS/Desktop
flutter run
```

### Database Initialization
The database is automatically created on first run with all migrations. The schema version is 6.

### AI Model Setup
1. Place your TensorFlow Lite model (.tflite) in `assets/models/`
2. Place label file (.txt) in `assets/models/`
3. Configure in Camera Device settings:
   - Model path
   - Input dimensions
   - Confidence/IoU thresholds
   - Detection classes

### Printer Configuration
1. Go to Barcode → Print Labels
2. Add printer configuration (Zebra, Datamax, SATO, Brother, Generic)
3. Configure connection (USB, Network, Bluetooth, Serial)
4. Set as default printer

## 📱 Key Features

### Real-time AI Counting
```dart
// Start a counting session
final session = await cameraService.startCountingSession(
  camera: selectedCamera,
  sessionType: 'LOADING',
  referenceType: 'GATEPASS',
  referenceId: gatepassId,
  expectedCount: 100,
  operatorId: currentUserId,
);

// Subscribe to real-time count updates
cameraService.getCountStream(session.id).listen((count) {
  setState(() => currentCount = count);
});
```

### Financial Reporting
```dart
// Get Profit & Loss
final pl = await financeService.getProfitLoss(fromDate, toDate);

// Get Balance Sheet
final bs = await financeService.getBalanceSheet(asOfDate);

// Get Trial Balance
final tb = await financeService.getTrialBalance(asOfDate);
```

### Gatepass Workflow
```dart
// Create gatepass
final gatepassId = await gatepassService.createGatepass(gatepass);

// Submit for approval
await gatepassService.submitGatepass(gatepassId, userId);

// Approve
await gatepassService.approveGatepass(gatepassId, userId);

// Activate (vehicle entry)
await gatepassService.activateGatepass(gatepassId, userId);

// Complete (vehicle exit)
await gatepassService.completeGatepass(gatepassId, userId);
```

### Batch Barcode Scanning
```dart
// Start batch session
final session = await barcodeService.createBatchScanSession(BatchScanSession(
  sessionNumber: 'BATCH-001',
  sessionType: 'RECEIVING',
  referenceId: gatepassId,
  locationId: warehouseId,
  operatorId: userId,
));

// Scan items
await barcodeService.addBatchScanItem(BatchScanItem(
  sessionId: session.id,
  barcodeValue: scannedValue,
  expectedQuantity: 10,
));

// Complete session
await barcodeService.updateBatchScanSession(session.copyWith(status: 'COMPLETED'));
```

## 🔧 Configuration

### Environment Variables
Create `.env` file:
```env
DATABASE_PATH=wms.db
CAMERA_RTSP_URL=rtsp://user:pass@ip:port/stream
ML_MODEL_PATH=assets/models/yolov8n.tflite
PRINTER_IP=192.168.1.100
PRINTER_PORT=9100
```

### Camera Configuration
```dart
final camera = CameraDevice(
  name: 'Loading Dock Camera',
  code: 'CAM-LD-01',
  deviceType: 'FIXED',
  rtspUrl: 'rtsp://admin:pass@192.168.1.50:554/stream1',
  resolutionWidth: 1920,
  resolutionHeight: 1080,
  fps: 30,
  modelPath: 'assets/models/yolov8n.tflite',
  confidenceThreshold: 0.5,
  countDirection: 'IN',
  roiCoordinates: '[[100,100],[500,100],[500,400],[100,400]]',
);
```

## 📊 Dashboard Widgets

The app includes 6 main dashboard tabs:
1. **Inventory** - Stock levels, expiries, transfers
2. **Finance** - P&L, Balance Sheet, AR/AP aging
3. **Logistics** - Shipments, vehicles, carrier performance
4. **AI Camera** - Live counting, verification, calibration
5. **Gatepass** - Gatepass lifecycle, dispatch scheduling
6. **Barcode** - Scanning, batch operations, label printing

## 🔐 Security Features
- User authentication with roles
- Face recognition for sensitive operations
- OTP-based verification
- Audit logging for all critical operations
- Gatepass security pins
- Biometric verification at checkpoints
- QR code validation with timestamp

## 📈 Reporting & Analytics
- Financial reports (P&L, BS, Trial Balance, GST)
- Inventory reports (Stock, Expiry, Movement)
- Logistics reports (Carrier performance, Vehicle utilization)
- Camera accuracy reports
- Gatepass turnaround time
- Barcode scan analytics

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📦 Building for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows/Linux/macOS
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

## 🤝 Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License
MIT License - See LICENSE file for details.

## 🆘 Support
For issues and feature requests, please create an issue in the repository.

---

**Built with ❤️ using Flutter & SQLite**