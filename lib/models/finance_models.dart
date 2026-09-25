// lib/models/finance_models.dart

class ChartOfAccount {
  final int? id;
  final String code;
  final String name;
  final String type; // ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
  final int? parentId;
  final int isActive;
  final int gstApplicable;
  final double gstRate;
  final double openingBalance;
  final int? createdAt;
  final int? updatedAt;

  ChartOfAccount({
    this.id,
    required this.code,
    required this.name,
    required this.type,
    this.parentId,
    this.isActive = 1,
    this.gstApplicable = 0,
    this.gstRate = 0,
    this.openingBalance = 0,
    this.createdAt,
    this.updatedAt,
  });

  double get balance => openingBalance;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'parent_id': parentId,
      'is_active': isActive,
      'gst_applicable': gstApplicable,
      'gst_rate': gstRate,
      'opening_balance': openingBalance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ChartOfAccount.fromMap(Map<String, dynamic> m) {
    return ChartOfAccount(
      id: m['id'] as int?,
      code: m['code'] as String,
      name: m['name'] as String,
      type: m['type'] as String,
      parentId: m['parent_id'] as int?,
      isActive: m['is_active'] as int? ?? 1,
      gstApplicable: m['gst_applicable'] as int? ?? 0,
      gstRate: (m['gst_rate'] as num?)?.toDouble() ?? 0,
      openingBalance: (m['opening_balance'] as num?)?.toDouble() ?? 0,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class Party {
  final int? id;
  final String name;
  final String type; // CUSTOMER, VENDOR, BOTH
  final String? gstin;
  final String? pan;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? contactPerson;
  final double creditLimit;
  final int paymentTerms;
  final double openingBalance;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  Party({
    this.id,
    required this.name,
    required this.type,
    this.gstin,
    this.pan,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.email,
    this.contactPerson,
    this.creditLimit = 0,
    this.paymentTerms = 30,
    this.openingBalance = 0,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'gstin': gstin,
      'pan': pan,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'email': email,
      'contact_person': contactPerson,
      'credit_limit': creditLimit,
      'payment_terms': paymentTerms,
      'opening_balance': openingBalance,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Party.fromMap(Map<String, dynamic> m) {
    return Party(
      id: m['id'] as int?,
      name: m['name'] as String,
      type: m['type'] as String,
      gstin: m['gstin'] as String?,
      pan: m['pan'] as String?,
      address: m['address'] as String?,
      city: m['city'] as String?,
      state: m['state'] as String?,
      pincode: m['pincode'] as String?,
      phone: m['phone'] as String?,
      email: m['email'] as String?,
      contactPerson: m['contact_person'] as String?,
      creditLimit: (m['credit_limit'] as num?)?.toDouble() ?? 0,
      paymentTerms: m['payment_terms'] as int? ?? 30,
      openingBalance: (m['opening_balance'] as num?)?.toDouble() ?? 0,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class Invoice {
  final int? id;
  final String invoiceNumber;
  final int invoiceDate;
  final int? dueDate;
  final int partyId;
  final String type; // SALES, PURCHASE, CREDIT_NOTE, DEBIT_NOTE
  final String status; // DRAFT, POSTED, CANCELLED, PAID
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final String? narration;
  final String? referenceType;
  final int? referenceId;
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    required this.partyId,
    required this.type,
    this.status = 'DRAFT',
    this.subtotal = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.balanceAmount = 0,
    this.narration,
    this.referenceType,
    this.referenceId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'due_date': dueDate,
      'party_id': partyId,
      'type': type,
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'narration': narration,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> m) {
    return Invoice(
      id: m['id'] as int?,
      invoiceNumber: m['invoice_number'] as String,
      invoiceDate: m['invoice_date'] as int,
      dueDate: m['due_date'] as int?,
      partyId: m['party_id'] as int,
      type: m['type'] as String,
      status: m['status'] as String? ?? 'DRAFT',
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (m['tax_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (m['discount_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (m['paid_amount'] as num?)?.toDouble() ?? 0,
      balanceAmount: (m['balance_amount'] as num?)?.toDouble() ?? 0,
      narration: m['narration'] as String?,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class InvoiceItem {
  final int? id;
  final int invoiceId;
  final int? itemId;
  final String? description;
  final String? hsnCode;
  final double quantity;
  final String? unit;
  final double rate;
  final double discountPercent;
  final double discountAmount;
  final double taxableAmount;
  final double gstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    this.itemId,
    this.description,
    this.hsnCode,
    required this.quantity,
    this.unit,
    required this.rate,
    this.discountPercent = 0,
    this.discountAmount = 0,
    required this.taxableAmount,
    this.gstRate = 0,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.igstAmount = 0,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'item_id': itemId,
      'description': description,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'taxable_amount': taxableAmount,
      'gst_rate': gstRate,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> m) {
    return InvoiceItem(
      id: m['id'] as int?,
      invoiceId: m['invoice_id'] as int,
      itemId: m['item_id'] as int?,
      description: m['description'] as String?,
      hsnCode: m['hsn_code'] as String?,
      quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
      unit: m['unit'] as String?,
      rate: (m['rate'] as num?)?.toDouble() ?? 0,
      discountPercent: (m['discount_percent'] as num?)?.toDouble() ?? 0,
      discountAmount: (m['discount_amount'] as num?)?.toDouble() ?? 0,
      taxableAmount: (m['taxable_amount'] as num?)?.toDouble() ?? 0,
      gstRate: (m['gst_rate'] as num?)?.toDouble() ?? 0,
      cgstAmount: (m['cgst_amount'] as num?)?.toDouble() ?? 0,
      sgstAmount: (m['sgst_amount'] as num?)?.toDouble() ?? 0,
      igstAmount: (m['igst_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Payment {
  final int? id;
  final String paymentNumber;
  final int paymentDate;
  final int partyId;
  final String type; // RECEIPT, PAYMENT
  final String mode; // CASH, BANK, UPI, CARD, CHEQUE
  final int? bankAccountId;
  final String? chequeNumber;
  final int? chequeDate;
  final double amount;
  final String? narration;
  final String? referenceType;
  final int? referenceId;
  final String status; // POSTED, CLEARED, BOUNCED, CANCELLED
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  Payment({
    this.id,
    required this.paymentNumber,
    required this.paymentDate,
    required this.partyId,
    required this.type,
    required this.mode,
    this.bankAccountId,
    this.chequeNumber,
    this.chequeDate,
    required this.amount,
    this.narration,
    this.referenceType,
    this.referenceId,
    this.status = 'POSTED',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payment_number': paymentNumber,
      'payment_date': paymentDate,
      'party_id': partyId,
      'type': type,
      'mode': mode,
      'bank_account_id': bankAccountId,
      'cheque_number': chequeNumber,
      'cheque_date': chequeDate,
      'amount': amount,
      'narration': narration,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> m) {
    return Payment(
      id: m['id'] as int?,
      paymentNumber: m['payment_number'] as String,
      paymentDate: m['payment_date'] as int,
      partyId: m['party_id'] as int,
      type: m['type'] as String,
      mode: m['mode'] as String,
      bankAccountId: m['bank_account_id'] as int?,
      chequeNumber: m['cheque_number'] as String?,
      chequeDate: m['cheque_date'] as int?,
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      narration: m['narration'] as String?,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      status: m['status'] as String? ?? 'POSTED',
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class BankAccount {
  final int? id;
  final String accountName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branch;
  final String? accountType; // CURRENT, SAVINGS, OD, CC
  final double openingBalance;
  final double currentBalance;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  BankAccount({
    this.id,
    required this.accountName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branch,
    this.accountType,
    this.openingBalance = 0,
    this.currentBalance = 0,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_name': accountName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch': branch,
      'account_type': accountType,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> m) {
    return BankAccount(
      id: m['id'] as int?,
      accountName: m['account_name'] as String,
      bankName: m['bank_name'] as String?,
      accountNumber: m['account_number'] as String?,
      ifscCode: m['ifsc_code'] as String?,
      branch: m['branch'] as String?,
      accountType: m['account_type'] as String?,
      openingBalance: (m['opening_balance'] as num?)?.toDouble() ?? 0,
      currentBalance: (m['current_balance'] as num?)?.toDouble() ?? 0,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class JournalEntry {
  final int? id;
  final String entryNumber;
  final int entryDate;
  final String? narration;
  final String? referenceType;
  final int? referenceId;
  final String status; // POSTED, REVERSED
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  JournalEntry({
    this.id,
    required this.entryNumber,
    required this.entryDate,
    this.narration,
    this.referenceType,
    this.referenceId,
    this.status = 'POSTED',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_number': entryNumber,
      'entry_date': entryDate,
      'narration': narration,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> m) {
    return JournalEntry(
      id: m['id'] as int?,
      entryNumber: m['entry_number'] as String,
      entryDate: m['entry_date'] as int,
      narration: m['narration'] as String?,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      status: m['status'] as String? ?? 'POSTED',
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class JournalEntryLine {
  final int? id;
  final int entryId;
  final int accountId;
  final double debit;
  final double credit;
  final String? narration;

  JournalEntryLine({
    this.id,
    required this.entryId,
    required this.accountId,
    this.debit = 0,
    this.credit = 0,
    this.narration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_id': entryId,
      'account_id': accountId,
      'debit': debit,
      'credit': credit,
      'narration': narration,
    };
  }

  factory JournalEntryLine.fromMap(Map<String, dynamic> m) {
    return JournalEntryLine(
      id: m['id'] as int?,
      entryId: m['entry_id'] as int,
      accountId: m['account_id'] as int,
      debit: (m['debit'] as num?)?.toDouble() ?? 0,
      credit: (m['credit'] as num?)?.toDouble() ?? 0,
      narration: m['narration'] as String?,
    );
  }
}

class PurchaseOrder {
  final int? id;
  final String poNumber;
  final int poDate;
  final int vendorId;
  final int? expectedDate;
  final String status; // DRAFT, SENT, PARTIAL, RECEIVED, CANCELLED
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? narration;
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  PurchaseOrder({
    this.id,
    required this.poNumber,
    required this.poDate,
    required this.vendorId,
    this.expectedDate,
    this.status = 'DRAFT',
    this.subtotal = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.narration,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'po_number': poNumber,
      'po_date': poDate,
      'vendor_id': vendorId,
      'expected_date': expectedDate,
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'narration': narration,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> m) {
    return PurchaseOrder(
      id: m['id'] as int?,
      poNumber: m['po_number'] as String,
      poDate: m['po_date'] as int,
      vendorId: m['vendor_id'] as int,
      expectedDate: m['expected_date'] as int?,
      status: m['status'] as String? ?? 'DRAFT',
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (m['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      narration: m['narration'] as String?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class PurchaseOrderItem {
  final int? id;
  final int poId;
  final int? itemId;
  final String? description;
  final double quantity;
  final String? unit;
  final double rate;
  final double discountPercent;
  final double taxRate;
  final double totalAmount;
  final double receivedQuantity;

  PurchaseOrderItem({
    this.id,
    required this.poId,
    this.itemId,
    this.description,
    required this.quantity,
    this.unit,
    required this.rate,
    this.discountPercent = 0,
    this.taxRate = 0,
    required this.totalAmount,
    this.receivedQuantity = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'po_id': poId,
      'item_id': itemId,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'discount_percent': discountPercent,
      'tax_rate': taxRate,
      'total_amount': totalAmount,
      'received_quantity': receivedQuantity,
    };
  }

  factory PurchaseOrderItem.fromMap(Map<String, dynamic> m) {
    return PurchaseOrderItem(
      id: m['id'] as int?,
      poId: m['po_id'] as int,
      itemId: m['item_id'] as int?,
      description: m['description'] as String?,
      quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
      unit: m['unit'] as String?,
      rate: (m['rate'] as num?)?.toDouble() ?? 0,
      discountPercent: (m['discount_percent'] as num?)?.toDouble() ?? 0,
      taxRate: (m['tax_rate'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      receivedQuantity: (m['received_quantity'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SalesOrder {
  final int? id;
  final String soNumber;
  final int soDate;
  final int customerId;
  final int? expectedDate;
  final String status; // DRAFT, CONFIRMED, PARTIAL, DELIVERED, CANCELLED
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? narration;
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  SalesOrder({
    this.id,
    required this.soNumber,
    required this.soDate,
    required this.customerId,
    this.expectedDate,
    this.status = 'DRAFT',
    this.subtotal = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.narration,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'so_number': soNumber,
      'so_date': soDate,
      'customer_id': customerId,
      'expected_date': expectedDate,
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'narration': narration,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SalesOrder.fromMap(Map<String, dynamic> m) {
    return SalesOrder(
      id: m['id'] as int?,
      soNumber: m['so_number'] as String,
      soDate: m['so_date'] as int,
      customerId: m['customer_id'] as int,
      expectedDate: m['expected_date'] as int?,
      status: m['status'] as String? ?? 'DRAFT',
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (m['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      narration: m['narration'] as String?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class SalesOrderItem {
  final int? id;
  final int soId;
  final int? itemId;
  final String? description;
  final double quantity;
  final String? unit;
  final double rate;
  final double discountPercent;
  final double taxRate;
  final double totalAmount;
  final double deliveredQuantity;

  SalesOrderItem({
    this.id,
    required this.soId,
    this.itemId,
    this.description,
    required this.quantity,
    this.unit,
    required this.rate,
    this.discountPercent = 0,
    this.taxRate = 0,
    required this.totalAmount,
    this.deliveredQuantity = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'so_id': soId,
      'item_id': itemId,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'discount_percent': discountPercent,
      'tax_rate': taxRate,
      'total_amount': totalAmount,
      'delivered_quantity': deliveredQuantity,
    };
  }

  factory SalesOrderItem.fromMap(Map<String, dynamic> m) {
    return SalesOrderItem(
      id: m['id'] as int?,
      soId: m['so_id'] as int,
      itemId: m['item_id'] as int?,
      description: m['description'] as String?,
      quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
      unit: m['unit'] as String?,
      rate: (m['rate'] as num?)?.toDouble() ?? 0,
      discountPercent: (m['discount_percent'] as num?)?.toDouble() ?? 0,
      taxRate: (m['tax_rate'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      deliveredQuantity: (m['delivered_quantity'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TaxRate {
  final int? id;
  final String name;
  final String type; // CGST, SGST, IGST, CESS
  final double rate;
  final int? effectiveFrom;
  final int? effectiveTo;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  TaxRate({
    this.id,
    required this.name,
    required this.type,
    required this.rate,
    this.effectiveFrom,
    this.effectiveTo,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rate': rate,
      'effective_from': effectiveFrom,
      'effective_to': effectiveTo,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TaxRate.fromMap(Map<String, dynamic> m) {
    return TaxRate(
      id: m['id'] as int?,
      name: m['name'] as String,
      type: m['type'] as String,
      rate: (m['rate'] as num?)?.toDouble() ?? 0,
      effectiveFrom: m['effective_from'] as int?,
      effectiveTo: m['effective_to'] as int?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class AccountReceivable {
  final int? id;
  final String arNumber;
  final int partyId;
  final int invoiceId;
  final int invoiceDate;
  final int dueDate;
  final double invoiceAmount;
  final double paidAmount;
  final double outstandingAmount;
  final String status; // OPEN, PARTIAL, CLOSED, OVERDUE
  final String? narration;
  final int? createdAt;
  final int? updatedAt;

  AccountReceivable({
    this.id,
    required this.arNumber,
    required this.partyId,
    required this.invoiceId,
    required this.invoiceDate,
    required this.dueDate,
    required this.invoiceAmount,
    this.paidAmount = 0,
    required this.outstandingAmount,
    this.status = 'OPEN',
    this.narration,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ar_number': arNumber,
      'party_id': partyId,
      'invoice_id': invoiceId,
      'invoice_date': invoiceDate,
      'due_date': dueDate,
      'invoice_amount': invoiceAmount,
      'paid_amount': paidAmount,
      'outstanding_amount': outstandingAmount,
      'status': status,
      'narration': narration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory AccountReceivable.fromMap(Map<String, dynamic> m) {
    return AccountReceivable(
      id: m['id'] as int?,
      arNumber: m['ar_number'] as String,
      partyId: m['party_id'] as int,
      invoiceId: m['invoice_id'] as int,
      invoiceDate: m['invoice_date'] as int,
      dueDate: m['due_date'] as int,
      invoiceAmount: (m['invoice_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (m['paid_amount'] as num?)?.toDouble() ?? 0,
      outstandingAmount: (m['outstanding_amount'] as num?)?.toDouble() ?? 0,
      status: m['status'] as String? ?? 'OPEN',
      narration: m['narration'] as String?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class AccountPayable {
  final int? id;
  final String apNumber;
  final int partyId;
  final int invoiceId;
  final int invoiceDate;
  final int dueDate;
  final double invoiceAmount;
  final double paidAmount;
  final double outstandingAmount;
  final String status; // OPEN, PARTIAL, CLOSED, OVERDUE
  final String? narration;
  final int? createdAt;
  final int? updatedAt;

  AccountPayable({
    this.id,
    required this.apNumber,
    required this.partyId,
    required this.invoiceId,
    required this.invoiceDate,
    required this.dueDate,
    required this.invoiceAmount,
    this.paidAmount = 0,
    required this.outstandingAmount,
    this.status = 'OPEN',
    this.narration,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ap_number': apNumber,
      'party_id': partyId,
      'invoice_id': invoiceId,
      'invoice_date': invoiceDate,
      'due_date': dueDate,
      'invoice_amount': invoiceAmount,
      'paid_amount': paidAmount,
      'outstanding_amount': outstandingAmount,
      'status': status,
      'narration': narration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory AccountPayable.fromMap(Map<String, dynamic> m) {
    return AccountPayable(
      id: m['id'] as int?,
      apNumber: m['ap_number'] as String,
      partyId: m['party_id'] as int,
      invoiceId: m['invoice_id'] as int,
      invoiceDate: m['invoice_date'] as int,
      dueDate: m['due_date'] as int,
      invoiceAmount: (m['invoice_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (m['paid_amount'] as num?)?.toDouble() ?? 0,
      outstandingAmount: (m['outstanding_amount'] as num?)?.toDouble() ?? 0,
      status: m['status'] as String? ?? 'OPEN',
      narration: m['narration'] as String?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class GSTReturn {
  final int? id;
  final String returnType; // GSTR1, GSTR3B
  final String period; // YYYY-MM
  final String status; // DRAFT, FILED, AMENDED
  final double totalTaxableValue;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalCess;
  final int? filedDate;
  final String? acknowledgementNo;
  final String? jsonData;
  final int? createdAt;
  final int? updatedAt;

  GSTReturn({
    this.id,
    required this.returnType,
    required this.period,
    this.status = 'DRAFT',
    this.totalTaxableValue = 0,
    this.totalCgst = 0,
    this.totalSgst = 0,
    this.totalIgst = 0,
    this.totalCess = 0,
    this.filedDate,
    this.acknowledgementNo,
    this.jsonData,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'return_type': returnType,
      'period': period,
      'status': status,
      'total_taxable_value': totalTaxableValue,
      'total_cgst': totalCgst,
      'total_sgst': totalSgst,
      'total_igst': totalIgst,
      'total_cess': totalCess,
      'filed_date': filedDate,
      'acknowledgement_no': acknowledgementNo,
      'json_data': jsonData,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory GSTReturn.fromMap(Map<String, dynamic> m) {
    return GSTReturn(
      id: m['id'] as int?,
      returnType: m['return_type'] as String,
      period: m['period'] as String,
      status: m['status'] as String? ?? 'DRAFT',
      totalTaxableValue: (m['total_taxable_value'] as num?)?.toDouble() ?? 0,
      totalCgst: (m['total_cgst'] as num?)?.toDouble() ?? 0,
      totalSgst: (m['total_sgst'] as num?)?.toDouble() ?? 0,
      totalIgst: (m['total_igst'] as num?)?.toDouble() ?? 0,
      totalCess: (m['total_cess'] as num?)?.toDouble() ?? 0,
      filedDate: m['filed_date'] as int?,
      acknowledgementNo: m['acknowledgement_no'] as String?,
      jsonData: m['json_data'] as String?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}