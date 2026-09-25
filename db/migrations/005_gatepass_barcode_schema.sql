-- Gatepass & Dispatch Module Schema (Enhanced)

-- Gatepass Types
CREATE TABLE gatepass_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  workflow_type TEXT, -- SIMPLE, APPROVAL_REQUIRED, MULTI_LEVEL_APPROVAL
  requires_vehicle INTEGER DEFAULT 1,
  requires_driver INTEGER DEFAULT 1,
  requires_security_check INTEGER DEFAULT 1,
  validity_hours INTEGER DEFAULT 24,
  color_code TEXT, -- For UI
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
);

-- Gatepass (Enhanced)
CREATE TABLE gatepass (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  gatepass_number TEXT UNIQUE NOT NULL,
  gatepass_type_id INTEGER NOT NULL,
  reference_type TEXT, -- SALES_ORDER, PURCHASE_ORDER, TRANSFER, RETURN, SCRAP, OTHER
  reference_id INTEGER,
  party_id INTEGER, -- Customer/Vendor
  status TEXT DEFAULT 'DRAFT', -- DRAFT, SUBMITTED, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED, EXPIRED
  priority TEXT DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH, URGENT

  -- Vehicle Details
  vehicle_id INTEGER,
  vehicle_number TEXT,
  vehicle_type TEXT,
  driver_name TEXT,
  driver_phone TEXT,
  driver_license TEXT,
  driver_photo_path TEXT,

  -- Timing
  requested_date INTEGER,
  approved_date INTEGER,
  valid_from INTEGER,
  valid_to INTEGER,
  actual_entry_time INTEGER,
  actual_exit_time INTEGER,

  -- Locations
  entry_gate_id INTEGER,
  exit_gate_id INTEGER,
  origin_location TEXT,
  destination_location TEXT,

  -- Security
  security_officer_id INTEGER,
  security_check_status TEXT, -- PENDING, CLEARED, FLAGGED
  security_notes TEXT,
  seal_number TEXT,
  seal_intact INTEGER DEFAULT 1,

  -- QR Code
  qr_code_data TEXT,
  qr_code_image_path TEXT,
  qr_generated_at INTEGER,

  -- Counts
  total_items INTEGER DEFAULT 0,
  total_quantity REAL DEFAULT 0,
  total_weight REAL DEFAULT 0,
  total_packages INTEGER DEFAULT 0,

  -- Verification
  verified_by INTEGER,
  verified_at INTEGER,
  verification_method TEXT, -- MANUAL, CAMERA_AI, BARCODE, WEIGHT
  discrepancy_notes TEXT,

  -- Approval
  approved_by INTEGER,
  approved_at INTEGER,
  rejection_reason TEXT,

  -- Completion
  completed_by INTEGER,
  completed_at INTEGER,
  completion_notes TEXT,

  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,

  FOREIGN KEY (gatepass_type_id) REFERENCES gatepass_types(id),
  FOREIGN KEY (party_id) REFERENCES parties(id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (entry_gate_id) REFERENCES security_gates(id),
  FOREIGN KEY (exit_gate_id) REFERENCES security_gates(id),
  FOREIGN KEY (security_officer_id) REFERENCES users(id),
  FOREIGN KEY (verified_by) REFERENCES users(id),
  FOREIGN KEY (approved_by) REFERENCES users(id),
  FOREIGN KEY (completed_by) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Gatepass Items
CREATE TABLE gatepass_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  gatepass_id INTEGER NOT NULL,
  item_id INTEGER,
  description TEXT,
  hsn_code TEXT,
  quantity REAL NOT NULL,
  unit TEXT,
  weight_per_unit REAL,
  total_weight REAL,
  packages INTEGER DEFAULT 1,
  package_type TEXT, -- BOX, PALLET, CRATE, DRUM, BAG, LOOSE
  temperature_required INTEGER DEFAULT 0,
  min_temp REAL,
  max_temp REAL,
  batch_number TEXT,
  expiry_date INTEGER,
  -- Verification
  verified_quantity REAL DEFAULT 0,
  verified_weight REAL DEFAULT 0,
  verified_packages INTEGER DEFAULT 0,
  verification_status TEXT DEFAULT 'PENDING', -- PENDING, VERIFIED, SHORT, EXCESS, DAMAGED
  verification_notes TEXT,
  FOREIGN KEY (gatepass_id) REFERENCES gatepass(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES inventory_item(id)
);

-- Security Gates
CREATE TABLE security_gates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  gate_type TEXT, -- ENTRY, EXIT, BOTH
  location_description TEXT,
  latitude REAL,
  longitude REAL,
  camera_id INTEGER,
  barrier_type TEXT, -- MANUAL, AUTOMATIC, BOOM, TURNSTILE
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (camera_id) REFERENCES camera_devices(id)
);

-- Gatepass Vehicle Log (Entry/Exit tracking)
CREATE TABLE gatepass_vehicle_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  gatepass_id INTEGER NOT NULL,
  gate_id INTEGER NOT NULL,
  log_type TEXT NOT NULL, -- ENTRY, EXIT
  vehicle_number TEXT,
  driver_name TEXT,
  driver_verified INTEGER DEFAULT 0,
  seal_number TEXT,
  seal_verified INTEGER DEFAULT 0,
  seal_intact INTEGER DEFAULT 1,
  photos TEXT, -- JSON array of photo paths
  officer_id INTEGER,
  timestamp INTEGER,
  notes TEXT,
  FOREIGN KEY (gatepass_id) REFERENCES gatepass(id) ON DELETE CASCADE,
  FOREIGN KEY (gate_id) REFERENCES security_gates(id),
  FOREIGN KEY (officer_id) REFERENCES users(id)
);

