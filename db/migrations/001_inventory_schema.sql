-- db/migrations/001_inventory_schema.sql
-- Migration: Add inventory and related tables for Cold Storage WMS

BEGIN TRANSACTION;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE,
  password_hash TEXT,
  role TEXT,
  face_embedding BLOB
);

-- Audit log table (with acknowledged column for alert functionality)
CREATE TABLE IF NOT EXISTS audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  action TEXT,
  detail TEXT,
  timestamp INTEGER,
  entity_type TEXT,
  entity_id INTEGER,
  acknowledged INTEGER DEFAULT 0
);

-- Face embeddings
CREATE TABLE IF NOT EXISTS face_embeddings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  embedding BLOB,
  created_at INTEGER
);

-- Settings
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT
);

-- OTPs table
CREATE TABLE IF NOT EXISTS otps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  phone TEXT,
  code TEXT,
  expires_at INTEGER,
  verified INTEGER DEFAULT 0
);

-- Alerts table
CREATE TABLE IF NOT EXISTS alert (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT,
  severity TEXT,
  message TEXT,
  target_id INTEGER,
  acknowledged INTEGER DEFAULT 0,
  created_at INTEGER
);

-- Inventory item
CREATE TABLE IF NOT EXISTS inventory_item (
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
);

-- Storage locations
CREATE TABLE IF NOT EXISTS storage_location (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  rack_id TEXT,
  shelf_id TEXT,
  bin_id TEXT,
  zone TEXT,
  capacity REAL,
  current_utilization REAL
);

-- Temperature log
CREATE TABLE IF NOT EXISTS temperature_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id INTEGER,
  location_id INTEGER,
  temperature REAL,
  humidity REAL,
  timestamp INTEGER,
  sensor_id TEXT
);

-- Transfer record
CREATE TABLE IF NOT EXISTS transfer_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id INTEGER,
  from_location INTEGER,
  to_location INTEGER,
  quantity INTEGER,
  operator_id INTEGER,
  timestamp INTEGER,
  reason TEXT
);

COMMIT;