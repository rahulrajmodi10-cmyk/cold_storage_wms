-- Finance/Accounts Module Schema

-- Chart of Accounts
CREATE TABLE chart_of_accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
  parent_id INTEGER,
  is_active INTEGER DEFAULT 1,
  gst_applicable INTEGER DEFAULT 0,
  gst_rate REAL DEFAULT 0,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (parent_id) REFERENCES chart_of_accounts(id)
);

-- Parties (Customers/Vendors)
CREATE TABLE parties (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- CUSTOMER, VENDOR, BOTH
  gstin TEXT,
  pan TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  pincode TEXT,
  phone TEXT,
  email TEXT,
  contact_person TEXT,
  credit_limit REAL DEFAULT 0,
  payment_terms INTEGER DEFAULT 30, -- days
  opening_balance REAL DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
);

-- Invoices
CREATE TABLE invoices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT UNIQUE NOT NULL,
  invoice_date INTEGER NOT NULL,
  due_date INTEGER,
  party_id INTEGER NOT NULL,
  type TEXT NOT NULL, -- SALES, PURCHASE, CREDIT_NOTE, DEBIT_NOTE
  status TEXT DEFAULT 'DRAFT', -- DRAFT, POSTED, CANCELLED, PAID
  subtotal REAL DEFAULT 0,
  tax_amount REAL DEFAULT 0,
  discount_amount REAL DEFAULT 0,
  total_amount REAL DEFAULT 0,
  paid_amount REAL DEFAULT 0,
  balance_amount REAL DEFAULT 0,
  narration TEXT,
  reference_type TEXT, -- GATEPASS, PURCHASE_ORDER, etc.
  reference_id INTEGER,
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (party_id) REFERENCES parties(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Invoice Items
CREATE TABLE invoice_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER NOT NULL,
  item_id INTEGER,
  description TEXT,
  hsn_code TEXT,
  quantity REAL NOT NULL,
  unit TEXT,
  rate REAL NOT NULL,
  discount_percent REAL DEFAULT 0,
  discount_amount REAL DEFAULT 0,
  taxable_amount REAL NOT NULL,
  gst_rate REAL DEFAULT 0,
  cgst_amount REAL DEFAULT 0,
  sgst_amount REAL DEFAULT 0,
  igst_amount REAL DEFAULT 0,
  total_amount REAL NOT NULL,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES inventory_item(id)
);

-- Payments (Receipts & Payments)
CREATE TABLE payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  payment_number TEXT UNIQUE NOT NULL,
  payment_date INTEGER NOT NULL,
  party_id INTEGER NOT NULL,
  type TEXT NOT NULL, -- RECEIPT, PAYMENT
  mode TEXT NOT NULL, -- CASH, BANK, UPI, CARD, CHEQUE
  bank_account_id INTEGER,
  cheque_number TEXT,
  cheque_date INTEGER,
  amount REAL NOT NULL,
  narration TEXT,
  reference_type TEXT, -- INVOICE, ADVANCE, etc.
  reference_id INTEGER,
  status TEXT DEFAULT 'POSTED', -- POSTED, CLEARED, BOUNCED, CANCELLED
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (party_id) REFERENCES parties(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (bank_account_id) REFERENCES chart_of_accounts(id)
);

-- Payment Allocations (Link payments to invoices)
CREATE TABLE payment_allocations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  payment_id INTEGER NOT NULL,
  invoice_id INTEGER NOT NULL,
  allocated_amount REAL NOT NULL,
  created_at INTEGER,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);

-- Bank Accounts
CREATE TABLE bank_accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  account_name TEXT NOT NULL,
  bank_name TEXT,
  account_number TEXT,
  ifsc_code TEXT,
  branch TEXT,
  account_type TEXT, -- CURRENT, SAVINGS, OD, CC
  opening_balance REAL DEFAULT 0,
  current_balance REAL DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
);

-- GST Returns
CREATE TABLE gst_returns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  return_type TEXT NOT NULL, -- GSTR1, GSTR3B
  period TEXT NOT NULL, -- YYYY-MM
  status TEXT DEFAULT 'DRAFT', -- DRAFT, FILED, AMENDED
  total_taxable_value REAL DEFAULT 0,
  total_cgst REAL DEFAULT 0,
  total_sgst REAL DEFAULT 0,
  total_igst REAL DEFAULT 0,
  total_cess REAL DEFAULT 0,
  filed_date INTEGER,
  acknowledgement_no TEXT,
  json_data TEXT, -- Store return JSON
  created_at INTEGER,
  updated_at INTEGER
);

-- Journal Entries (for manual adjustments)
CREATE TABLE journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_number TEXT UNIQUE NOT NULL,
  entry_date INTEGER NOT NULL,
  narration TEXT,
  reference_type TEXT,
  reference_id INTEGER,
  status TEXT DEFAULT 'POSTED', -- POSTED, REVERSED
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE journal_entry_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id INTEGER NOT NULL,
  account_id INTEGER NOT NULL,
  debit REAL DEFAULT 0,
  credit REAL DEFAULT 0,
  narration TEXT,
  FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
  FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id)
);

-- Purchase Orders
CREATE TABLE purchase_orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  po_number TEXT UNIQUE NOT NULL,
  po_date INTEGER NOT NULL,
  vendor_id INTEGER NOT NULL,
  expected_date INTEGER,
  status TEXT DEFAULT 'DRAFT', -- DRAFT, SENT, PARTIAL, RECEIVED, CANCELLED
  subtotal REAL DEFAULT 0,
  tax_amount REAL DEFAULT 0,
  total_amount REAL DEFAULT 0,
  narration TEXT,
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (vendor_id) REFERENCES parties(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE purchase_order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  po_id INTEGER NOT NULL,
  item_id INTEGER,
  description TEXT,
  quantity REAL NOT NULL,
  unit TEXT,
  rate REAL NOT NULL,
  discount_percent REAL DEFAULT 0,
  tax_rate REAL DEFAULT 0,
  total_amount REAL NOT NULL,
  received_quantity REAL DEFAULT 0,
  FOREIGN KEY (po_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES inventory_item(id)
);

-- Sales Orders
CREATE TABLE sales_orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  so_number TEXT UNIQUE NOT NULL,
  so_date INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  expected_date INTEGER,
  status TEXT DEFAULT 'DRAFT', -- DRAFT, CONFIRMED, PARTIAL, DELIVERED, CANCELLED
  subtotal REAL DEFAULT 0,
  tax_amount REAL DEFAULT 0,
  total_amount REAL DEFAULT 0,
  narration TEXT,
  created_by INTEGER,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (customer_id) REFERENCES parties(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE sales_order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  so_id INTEGER NOT NULL,
  item_id INTEGER,
  description TEXT,
  quantity REAL NOT NULL,
  unit TEXT,
  rate REAL NOT NULL,
  discount_percent REAL DEFAULT 0,
  tax_rate REAL DEFAULT 0,
  total_amount REAL NOT NULL,
  delivered_quantity REAL DEFAULT 0,
  FOREIGN KEY (so_id) REFERENCES sales_orders(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES inventory_item(id)
);