-- Gatepass Approval Workflow
CREATE TABLE gatepass_approvals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  gatepass_id INTEGER NOT NULL,
  level INTEGER NOT NULL,
  approver_role TEXT,
  approver_id INTEGER,
  status TEXT DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, DELEGATED
  action_at INTEGER,
  comments TEXT,
  delegated_to INTEGER,
  FOREIGN KEY (gatepass_id) REFERENCES gatepass(id) ON DELETE CASCADE,
  FOREIGN KEY (approver_id) REFERENCES users(id),
  FOREIGN KEY (delegated_to) REFERENCES users(id)
);

-- Dispatch Scheduling
CREATE TABLE dispatch_schedules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  schedule_number TEXT UNIQUE NOT NULL,
  schedule_date INTEGER NOT NULL,
  shift TEXT, -- MORNING, AFTERNOON, NIGHT
  gatepass_id INTEGER,
  shipment_id INTEGER,
  vehicle_id INTEGER,
  driver_id INTEGER,
  loading_bay_id INTEGER,
  scheduled_start INTEGER,
  scheduled_end INTEGER,
  actual_start INTEGER,
  actual_end INTEGER,
  status TEXT DEFAULT 'SCHEDULED', -- SCHEDULED, IN_PROGRESS, COMPLETED, DELAYED, CANCELLED
  priority INTEGER DEFAULT 0,
  assigned_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (gatepass_id) REFERENCES gatepass(id),
  FOREIGN KEY (shipment_id) REFERENCES shipments(id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (driver_id) REFERENCES users(id),
  FOREIGN KEY (loading_bay_id) REFERENCES loading_bays(id),
  FOREIGN KEY (assigned_by) REFERENCES users(id)
);

-- Loading Bays
CREATE TABLE loading_bays (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  bay_type TEXT, -- LOADING, UNLOADING, BOTH
  dock_level INTEGER DEFAULT 0, -- 0=ground, 1=dock height
  max_vehicle_length REAL,
  max_vehicle_weight REAL,
  temperature_controlled INTEGER DEFAULT 0,
  min_temp REAL,
  max_temp REAL,
  camera_id INTEGER,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (camera_id) REFERENCES camera_devices(id)
);

-- ============================================
-- Barcode/QR Code Module Schema
-- ============================================

-- Barcode Definitions (for label templates)
CREATE TABLE barcode_definitions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  symbology TEXT NOT NULL, -- CODE128, QR_CODE, DATA_MATRIX, EAN13, UPCA, CODE39
  prefix TEXT,
  suffix TEXT,
  format_template TEXT, -- e.g., "GP-{gatepass_number}-{sequence}"
  width_mm REAL,
  height_mm REAL,
  module_width REAL, -- narrow bar width
  include_text INTEGER DEFAULT 1,
  font_size INTEGER,
  error_correction TEXT, -- L, M, Q, H (for QR)
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
);

-- Generated Barcodes/Labels
CREATE TABLE barcodes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  barcode_value TEXT UNIQUE NOT NULL,
  barcode_type_id INTEGER NOT NULL,
  entity_type TEXT NOT NULL, -- ITEM, GATEPASS, SHIPMENT, LOCATION, PALLET, BATCH, VEHICLE
  entity_id INTEGER NOT NULL,
  label_data TEXT, -- JSON with all label fields
  image_path TEXT,
  print_count INTEGER DEFAULT 0,
  last_printed_at INTEGER,
  printed_by INTEGER,
  status TEXT DEFAULT 'ACTIVE', -- ACTIVE, VOIDED, REPLACED
  expires_at INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (barcode_type_id) REFERENCES barcode_definitions(id),
  FOREIGN KEY (printed_by) REFERENCES users(id)
);

