-- AI Camera Integration for Counting Schema

-- Camera Devices
CREATE TABLE camera_devices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  device_type TEXT, -- FIXED, MOBILE, HANDHELD, DRONE
  location_id INTEGER,
  ip_address TEXT,
  port INTEGER,
  username TEXT,
  password_hash TEXT,
  rtsp_url TEXT,
  resolution_width INTEGER DEFAULT 1920,
  resolution_height INTEGER DEFAULT 1080,
  fps INTEGER DEFAULT 30,
  model_path TEXT, -- Path to TFLite model
  model_version TEXT,
  confidence_threshold REAL DEFAULT 0.5,
  iou_threshold REAL DEFAULT 0.45,
  detection_classes TEXT, -- JSON array of class names to detect
  count_direction TEXT, -- IN, OUT, BOTH
  roi_coordinates TEXT, -- JSON polygon for region of interest
  calibration_factor REAL DEFAULT 1.0, -- Pixels to real-world units
  is_active INTEGER DEFAULT 1,
  last_heartbeat INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (location_id) REFERENCES storage_location(id)
);

-- Camera Counting Sessions (Loading/Unloading events)
CREATE TABLE counting_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_number TEXT UNIQUE NOT NULL,
  camera_id INTEGER NOT NULL,
  reference_type TEXT, -- GATEPASS, SHIPMENT, RECEIVING, INVENTORY_CHECK
  reference_id INTEGER,
  session_type TEXT NOT NULL, -- LOADING, UNLOADING, TRANSFER, CYCLE_COUNT
  status TEXT DEFAULT 'IN_PROGRESS', -- IN_PROGRESS, COMPLETED, VERIFIED, DISPUTED, CANCELLED
  expected_count INTEGER,
  ai_count INTEGER DEFAULT 0,
  manual_count INTEGER,
  verified_count INTEGER,
  discrepancy INTEGER DEFAULT 0,
  discrepancy_percent REAL DEFAULT 0,
  start_time INTEGER,
  end_time INTEGER,
  duration_seconds INTEGER,
  operator_id INTEGER,
  verified_by INTEGER,
  verified_at INTEGER,
  notes TEXT,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (camera_id) REFERENCES camera_devices(id),
  FOREIGN KEY (operator_id) REFERENCES users(id),
  FOREIGN KEY (verified_by) REFERENCES users(id)
);

-- Individual Detection Events
CREATE TABLE detection_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  frame_timestamp INTEGER NOT NULL, -- Relative to session start
  track_id INTEGER, -- Object tracking ID
  class_name TEXT, -- Detected class (box, pallet, crate, etc.)
  confidence REAL,
  bbox_x REAL, -- Normalized 0-1
  bbox_y REAL,
  bbox_width REAL,
  bbox_height REAL,
  centroid_x REAL,
  centroid_y REAL,
  direction TEXT, -- IN, OUT, UNKNOWN
  counted INTEGER DEFAULT 0, -- Whether this detection was counted
  count_timestamp INTEGER, -- When it crossed the count line
  image_path TEXT, -- Cropped detection image
  created_at INTEGER,
  FOREIGN KEY (session_id) REFERENCES counting_sessions(id) ON DELETE CASCADE
);

-- Count Verification Workflow
CREATE TABLE count_verifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  verification_type TEXT, -- MANUAL_RECOUNT, SUPERVISOR_APPROVAL, WEIGHT_BASED, BARCODE_MATCH
  verifier_id INTEGER NOT NULL,
  original_count INTEGER,
  verified_count INTEGER,
  variance INTEGER,
  variance_percent REAL,
  status TEXT DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, NEEDS_RECOUNT
  verification_notes TEXT,
  evidence_images TEXT, -- JSON array of image paths
  started_at INTEGER,
  completed_at INTEGER,
  created_at INTEGER,
  FOREIGN KEY (session_id) REFERENCES counting_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (verifier_id) REFERENCES users(id)
);

-- Camera Calibration Records
CREATE TABLE camera_calibrations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  camera_id INTEGER NOT NULL,
  calibration_type TEXT, -- DISTANCE, COUNT_LINE, ROI, LENS
  reference_object TEXT,
  reference_size REAL, -- Known size in meters/cm
  pixel_measurement REAL, -- Measured in pixels
  calibration_factor REAL, -- Calculated factor
  accuracy_percent REAL,
  calibrated_by INTEGER,
  calibrated_at INTEGER,
  is_active INTEGER DEFAULT 1,
  notes TEXT,
  FOREIGN KEY (camera_id) REFERENCES camera_devices(id),
  FOREIGN KEY (calibrated_by) REFERENCES users(id)
);

-- ML Model Registry
CREATE TABLE ml_models (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  version TEXT NOT NULL,
  model_type TEXT, -- YOLO, SSD, EFFICIENTDET, CUSTOM
  framework TEXT, -- TFLITE, ONNX, PYTORCH
  input_width INTEGER,
  input_height INTEGER,
  input_channels INTEGER DEFAULT 3,
  classes TEXT, -- JSON array of class names
  model_file_path TEXT,
  label_file_path TEXT,
  metrics_json TEXT, -- mAP, precision, recall per class
  training_data_info TEXT,
  is_active INTEGER DEFAULT 1,
  deployed_at INTEGER,
  created_at INTEGER,
  updated_at INTEGER
);

-- Camera Alerts/Incidents
CREATE TABLE camera_alerts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  camera_id INTEGER NOT NULL,
  alert_type TEXT, -- DISCREPANCY, CAMERA_OFFLINE, LOW_CONFIDENCE, OBSTRUCTION, TAMPERING
  severity TEXT, -- LOW, MEDIUM, HIGH, CRITICAL
  message TEXT,
  session_id INTEGER,
  detection_event_id INTEGER,
  acknowledged INTEGER DEFAULT 0,
  acknowledged_by INTEGER,
  acknowledged_at INTEGER,
  resolved INTEGER DEFAULT 0,
  resolved_by INTEGER,
  resolved_at INTEGER,
  created_at INTEGER,
  FOREIGN KEY (camera_id) REFERENCES camera_devices(id),
  FOREIGN KEY (session_id) REFERENCES counting_sessions(id),
  FOREIGN KEY (detection_event_id) REFERENCES detection_events(id),
  FOREIGN KEY (acknowledged_by) REFERENCES users(id),
  FOREIGN KEY (resolved_by) REFERENCES users(id)
);