-- db/migrations/001_inventory_schema.sql
-- Migration: Add inventory and related tables for Cold Storage WMS

BEGIN TRANSACTION;

-- Extend audit_log to include entity_type and entity_id
ALTER TABLE audit_log RENAME TO audit_log_old;
CREATE TABLE audit_log(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  action TEXT,
  detail TEXT,
  timestamp INTEGER,
  entity_type TEXT,
  entity_id INTEGER
);
INSERT INTO audit_log (id, user_id, action, detail, timestamp)
SELECT id, user_id, action, detail, timestamp FROM audit_log_old;
DROP TABLE audit_log_old;

-- Inventory item
CREATE TABLE IF NOT EXISTS inventory_item(
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
CREATE TABLE IF NOT EXISTS storage_location(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  rack_id TEXT,
  shelf_id TEXT,
  bin_id TEXT,
  zone TEXT,
  capacity REAL,
  current_utilization REAL
);

-- Temperature log
CREATE TABLE IF NOT EXISTS temperature_log(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id INTEGER,
  location_id INTEGER,
  temperature REAL,
  humidity REAL,
  timestamp INTEGER,
  sensor_id TEXT
);

-- Transfer record
CREATE TABLE IF NOT EXISTS transfer_record(
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
