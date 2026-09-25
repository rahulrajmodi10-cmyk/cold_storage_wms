-- Logistics Module Schema

-- Carriers
CREATE TABLE carriers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  code TEXT UNIQUE,
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
);

-- Vehicles
CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  carrier_id INTEGER,
  registration_number TEXT UNIQUE NOT NULL,
  vehicle_type TEXT, -- TRUCK, CONTAINER, REEFER, VAN, PICKUP
  capacity_weight REAL, -- in kg
  capacity_volume REAL, -- in cubic meters
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
  status TEXT DEFAULT 'AVAILABLE', -- AVAILABLE, IN_TRANSIT, MAINTENANCE, RETIRED
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (carrier_id) REFERENCES carriers(id)
);

-- Routes
CREATE TABLE routes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
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
);

-- Route Stops (for multi-stop routes)
CREATE TABLE route_stops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route_id INTEGER NOT NULL,
  stop_order INTEGER NOT NULL,
  location_name TEXT NOT NULL,
  address TEXT,
  latitude REAL,
  longitude REAL,
  estimated_arrival INTEGER,
  estimated_departure INTEGER,
  stop_type TEXT, -- PICKUP, DELIVERY, BOTH
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
);

-- Shipments
CREATE TABLE shipments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shipment_number TEXT UNIQUE NOT NULL,
  shipment_date INTEGER NOT NULL,
  reference_type TEXT, -- SALES_ORDER, GATEPASS, TRANSFER
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
  status TEXT DEFAULT 'PLANNED', -- PLANNED, ASSIGNED, LOADED, IN_TRANSIT, ARRIVED, UNLOADED, DELIVERED, CANCELLED
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
  proof_of_delivery TEXT, -- Base64 image or file path
  pod_timestamp INTEGER,
  pod_received_by TEXT,
  narration TEXT,
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (carrier_id) REFERENCES carriers(id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (route_id) REFERENCES routes(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Shipment Items
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
  delivered_quantity REAL DEFAULT 0,
  FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES inventory_item(id)
);

-- Shipment Tracking (GPS/Status updates)
CREATE TABLE shipment_tracking (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shipment_id INTEGER NOT NULL,
  latitude REAL,
  longitude REAL,
  address TEXT,
  speed REAL,
  heading REAL,
  status TEXT, -- LOADING, IN_TRANSIT, UNLOADING, DELIVERED, DELAYED
  temperature REAL,
  humidity REAL,
  battery_level REAL,
  signal_strength REAL,
  timestamp INTEGER,
  source TEXT, -- GPS, MANUAL, DRIVER_APP
  FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
);

-- Load Planning
CREATE TABLE load_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shipment_id INTEGER NOT NULL,
  vehicle_id INTEGER NOT NULL,
  plan_date INTEGER NOT NULL,
  total_weight REAL DEFAULT 0,
  total_volume REAL DEFAULT 0,
  total_packages INTEGER DEFAULT 0,
  weight_utilization REAL DEFAULT 0, -- percentage
  volume_utilization REAL DEFAULT 0,
  pallet_count INTEGER DEFAULT 0,
  loading_sequence TEXT, -- JSON array of item loading order
  status TEXT DEFAULT 'DRAFT', -- DRAFT, APPROVED, EXECUTED
  approved_by INTEGER,
  approved_at INTEGER,
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (shipment_id) REFERENCES shipments(id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (approved_by) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Load Plan Items
CREATE TABLE load_plan_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  load_plan_id INTEGER NOT NULL,
  shipment_item_id INTEGER NOT NULL,
  load_order INTEGER,
  position_x REAL,
  position_y REAL,
  position_z REAL,
  stackable INTEGER DEFAULT 1,
  fragile INTEGER DEFAULT 0,
  temperature_zone TEXT,
  FOREIGN KEY (load_plan_id) REFERENCES load_plans(id) ON DELETE CASCADE,
  FOREIGN KEY (shipment_item_id) REFERENCES shipment_items(id)
);

-- Freight Rates
CREATE TABLE freight_rates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  carrier_id INTEGER,
  route_id INTEGER,
  vehicle_type TEXT,
  rate_type TEXT, -- PER_KM, PER_TON, PER_TON_KM, FLAT, PER_PALLET
  base_rate REAL NOT NULL,
  min_charge REAL DEFAULT 0,
  fuel_surcharge_percent REAL DEFAULT 0,
  toll_included INTEGER DEFAULT 0,
  gst_rate REAL DEFAULT 0,
  effective_from INTEGER,
  effective_to INTEGER,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (carrier_id) REFERENCES carriers(id),
  FOREIGN KEY (route_id) REFERENCES routes(id)
);

-- Freight Bills
CREATE TABLE freight_bills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  bill_number TEXT UNIQUE NOT NULL,
  bill_date INTEGER NOT NULL,
  carrier_id INTEGER NOT NULL,
  shipment_id INTEGER,
  route_id INTEGER,
  vehicle_id INTEGER,
  distance_km REAL,
  weight_charged REAL,
  rate_applied REAL,
  base_freight REAL DEFAULT 0,
  fuel_surcharge REAL DEFAULT 0,
  toll_charges REAL DEFAULT 0,
  other_charges REAL DEFAULT 0,
  cgst_amount REAL DEFAULT 0,
  sgst_amount REAL DEFAULT 0,
  igst_amount REAL DEFAULT 0,
  total_amount REAL NOT NULL,
  status TEXT DEFAULT 'DRAFT', -- DRAFT, VERIFIED, APPROVED, PAID, DISPUTED
  verified_by INTEGER,
  verified_at INTEGER,
  paid_date INTEGER,
  narration TEXT,
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (carrier_id) REFERENCES carriers(id),
  FOREIGN KEY (shipment_id) REFERENCES shipments(id),
  FOREIGN KEY (route_id) REFERENCES routes(id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (verified_by) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Vehicle Maintenance
CREATE TABLE vehicle_maintenance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  maintenance_type TEXT, -- PREVENTIVE, BREAKDOWN, ACCIDENT, INSPECTION
  description TEXT,
  cost REAL DEFAULT 0,
  service_date INTEGER,
  next_due_date INTEGER,
  odometer_reading INTEGER,
  service_provider TEXT,
  status TEXT DEFAULT 'SCHEDULED', -- SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);