-- Barcode Scan Logs
CREATE TABLE barcode_scans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  scan_session_id INTEGER,
  barcode_value TEXT NOT NULL,
  barcode_id INTEGER,
  entity_type TEXT,
  entity_id INTEGER,
  scan_type TEXT, -- RECEIVING, PICKING, PACKING, DISPATCH, TRANSFER, CYCLE_COUNT, GATEPASS_VERIFY
  location_id INTEGER,
  scanned_by INTEGER,
  device_id TEXT, -- Scanner device ID
  latitude REAL,
  longitude REAL,
  quantity REAL DEFAULT 1,
  unit TEXT,
  status TEXT DEFAULT 'SUCCESS', -- SUCCESS, FAILED, DUPLICATE, NOT_FOUND, MISMATCH
  error_message TEXT,
  timestamp INTEGER,
  created_at INTEGER,
  FOREIGN KEY (barcode_id) REFERENCES barcodes(id),
  FOREIGN KEY (location_id) REFERENCES storage_location(id),
  FOREIGN KEY (scanned_by) REFERENCES users(id)
);

-- Batch Scan Sessions
CREATE TABLE batch_scan_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_number TEXT UNIQUE NOT NULL,
  session_type TEXT, -- RECEIVING, DISPATCH, TRANSFER, INVENTORY, GATEPASS
  reference_type TEXT,
  reference_id INTEGER,
  location_id INTEGER,
  operator_id INTEGER,
  status TEXT DEFAULT 'IN_PROGRESS', -- IN_PROGRESS, COMPLETED, CANCELLED
  total_expected INTEGER,
  total_scanned INTEGER DEFAULT 0,
  total_matched INTEGER DEFAULT 0,
  total_mismatched INTEGER DEFAULT 0,
  started_at INTEGER,
  completed_at INTEGER,
  notes TEXT,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (location_id) REFERENCES storage_location(id),
  FOREIGN KEY (operator_id) REFERENCES users(id)
);

-- Batch Scan Items
CREATE TABLE batch_scan_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  barcode_value TEXT,
  barcode_id INTEGER,
  item_id INTEGER,
  expected_quantity REAL,
  scanned_quantity REAL DEFAULT 0,
  matched INTEGER DEFAULT 0,
  mismatch_reason TEXT, -- QUANTITY, WRONG_ITEM, DAMAGED, EXPIRED
  status TEXT DEFAULT 'PENDING', -- PENDING, SCANNED, VERIFIED, EXCEPTION
  scanned_at INTEGER,
  verified_by INTEGER,
  verified_at INTEGER,
  FOREIGN KEY (session_id) REFERENCES batch_scan_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (barcode_id) REFERENCES barcodes(id),
  FOREIGN KEY (item_id) REFERENCES inventory_item(id),
  FOREIGN KEY (verified_by) REFERENCES users(id)
);

-- Label Print Jobs
CREATE TABLE label_print_jobs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_number TEXT UNIQUE NOT NULL,
  barcode_definition_id INTEGER NOT NULL,
  entity_type TEXT NOT NULL,
  entity_ids TEXT, -- JSON array of entity IDs
  label_data_json TEXT, -- JSON array of label data per entity
  copies INTEGER DEFAULT 1,
  printer_name TEXT,
  printer_type TEXT, -- ZEBRA, DATAMAX, SATO, BROTHER, GENERIC
  label_width_mm REAL,
  label_height_mm REAL,
  status TEXT DEFAULT 'QUEUED', -- QUEUED, PRINTING, COMPLETED, FAILED, CANCELLED
  printed_count INTEGER DEFAULT 0,
  failed_count INTEGER DEFAULT 0,
  error_log TEXT,
  requested_by INTEGER,
  requested_at INTEGER,
  started_at INTEGER,
  completed_at INTEGER,
  FOREIGN KEY (barcode_definition_id) REFERENCES barcode_definitions(id),
  FOREIGN KEY (requested_by) REFERENCES users(id)
);

-- Printer Configurations
CREATE TABLE printer_configs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  printer_type TEXT, -- ZEBRA_ZPL, DATAMAX_DPL, SATO_SBPL, EPSON_ESCPOS, GENERIC
  connection_type TEXT, -- USB, NETWORK, BLUETOOTH, SERIAL
  ip_address TEXT,
  port INTEGER,
  usb_vid_pid TEXT,
  bluetooth_mac TEXT,
  serial_port TEXT,
  baud_rate INTEGER,
  paper_width_mm REAL,
  paper_height_mm REAL,
  print_speed INTEGER,
  print_density INTEGER,
  is_default INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  test_print_command TEXT,
  created_at INTEGER,
  updated_at INTEGER
);