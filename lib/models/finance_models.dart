// lib/models/finance_models.dart

import 'package:json_annotation/json_annotation.dart';

part 'finance_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory ChartOfAccount.fromJson(Map<String, dynamic> json) => _$ChartOfAccountFromJson(json);
  Map<String, dynamic> toJson() => _$ChartOfAccountToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);
  Map<String, dynamic> toJson() => _$PartyToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory BankAccount.fromJson(Map<String, dynamic> json) => _$BankAccountFromJson(json);
  Map<String, dynamic> toJson() => _$BankAccountToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class JournalEntry {
  final int? id;
  final String entryNumber;
  final int entryDate;
  final String? narration;
  final String? referenceType;
  final int? referenceId;
  final String status; // POSTED, REVERSED
  final int? createdBy;
  final int? postedAt;
  final int? postedBy;
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
    this.postedAt,
    this.postedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory JournalEntryLine.fromJson(Map<String, dynamic> json) => _$JournalEntryLineFromJson(json);
  Map<String, dynamic> toJson() => _$JournalEntryLineToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => _$PurchaseOrderFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseOrderToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => _$PurchaseOrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseOrderItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory SalesOrder.fromJson(Map<String, dynamic> json) => _$SalesOrderFromJson(json);
  Map<String, dynamic> toJson() => _$SalesOrderToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) => _$SalesOrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$SalesOrderItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaxRate {
  final int? id;
  final String name;
  final String type; // CGST, SGST, IGST, CESS
  final double rate;
  final int? effectiveFrom;
  final int? effectiveTo;
  final int isActive;

  TaxRate({
    this.id,
    required this.name,
    required this.type,
    required this.rate,
    this.effectiveFrom,
    this.effectiveTo,
    this.isActive = 1,
  });

  factory TaxRate.fromJson(Map<String, dynamic> json) => _$TaxRateFromJson(json);
  Map<String, dynamic> toJson() => _$TaxRateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountReceivable {
  final int? id;
  @JsonKey(name: 'invoice_number')
  final String arNumber;
  final int partyId;
  final int invoiceId;
  @JsonKey(name: 'invoice_date')
  final int invoiceDate;
  final int dueDate;
  @JsonKey(name: 'total_amount')
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

  factory AccountReceivable.fromJson(Map<String, dynamic> json) => _$AccountReceivableFromJson(json);
  Map<String, dynamic> toJson() => _$AccountReceivableToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountPayable {
  final int? id;
  @JsonKey(name: 'invoice_number')
  final String apNumber;
  final int partyId;
  final int invoiceId;
  @JsonKey(name: 'invoice_date')
  final int invoiceDate;
  final int dueDate;
  @JsonKey(name: 'total_amount')
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

  factory AccountPayable.fromJson(Map<String, dynamic> json) => _$AccountPayableFromJson(json);
  Map<String, dynamic> toJson() => _$AccountPayableToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory GSTReturn.fromJson(Map<String, dynamic> json) => _$GSTReturnFromJson(json);
  Map<String, dynamic> toJson() => _$GSTReturnToJson(this);
}