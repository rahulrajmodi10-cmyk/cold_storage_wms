// lib/db/migrations/migration_002_finance.dart

import 'package:sqflite/sqflite.dart';

/// Migration 002: Finance Schema
/// Creates chart_of_accounts, parties, tax_rates, invoices, invoice_items,
/// payments, payment_allocations, accounts_receivable, accounts_payable,
/// journal_entries, journal_entry_lines, financial_periods, bank_accounts,
/// gst_returns, purchase_orders, purchase_order_items, sales_orders, sales_order_items
class Migration002Finance {
  static const int version = 2;

  static Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE chart_of_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id INTEGER,
        is_active INTEGER DEFAULT 1,
        gst_applicable INTEGER DEFAULT 0,
        gst_rate REAL DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (parent_id) REFERENCES chart_of_accounts(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE parties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
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
        payment_terms INTEGER DEFAULT 30,
        opening_balance REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE tax_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        rate REAL NOT NULL,
        effective_from INTEGER,
        effective_to INTEGER,
        is_active INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT UNIQUE NOT NULL,
        invoice_date INTEGER NOT NULL,
        due_date INTEGER,
        party_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        status TEXT DEFAULT 'DRAFT',
        subtotal REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        discount_amount REAL DEFAULT 0,
        total_amount REAL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        balance_amount REAL DEFAULT 0,
        narration TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        created_by INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (party_id) REFERENCES parties(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
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
      )
    ''');
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_number TEXT UNIQUE NOT NULL,
        payment_date INTEGER NOT NULL,
        party_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        mode TEXT NOT NULL,
        bank_account_id INTEGER,
        cheque_number TEXT,
        cheque_date INTEGER,
        amount REAL NOT NULL,
        narration TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        status TEXT DEFAULT 'POSTED',
        created_by INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (party_id) REFERENCES parties(id),
        FOREIGN KEY (created_by) REFERENCES users(id),
        FOREIGN KEY (bank_account_id) REFERENCES chart_of_accounts(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE payment_allocations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_id INTEGER NOT NULL,
        invoice_id INTEGER NOT NULL,
        allocated_amount REAL NOT NULL,
        created_at INTEGER,
        FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE accounts_receivable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        party_id INTEGER NOT NULL,
        invoice_number TEXT,
        invoice_date INTEGER,
        due_date INTEGER,
        total_amount REAL,
        paid_amount REAL DEFAULT 0,
        outstanding_amount REAL,
        status TEXT DEFAULT 'OPEN',
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id),
        FOREIGN KEY (party_id) REFERENCES parties(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE accounts_payable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        party_id INTEGER NOT NULL,
        invoice_number TEXT,
        invoice_date INTEGER,
        due_date INTEGER,
        total_amount REAL,
        paid_amount REAL DEFAULT 0,
        outstanding_amount REAL,
        status TEXT DEFAULT 'OPEN',
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id),
        FOREIGN KEY (party_id) REFERENCES parties(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_number TEXT UNIQUE NOT NULL,
        entry_date INTEGER NOT NULL,
        narration TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        status TEXT DEFAULT 'DRAFT',
        posted_at INTEGER,
        posted_by INTEGER,
        created_by INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE journal_entry_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        debit REAL DEFAULT 0,
        credit REAL DEFAULT 0,
        narration TEXT,
        FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE financial_periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_closed INTEGER DEFAULT 0,
        closed_at INTEGER,
        closed_by INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT NOT NULL,
        bank_name TEXT,
        account_number TEXT,
        ifsc_code TEXT,
        branch TEXT,
        account_type TEXT,
        opening_balance REAL DEFAULT 0,
        current_balance REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE gst_returns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_type TEXT NOT NULL,
        period TEXT NOT NULL,
        status TEXT DEFAULT 'DRAFT',
        total_taxable_value REAL DEFAULT 0,
        total_cgst REAL DEFAULT 0,
        total_sgst REAL DEFAULT 0,
        total_igst REAL DEFAULT 0,
        total_cess REAL DEFAULT 0,
        filed_date INTEGER,
        acknowledgement_no TEXT,
        json_data TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE purchase_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        po_number TEXT UNIQUE NOT NULL,
        po_date INTEGER NOT NULL,
        vendor_id INTEGER NOT NULL,
        expected_date INTEGER,
        status TEXT DEFAULT 'DRAFT',
        subtotal REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        total_amount REAL DEFAULT 0,
        narration TEXT,
        created_by INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (vendor_id) REFERENCES parties(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
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
      )
    ''');
    await db.execute('''
      CREATE TABLE sales_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        so_number TEXT UNIQUE NOT NULL,
        so_date INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        expected_date INTEGER,
        status TEXT DEFAULT 'DRAFT',
        subtotal REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        total_amount REAL DEFAULT 0,
        narration TEXT,
        created_by INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (customer_id) REFERENCES parties(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
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
      )
    ''');
  }

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS sales_order_items');
    await db.execute('DROP TABLE IF EXISTS sales_orders');
    await db.execute('DROP TABLE IF EXISTS purchase_order_items');
    await db.execute('DROP TABLE IF EXISTS purchase_orders');
    await db.execute('DROP TABLE IF EXISTS gst_returns');
    await db.execute('DROP TABLE IF EXISTS bank_accounts');
    await db.execute('DROP TABLE IF EXISTS financial_periods');
    await db.execute('DROP TABLE IF EXISTS journal_entry_lines');
    await db.execute('DROP TABLE IF EXISTS journal_entries');
    await db.execute('DROP TABLE IF EXISTS accounts_payable');
    await db.execute('DROP TABLE IF EXISTS accounts_receivable');
    await db.execute('DROP TABLE IF EXISTS payment_allocations');
    await db.execute('DROP TABLE IF EXISTS payments');
    await db.execute('DROP TABLE IF EXISTS invoice_items');
    await db.execute('DROP TABLE IF EXISTS invoices');
    await db.execute('DROP TABLE IF EXISTS tax_rates');
    await db.execute('DROP TABLE IF EXISTS parties');
    await db.execute('DROP TABLE IF EXISTS chart_of_accounts');
  }
}