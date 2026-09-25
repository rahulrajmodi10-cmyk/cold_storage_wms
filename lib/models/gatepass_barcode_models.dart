// lib/models/gatepass_barcode_models.dart

class GatepassType {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final String? workflowType; // SIMPLE, APPROVAL_REQUIRED, MULTI_LEVEL_APPROVAL
  final int requiresVehicle;
  final int requiresDriver;
  final int requiresSecurityCheck;
  final int validityHours;
  final String? colorCode;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  GatepassType({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.workflowType,
    this.requiresVehicle = 1,
    this.requiresDriver = 1,
    this.requiresSecurityCheck = 1,
    this.validityHours = 24,
    this.colorCode,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'workflow_type': workflowType,
      'requires_vehicle': requiresVehicle,
      'requires_driver': requiresDriver,
      'requires_security_check': requiresSecurityCheck,
      'validity_hours': validityHours,
      'color_code': colorCode,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory GatepassType.fromMap(Map<String, dynamic> m) {
    return GatepassType(
      id: m['id'] as int?,
      code: m['code'] as String,
      name: m['name'] as String,
      description: m['description'] as String?,
      workflowType: m['workflow_type'] as String?,
      requiresVehicle: m['requires_vehicle'] as int? ?? 1,
      requiresDriver: m['requires_driver'] as int? ?? 1,
      requiresSecurityCheck: m['requires_security_check'] as int? ?? 1,
      validityHours: m['validity_hours'] as int? ?? 24,
      colorCode: m['color_code'] as String?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class Gatepass {
  final int? id;
  final String gatepassNumber;
  final int gatepassTypeId;
  final String? referenceType; // SALES_ORDER, PURCHASE_ORDER, TRANSFER, RETURN, SCRAP, OTHER
  final int? referenceId;
  final int? partyId;
  final String status; // DRAFT, SUBMITTED, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED, EXPIRED
  final String priority; // LOW, NORMAL, HIGH, URGENT

  // Vehicle Details
  final int? vehicleId;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? driverName;
  final String? driverPhone;
  final String? driverLicense;
  final String? driverPhotoPath;

  // Timing
  final int? requestedDate;
  final int? approvedDate;
  final int? validFrom;
  final int? validTo;
  final int? actualEntryTime;
  final int? actualExitTime;

  // Locations
  final int? entryGateId;
  final int? exitGateId;
  final String? originLocation;
  final String? destinationLocation;

  // Security
  final int? securityOfficerId;
  final String? securityCheckStatus; // PENDING, CLEARED, FLAGGED
  final String? securityNotes;
  final String? sealNumber;
  final int sealIntact;

  // QR Code
  final String? qrCodeData;
  final String? qrCodeImagePath;
  final int? qrGeneratedAt;

  // Counts
  final int totalItems;
  final double totalQuantity;
  final double totalWeight;
  final int totalPackages;

  // Verification
  final int? verifiedBy;
  final int? verifiedAt;
  final String? verificationMethod; // MANUAL, CAMERA_AI, BARCODE, WEIGHT
  final String? discrepancyNotes;

  // Approval
  final int? approvedBy;
  final int? approvedAt;
  final String? rejectionReason;

  // Completion
  final int? completedBy;
  final int? completedAt;
  final String? completionNotes;

  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  Gatepass({
    this.id,
    required this.gatepassNumber,
    required this.gatepassTypeId,
    this.referenceType,
    this.referenceId,
    this.partyId,
    this.status = 'DRAFT',
    this.priority = 'NORMAL',
    this.vehicleId,
    this.vehicleNumber,
    this.vehicleType,
    this.driverName,
    this.driverPhone,
    this.driverLicense,
    this.driverPhotoPath,
    this.requestedDate,
    this.approvedDate,
    this.validFrom,
    this.validTo,
    this.actualEntryTime,
    this.actualExitTime,
    this.entryGateId,
    this.exitGateId,
    this.originLocation,
    this.destinationLocation,
    this.securityOfficerId,
    this.securityCheckStatus,
    this.securityNotes,
    this.sealNumber,
    this.sealIntact = 1,
    this.qrCodeData,
    this.qrCodeImagePath,
    this.qrGeneratedAt,
    this.totalItems = 0,
    this.totalQuantity = 0,
    this.totalWeight = 0,
    this.totalPackages = 0,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationMethod,
    this.discrepancyNotes,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.completedBy,
    this.completedAt,
    this.completionNotes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gatepass_number': gatepassNumber,
      'gatepass_type_id': gatepassTypeId,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'party_id': partyId,
      'status': status,
      'priority': priority,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'driver_license': driverLicense,
      'driver_photo_path': driverPhotoPath,
      'requested_date': requestedDate,
      'approved_date': approvedDate,
      'valid_from': validFrom,
      'valid_to': validTo,
      'actual_entry_time': actualEntryTime,
      'actual_exit_time': actualExitTime,
      'entry_gate_id': entryGateId,
      'exit_gate_id': exitGateId,
      'origin_location': originLocation,
      'destination_location': destinationLocation,
      'security_officer_id': securityOfficerId,
      'security_check_status': securityCheckStatus,
      'security_notes': securityNotes,
      'seal_number': sealNumber,
      'seal_intact': sealIntact,
      'qr_code_data': qrCodeData,
      'qr_code_image_path': qrCodeImagePath,
      'qr_generated_at': qrGeneratedAt,
      'total_items': totalItems,
      'total_quantity': totalQuantity,
      'total_weight': totalWeight,
      'total_packages': totalPackages,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt,
      'verification_method': verificationMethod,
      'discrepancy_notes': discrepancyNotes,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'rejection_reason': rejectionReason,
      'completed_by': completedBy,
      'completed_at': completedAt,
      'completion_notes': completionNotes,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Gatepass.fromMap(Map<String, dynamic> m) {
    return Gatepass(
      id: m['id'] as int?,
      gatepassNumber: m['gatepass_number'] as String,
      gatepassTypeId: m['gatepass_type_id'] as int,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      partyId: m['party_id'] as int?,
      status: m['status'] as String? ?? 'DRAFT',
      priority: m['priority'] as String? ?? 'NORMAL',
      vehicleId: m['vehicle_id'] as int?,
      vehicleNumber: m['vehicle_number'] as String?,
      vehicleType: m['vehicle_type'] as String?,
      driverName: m['driver_name'] as String?,
      driverPhone: m['driver_phone'] as String?,
      driverLicense: m['driver_license'] as String?,
      driverPhotoPath: m['driver_photo_path'] as String?,
      requestedDate: m['requested_date'] as int?,
      approvedDate: m['approved_date'] as int?,
      validFrom: m['valid_from'] as int?,
      validTo: m['valid_to'] as int?,
      actualEntryTime: m['actual_entry_time'] as int?,
      actualExitTime: m['actual_exit_time'] as int?,
      entryGateId: m['entry_gate_id'] as int?,
      exitGateId: m['exit_gate_id'] as int?,
      originLocation: m['origin_location'] as String?,
      destinationLocation: m['destination_location'] as String?,
      securityOfficerId: m['security_officer_id'] as int?,
      securityCheckStatus: m['security_check_status'] as String?,
      securityNotes: m['security_notes'] as String?,
      sealNumber: m['seal_number'] as String?,
      sealIntact: m['seal_intact'] as int? ?? 1,
      qrCodeData: m['qr_code_data'] as String?,
      qrCodeImagePath: m['qr_code_image_path'] as String?,
      qrGeneratedAt: m['qr_generated_at'] as int?,
      totalItems: m['total_items'] as int? ?? 0,
      totalQuantity: (m['total_quantity'] as num?)?.toDouble() ?? 0,
      totalWeight: (m['total_weight'] as num?)?.toDouble() ?? 0,
      totalPackages: m['total_packages'] as int? ?? 0,
      verifiedBy: m['verified_by'] as int?,
      verifiedAt: m['verified_at'] as int?,
      verificationMethod: m['verification_method'] as String?,
      discrepancyNotes: m['discrepancy_notes'] as String?,
      approvedBy: m['approved_by'] as int?,
      approvedAt: m['approved_at'] as int?,
      rejectionReason: m['rejection_reason'] as String?,
      completedBy: m['completed_by'] as int?,
      completedAt: m['completed_at'] as int?,
      completionNotes: m['completion_notes'] as String?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class GatepassItem {
  final int? id;
  final int gatepassId;
  final int? itemId;
  final String? description;
  final String? hsnCode;
  final double quantity;
  final String? unit;
  final double? weightPerUnit;
  final double? totalWeight;
  final int packages;
  final String? packageType; // BOX, PALLET, CRATE, DRUM, BAG, LOOSE
  final int temperatureRequired;
  final double? minTemp;
  final double? maxTemp;
  final String? batchNumber;
  final int? expiryDate;
  final double verifiedQuantity;
  final double verifiedWeight;
  final int verifiedPackages;
  final String verificationStatus; // PENDING, VERIFIED, SHORT, EXCESS, DAMAGED
  final String? verificationNotes;

  GatepassItem({
    this.id,
    required this.gatepassId,
    this.itemId,
    this.description,
    this.hsnCode,
    required this.quantity,
    this.unit,
    this.weightPerUnit,
    this.totalWeight,
    this.packages = 1,
    this.packageType,
    this.temperatureRequired = 0,
    this.minTemp,
    this.maxTemp,
    this.batchNumber,
    this.expiryDate,
    this.verifiedQuantity = 0,
    this.verifiedWeight = 0,
    this.verifiedPackages = 0,
    this.verificationStatus = 'PENDING',
    this.verificationNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gatepass_id': gatepassId,
      'item_id': itemId,
      'description': description,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'weight_per_unit': weightPerUnit,
      'total_weight': totalWeight,
      'packages': packages,
      'package_type': packageType,
      'temperature_required': temperatureRequired,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'batch_number': batchNumber,
      'expiry_date': expiryDate,
      'verified_quantity': verifiedQuantity,
      'verified_weight': verifiedWeight,
      'verified_packages': verifiedPackages,
      'verification_status': verificationStatus,
      'verification_notes': verificationNotes,
    };
  }

  factory GatepassItem.fromMap(Map<String, dynamic> m) {
    return GatepassItem(
      id: m['id'] as int?,
      gatepassId: m['gatepass_id'] as int,
      itemId: m['item_id'] as int?,
      description: m['description'] as String?,
      hsnCode: m['hsn_code'] as String?,
      quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
      unit: m['unit'] as String?,
      weightPerUnit: (m['weight_per_unit'] as num?)?.toDouble(),
      totalWeight: (m['total_weight'] as num?)?.toDouble(),
      packages: m['packages'] as int? ?? 1,
      packageType: m['package_type'] as String?,
      temperatureRequired: m['temperature_required'] as int? ?? 0,
      minTemp: (m['min_temp'] as num?)?.toDouble(),
      maxTemp: (m['max_temp'] as num?)?.toDouble(),
      batchNumber: m['batch_number'] as String?,
      expiryDate: m['expiry_date'] as int?,
      verifiedQuantity: (m['verified_quantity'] as num?)?.toDouble() ?? 0,
      verifiedWeight: (m['verified_weight'] as num?)?.toDouble() ?? 0,
      verifiedPackages: m['verified_packages'] as int? ?? 0,
      verificationStatus: m['verification_status'] as String? ?? 'PENDING',
      verificationNotes: m['verification_notes'] as String?,
    );
  }
}

class SecurityGate {
  final int? id;
  final String code;
  final String name;
  final String? gateType; // ENTRY, EXIT, BOTH
  final String? locationDescription;
  final double? latitude;
  final double? longitude;
  final int? cameraId;
  final String? barrierType; // MANUAL, AUTOMATIC, BOOM, TURNSTILE
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  SecurityGate({
    this.id,
    required this.code,
    required this.name,
    this.gateType,
    this.locationDescription,
    this.latitude,
    this.longitude,
    this.cameraId,
    this.barrierType,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'gate_type': gateType,
      'location_description': locationDescription,
      'latitude': latitude,
      'longitude': longitude,
      'camera_id': cameraId,
      'barrier_type': barrierType,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SecurityGate.fromMap(Map<String, dynamic> m) {
    return SecurityGate(
      id: m['id'] as int?,
      code: m['code'] as String,
      name: m['name'] as String,
      gateType: m['gate_type'] as String?,
      locationDescription: m['location_description'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      cameraId: m['camera_id'] as int?,
      barrierType: m['barrier_type'] as String?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class GatepassVehicleLog {
  final int? id;
  final int gatepassId;
  final int gateId;
  final String logType; // ENTRY, EXIT
  final String? vehicleNumber;
  final String? driverName;
  final int driverVerified;
  final String? sealNumber;
  final int sealVerified;
  final int sealIntact;
  final String? photos; // JSON array
  final int? officerId;
  final int timestamp;
  final String? notes;

  GatepassVehicleLog({
    this.id,
    required this.gatepassId,
    required this.gateId,
    required this.logType,
    this.vehicleNumber,
    this.driverName,
    this.driverVerified = 0,
    this.sealNumber,
    this.sealVerified = 0,
    this.sealIntact = 1,
    this.photos,
    this.officerId,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gatepass_id': gatepassId,
      'gate_id': gateId,
      'log_type': logType,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
      'driver_verified': driverVerified,
      'seal_number': sealNumber,
      'seal_verified': sealVerified,
      'seal_intact': sealIntact,
      'photos': photos,
      'officer_id': officerId,
      'timestamp': timestamp,
      'notes': notes,
    };
  }

  factory GatepassVehicleLog.fromMap(Map<String, dynamic> m) {
    return GatepassVehicleLog(
      id: m['id'] as int?,
      gatepassId: m['gatepass_id'] as int,
      gateId: m['gate_id'] as int,
      logType: m['log_type'] as String,
      vehicleNumber: m['vehicle_number'] as String?,
      driverName: m['driver_name'] as String?,
      driverVerified: m['driver_verified'] as int? ?? 0,
      sealNumber: m['seal_number'] as String?,
      sealVerified: m['seal_verified'] as int? ?? 0,
      sealIntact: m['seal_intact'] as int? ?? 1,
      photos: m['photos'] as String?,
      officerId: m['officer_id'] as int?,
      timestamp: m['timestamp'] as int,
      notes: m['notes'] as String?,
    );
  }
}

class GatepassApproval {
  final int? id;
  final int gatepassId;
  final int level;
  final String? approverRole;
  final int? approverId;
  final String status; // PENDING, APPROVED, REJECTED, DELEGATED
  final int? actionAt;
  final String? comments;
  final int? delegatedTo;

  GatepassApproval({
    this.id,
    required this.gatepassId,
    required this.level,
    this.approverRole,
    this.approverId,
    this.status = 'PENDING',
    this.actionAt,
    this.comments,
    this.delegatedTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gatepass_id': gatepassId,
      'level': level,
      'approver_role': approverRole,
      'approver_id': approverId,
      'status': status,
      'action_at': actionAt,
      'comments': comments,
      'delegated_to': delegatedTo,
    };
  }

  factory GatepassApproval.fromMap(Map<String, dynamic> m) {
    return GatepassApproval(
      id: m['id'] as int?,
      gatepassId: m['gatepass_id'] as int,
      level: m['level'] as int,
      approverRole: m['approver_role'] as String?,
      approverId: m['approver_id'] as int?,
      status: m['status'] as String? ?? 'PENDING',
      actionAt: m['action_at'] as int?,
      comments: m['comments'] as String?,
      delegatedTo: m['delegated_to'] as int?,
    );
  }
}

class DispatchSchedule {
  final int? id;
  final String scheduleNumber;
  final int scheduleDate;
  final String? shift; // MORNING, AFTERNOON, NIGHT
  final int? gatepassId;
  final int? shipmentId;
  final int? vehicleId;
  final int? driverId;
  final int? loadingBayId;
  final int? scheduledStart;
  final int? scheduledEnd;
  final int? actualStart;
  final int? actualEnd;
  final String status; // SCHEDULED, IN_PROGRESS, COMPLETED, DELAYED, CANCELLED
  final int priority;
  final int? assignedBy;
  final int? createdAt;
  final int? updatedAt;

  DispatchSchedule({
    this.id,
    required this.scheduleNumber,
    required this.scheduleDate,
    this.shift,
    this.gatepassId,
    this.shipmentId,
    this.vehicleId,
    this.driverId,
    this.loadingBayId,
    this.scheduledStart,
    this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.status = 'SCHEDULED',
    this.priority = 0,
    this.assignedBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schedule_number': scheduleNumber,
      'schedule_date': scheduleDate,
      'shift': shift,
      'gatepass_id': gatepassId,
      'shipment_id': shipmentId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'loading_bay_id': loadingBayId,
      'scheduled_start': scheduledStart,
      'scheduled_end': scheduledEnd,
      'actual_start': actualStart,
      'actual_end': actualEnd,
      'status': status,
      'priority': priority,
      'assigned_by': assignedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory DispatchSchedule.fromMap(Map<String, dynamic> m) {
    return DispatchSchedule(
      id: m['id'] as int?,
      scheduleNumber: m['schedule_number'] as String,
      scheduleDate: m['schedule_date'] as int,
      shift: m['shift'] as String?,
      gatepassId: m['gatepass_id'] as int?,
      shipmentId: m['shipment_id'] as int?,
      vehicleId: m['vehicle_id'] as int?,
      driverId: m['driver_id'] as int?,
      loadingBayId: m['loading_bay_id'] as int?,
      scheduledStart: m['scheduled_start'] as int?,
      scheduledEnd: m['scheduled_end'] as int?,
      actualStart: m['actual_start'] as int?,
      actualEnd: m['actual_end'] as int?,
      status: m['status'] as String? ?? 'SCHEDULED',
      priority: m['priority'] as int? ?? 0,
      assignedBy: m['assigned_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class LoadingBay {
  final int? id;
  final String code;
  final String name;
  final String? bayType; // LOADING, UNLOADING, BOTH
  final int dockLevel;
  final double? maxVehicleLength;
  final double? maxVehicleWeight;
  final int temperatureControlled;
  final double? minTemp;
  final double? maxTemp;
  final int? cameraId;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  LoadingBay({
    this.id,
    required this.code,
    required this.name,
    this.bayType,
    this.dockLevel = 0,
    this.maxVehicleLength,
    this.maxVehicleWeight,
    this.temperatureControlled = 0,
    this.minTemp,
    this.maxTemp,
    this.cameraId,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'bay_type': bayType,
      'dock_level': dockLevel,
      'max_vehicle_length': maxVehicleLength,
      'max_vehicle_weight': maxVehicleWeight,
      'temperature_controlled': temperatureControlled,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'camera_id': cameraId,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory LoadingBay.fromMap(Map<String, dynamic> m) {
    return LoadingBay(
      id: m['id'] as int?,
      code: m['code'] as String,
      name: m['name'] as String,
      bayType: m['bay_type'] as String?,
      dockLevel: m['dock_level'] as int? ?? 0,
      maxVehicleLength: (m['max_vehicle_length'] as num?)?.toDouble(),
      maxVehicleWeight: (m['max_vehicle_weight'] as num?)?.toDouble(),
      temperatureControlled: m['temperature_controlled'] as int? ?? 0,
      minTemp: (m['min_temp'] as num?)?.toDouble(),
      maxTemp: (m['max_temp'] as num?)?.toDouble(),
      cameraId: m['camera_id'] as int?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

// ============================================
// Barcode/QR Code Models
// ============================================

class BarcodeDefinition {
  final int? id;
  final String code;
  final String name;
  final String symbology; // CODE128, QR_CODE, DATA_MATRIX, EAN13, UPCA, CODE39
  final String? prefix;
  final String? suffix;
  final String? formatTemplate;
  final double? widthMm;
  final double? heightMm;
  final double? moduleWidth;
  final int includeText;
  final int? fontSize;
  final String? errorCorrection; // L, M, Q, H
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  BarcodeDefinition({
    this.id,
    required this.code,
    required this.name,
    required this.symbology,
    this.prefix,
    this.suffix,
    this.formatTemplate,
    this.widthMm,
    this.heightMm,
    this.moduleWidth,
    this.includeText = 1,
    this.fontSize,
    this.errorCorrection,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbology': symbology,
      'prefix': prefix,
      'suffix': suffix,
      'format_template': formatTemplate,
      'width_mm': widthMm,
      'height_mm': heightMm,
      'module_width': moduleWidth,
      'include_text': includeText,
      'font_size': fontSize,
      'error_correction': errorCorrection,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory BarcodeDefinition.fromMap(Map<String, dynamic> m) {
    return BarcodeDefinition(
      id: m['id'] as int?,
      code: m['code'] as String,
      name: m['name'] as String,
      symbology: m['symbology'] as String,
      prefix: m['prefix'] as String?,
      suffix: m['suffix'] as String?,
      formatTemplate: m['format_template'] as String?,
      widthMm: (m['width_mm'] as num?)?.toDouble(),
      heightMm: (m['height_mm'] as num?)?.toDouble(),
      moduleWidth: (m['module_width'] as num?)?.toDouble(),
      includeText: m['include_text'] as int? ?? 1,
      fontSize: m['font_size'] as int?,
      errorCorrection: m['error_correction'] as String?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class Barcode {
  final int? id;
  final String barcodeValue;
  final int barcodeTypeId;
  final String entityType; // ITEM, GATEPASS, SHIPMENT, LOCATION, PALLET, BATCH, VEHICLE
  final int entityId;
  final String? labelData; // JSON
  final String? imagePath;
  final int printCount;
  final int? lastPrintedAt;
  final int? printedBy;
  final String status; // ACTIVE, VOIDED, REPLACED
  final int? expiresAt;
  final int? createdAt;
  final int? updatedAt;

  Barcode({
    this.id,
    required this.barcodeValue,
    required this.barcodeTypeId,
    required this.entityType,
    required this.entityId,
    this.labelData,
    this.imagePath,
    this.printCount = 0,
    this.lastPrintedAt,
    this.printedBy,
    this.status = 'ACTIVE',
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode_value': barcodeValue,
      'barcode_type_id': barcodeTypeId,
      'entity_type': entityType,
      'entity_id': entityId,
      'label_data': labelData,
      'image_path': imagePath,
      'print_count': printCount,
      'last_printed_at': lastPrintedAt,
      'printed_by': printedBy,
      'status': status,
      'expires_at': expiresAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Barcode.fromMap(Map<String, dynamic> m) {
    return Barcode(
      id: m['id'] as int?,
      barcodeValue: m['barcode_value'] as String,
      barcodeTypeId: m['barcode_type_id'] as int,
      entityType: m['entity_type'] as String,
      entityId: m['entity_id'] as int,
      labelData: m['label_data'] as String?,
      imagePath: m['image_path'] as String?,
      printCount: m['print_count'] as int? ?? 0,
      lastPrintedAt: m['last_printed_at'] as int?,
      printedBy: m['printed_by'] as int?,
      status: m['status'] as String? ?? 'ACTIVE',
      expiresAt: m['expires_at'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class BarcodeScan {
  final int? id;
  final int? scanSessionId;
  final String barcodeValue;
  final int? barcodeId;
  final String? entityType;
  final int? entityId;
  final String? scanType; // RECEIVING, PICKING, PACKING, DISPATCH, TRANSFER, CYCLE_COUNT, GATEPASS_VERIFY
  final int? locationId;
  final int? scannedBy;
  final String? deviceId;
  final double? latitude;
  final double? longitude;
  final double quantity;
  final String? unit;
  final String status; // SUCCESS, FAILED, DUPLICATE, NOT_FOUND, MISMATCH
  final String? errorMessage;
  final int timestamp;
  final int? createdAt;

  BarcodeScan({
    this.id,
    this.scanSessionId,
    required this.barcodeValue,
    this.barcodeId,
    this.entityType,
    this.entityId,
    this.scanType,
    this.locationId,
    this.scannedBy,
    this.deviceId,
    this.latitude,
    this.longitude,
    this.quantity = 1,
    this.unit,
    this.status = 'SUCCESS',
    this.errorMessage,
    required this.timestamp,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scan_session_id': scanSessionId,
      'barcode_value': barcodeValue,
      'barcode_id': barcodeId,
      'entity_type': entityType,
      'entity_id': entityId,
      'scan_type': scanType,
      'location_id': locationId,
      'scanned_by': scannedBy,
      'device_id': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'quantity': quantity,
      'unit': unit,
      'status': status,
      'error_message': errorMessage,
      'timestamp': timestamp,
      'created_at': createdAt,
    };
  }

  factory BarcodeScan.fromMap(Map<String, dynamic> m) {
    return BarcodeScan(
      id: m['id'] as int?,
      scanSessionId: m['scan_session_id'] as int?,
      barcodeValue: m['barcode_value'] as String,
      barcodeId: m['barcode_id'] as int?,
      entityType: m['entity_type'] as String?,
      entityId: m['entity_id'] as int?,
      scanType: m['scan_type'] as String?,
      locationId: m['location_id'] as int?,
      scannedBy: m['scanned_by'] as int?,
      deviceId: m['device_id'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      quantity: (m['quantity'] as num?)?.toDouble() ?? 1,
      unit: m['unit'] as String?,
      status: m['status'] as String? ?? 'SUCCESS',
      errorMessage: m['error_message'] as String?,
      timestamp: m['timestamp'] as int,
      createdAt: m['created_at'] as int?,
    );
  }
}

class BatchScanSession {
  final int? id;
  final String sessionNumber;
  final String? sessionType; // RECEIVING, DISPATCH, TRANSFER, INVENTORY, GATEPASS
  final String? referenceType;
  final int? referenceId;
  final int? locationId;
  final int? operatorId;
  final String status; // IN_PROGRESS, COMPLETED, CANCELLED
  final int totalExpected;
  final int totalScanned;
  final int totalMatched;
  final int totalMismatched;
  final int? startedAt;
  final int? completedAt;
  final String? notes;
  final int? createdAt;
  final int? updatedAt;

  BatchScanSession({
    this.id,
    required this.sessionNumber,
    this.sessionType,
    this.referenceType,
    this.referenceId,
    this.locationId,
    this.operatorId,
    this.status = 'IN_PROGRESS',
    this.totalExpected = 0,
    this.totalScanned = 0,
    this.totalMatched = 0,
    this.totalMismatched = 0,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_number': sessionNumber,
      'session_type': sessionType,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'location_id': locationId,
      'operator_id': operatorId,
      'status': status,
      'total_expected': totalExpected,
      'total_scanned': totalScanned,
      'total_matched': totalMatched,
      'total_mismatched': totalMismatched,
      'started_at': startedAt,
      'completed_at': completedAt,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory BatchScanSession.fromMap(Map<String, dynamic> m) {
    return BatchScanSession(
      id: m['id'] as int?,
      sessionNumber: m['session_number'] as String,
      sessionType: m['session_type'] as String?,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      locationId: m['location_id'] as int?,
      operatorId: m['operator_id'] as int?,
      status: m['status'] as String? ?? 'IN_PROGRESS',
      totalExpected: m['total_expected'] as int? ?? 0,
      totalScanned: m['total_scanned'] as int? ?? 0,
      totalMatched: m['total_matched'] as int? ?? 0,
      totalMismatched: m['total_mismatched'] as int? ?? 0,
      startedAt: m['started_at'] as int?,
      completedAt: m['completed_at'] as int?,
      notes: m['notes'] as String?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

class BatchScanItem {
  final int? id;
  final int sessionId;
  final String? barcodeValue;
  final int? barcodeId;
  final int? itemId;
  final double expectedQuantity;
  final double scannedQuantity;
  final int matched;
  final String? mismatchReason; // QUANTITY, WRONG_ITEM, DAMAGED, EXPIRED
  final String status; // PENDING, SCANNED, VERIFIED, EXCEPTION
  final int? scannedAt;
  final int? verifiedBy;
  final int? verifiedAt;

  BatchScanItem({
    this.id,
    required this.sessionId,
    this.barcodeValue,
    this.barcodeId,
    this.itemId,
    required this.expectedQuantity,
    this.scannedQuantity = 0,
    this.matched = 0,
    this.mismatchReason,
    this.status = 'PENDING',
    this.scannedAt,
    this.verifiedBy,
    this.verifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'barcode_value': barcodeValue,
      'barcode_id': barcodeId,
      'item_id': itemId,
      'expected_quantity': expectedQuantity,
      'scanned_quantity': scannedQuantity,
      'matched': matched,
      'mismatch_reason': mismatchReason,
      'status': status,
      'scanned_at': scannedAt,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt,
    };
  }

  factory BatchScanItem.fromMap(Map<String, dynamic> m) {
    return BatchScanItem(
      id: m['id'] as int?,
      sessionId: m['session_id'] as int,
      barcodeValue: m['barcode_value'] as String?,
      barcodeId: m['barcode_id'] as int?,
      itemId: m['item_id'] as int?,
      expectedQuantity: (m['expected_quantity'] as num?)?.toDouble() ?? 0,
      scannedQuantity: (m['scanned_quantity'] as num?)?.toDouble() ?? 0,
      matched: m['matched'] as int? ?? 0,
      mismatchReason: m['mismatch_reason'] as String?,
      status: m['status'] as String? ?? 'PENDING',
      scannedAt: m['scanned_at'] as int?,
      verifiedBy: m['verified_by'] as int?,
      verifiedAt: m['verified_at'] as int?,
    );
  }
}

class LabelPrintJob {
  final int? id;
  final String jobNumber;
  final int barcodeDefinitionId;
  final String entityType;
  final String? entityIds; // JSON array
  final String? labelDataJson; // JSON array
  final int copies;
  final String? printerName;
  final String? printerType; // ZEBRA, DATAMAX, SATO, BROTHER, GENERIC
  final double? labelWidthMm;
  final double? labelHeightMm;
  final String status; // QUEUED, PRINTING, COMPLETED, FAILED, CANCELLED
  final int printedCount;
  final int failedCount;
  final String? errorLog;
  final int? requestedBy;
  final int? requestedAt;
  final int? startedAt;
  final int? completedAt;

  LabelPrintJob({
    this.id,
    required this.jobNumber,
    required this.barcodeDefinitionId,
    required this.entityType,
    this.entityIds,
    this.labelDataJson,
    this.copies = 1,
    this.printerName,
    this.printerType,
    this.labelWidthMm,
    this.labelHeightMm,
    this.status = 'QUEUED',
    this.printedCount = 0,
    this.failedCount = 0,
    this.errorLog,
    this.requestedBy,
    this.requestedAt,
    this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_number': jobNumber,
      'barcode_definition_id': barcodeDefinitionId,
      'entity_type': entityType,
      'entity_ids': entityIds,
      'label_data_json': labelDataJson,
      'copies': copies,
      'printer_name': printerName,
      'printer_type': printerType,
      'label_width_mm': labelWidthMm,
      'label_height_mm': labelHeightMm,
      'status': status,
      'printed_count': printedCount,
      'failed_count': failedCount,
      'error_log': errorLog,
      'requested_by': requestedBy,
      'requested_at': requestedAt,
      'started_at': startedAt,
      'completed_at': completedAt,
    };
  }

  factory LabelPrintJob.fromMap(Map<String, dynamic> m) {
    return LabelPrintJob(
      id: m['id'] as int?,
      jobNumber: m['job_number'] as String,
      barcodeDefinitionId: m['barcode_definition_id'] as int,
      entityType: m['entity_type'] as String,
      entityIds: m['entity_ids'] as String?,
      labelDataJson: m['label_data_json'] as String?,
      copies: m['copies'] as int? ?? 1,
      printerName: m['printer_name'] as String?,
      printerType: m['printer_type'] as String?,
      labelWidthMm: (m['label_width_mm'] as num?)?.toDouble(),
      labelHeightMm: (m['label_height_mm'] as num?)?.toDouble(),
      status: m['status'] as String? ?? 'QUEUED',
      printedCount: m['printed_count'] as int? ?? 0,
      failedCount: m['failed_count'] as int? ?? 0,
      errorLog: m['error_log'] as String?,
      requestedBy: m['requested_by'] as int?,
      requestedAt: m['requested_at'] as int?,
      startedAt: m['started_at'] as int?,
      completedAt: m['completed_at'] as int?,
    );
  }
}

class PrinterConfig {
  final int? id;
  final String name;
  final String? printerType; // ZEBRA_ZPL, DATAMAX_DPL, SATO_SBPL, EPSON_ESCPOS, GENERIC
  final String? connectionType; // USB, NETWORK, BLUETOOTH, SERIAL
  final String? ipAddress;
  final int? port;
  final String? usbVidPid;
  final String? bluetoothMac;
  final String? serialPort;
  final int? baudRate;
  final double? paperWidthMm;
  final double? paperHeightMm;
  final int? printSpeed;
  final int? printDensity;
  final int isDefault;
  final int isActive;
  final String? testPrintCommand;
  final int? createdAt;
  final int? updatedAt;

  PrinterConfig({
    this.id,
    required this.name,
    this.printerType,
    this.connectionType,
    this.ipAddress,
    this.port,
    this.usbVidPid,
    this.bluetoothMac,
    this.serialPort,
    this.baudRate,
    this.paperWidthMm,
    this.paperHeightMm,
    this.printSpeed,
    this.printDensity,
    this.isDefault = 0,
    this.isActive = 1,
    this.testPrintCommand,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'printer_type': printerType,
      'connection_type': connectionType,
      'ip_address': ipAddress,
      'port': port,
      'usb_vid_pid': usbVidPid,
      'bluetooth_mac': bluetoothMac,
      'serial_port': serialPort,
      'baud_rate': baudRate,
      'paper_width_mm': paperWidthMm,
      'paper_height_mm': paperHeightMm,
      'print_speed': printSpeed,
      'print_density': printDensity,
      'is_default': isDefault,
      'is_active': isActive,
      'test_print_command': testPrintCommand,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PrinterConfig.fromMap(Map<String, dynamic> m) {
    return PrinterConfig(
      id: m['id'] as int?,
      name: m['name'] as String,
      printerType: m['printer_type'] as String?,
      connectionType: m['connection_type'] as String?,
      ipAddress: m['ip_address'] as String?,
      port: m['port'] as int?,
      usbVidPid: m['usb_vid_pid'] as String?,
      bluetoothMac: m['bluetooth_mac'] as String?,
      serialPort: m['serial_port'] as String?,
      baudRate: m['baud_rate'] as int?,
      paperWidthMm: (m['paper_width_mm'] as num?)?.toDouble(),
      paperHeightMm: (m['paper_height_mm'] as num?)?.toDouble(),
      printSpeed: m['print_speed'] as int?,
      printDensity: m['print_density'] as int?,
      isDefault: m['is_default'] as int? ?? 0,
      isActive: m['is_active'] as int? ?? 1,
      testPrintCommand: m['test_print_command'] as String?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}