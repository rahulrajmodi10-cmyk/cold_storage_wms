// lib/models/logistics_models.dart

import 'package:json_annotation/json_annotation.dart';

part 'logistics_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Carrier {
  final int? id;
  final String name;
  final String? code;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstin;
  final String? pan;
  final String? licenseNumber;
  final double rating;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  Carrier({
    this.id,
    required this.name,
    this.code,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.gstin,
    this.pan,
    this.licenseNumber,
    this.rating = 0,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory Carrier.fromJson(Map<String, dynamic> json) => _$CarrierFromJson(json);
  Map<String, dynamic> toJson() => _$CarrierToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Vehicle {
  final int? id;
  final int? carrierId;
  final String registrationNumber;
  final String? vehicleType; // TRUCK, CONTAINER, REEFER, VAN, PICKUP
  final double? capacityWeight; // kg
  final double? capacityVolume; // cubic meters
  final int? capacityPallets;
  final int temperatureControlled;
  final double? minTemp;
  final double? maxTemp;
  final String? gpsDeviceId;
  final int? insuranceExpiry;
  final int? fitnessExpiry;
  final int? permitExpiry;
  final String? driverName;
  final String? driverPhone;
  final String? driverLicense;
  final String status; // AVAILABLE, IN_TRANSIT, MAINTENANCE, RETIRED
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  Vehicle({
    this.id,
    this.carrierId,
    required this.registrationNumber,
    this.vehicleType,
    this.capacityWeight,
    this.capacityVolume,
    this.capacityPallets,
    this.temperatureControlled = 0,
    this.minTemp,
    this.maxTemp,
    this.gpsDeviceId,
    this.insuranceExpiry,
    this.fitnessExpiry,
    this.permitExpiry,
    this.driverName,
    this.driverPhone,
    this.driverLicense,
    this.status = 'AVAILABLE',
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Route {
  final int? id;
  final String code;
  final String name;
  final String origin;
  final String destination;
  final double? distanceKm;
  final int? estimatedDurationMinutes;
  final double tollCharges;
  final String? routeDescription;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  Route({
    this.id,
    required this.code,
    required this.name,
    required this.origin,
    required this.destination,
    this.distanceKm,
    this.estimatedDurationMinutes,
    this.tollCharges = 0,
    this.routeDescription,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RouteStop {
  final int? id;
  final int routeId;
  final int stopOrder;
  final String locationName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? estimatedArrival;
  final int? estimatedDeparture;
  final String? stopType; // PICKUP, DELIVERY, BOTH

  RouteStop({
    this.id,
    required this.routeId,
    required this.stopOrder,
    required this.locationName,
    this.address,
    this.latitude,
    this.longitude,
    this.estimatedArrival,
    this.estimatedDeparture,
    this.stopType,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) => _$RouteStopFromJson(json);
  Map<String, dynamic> toJson() => _$RouteStopToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Shipment {
  final int? id;
  final String shipmentNumber;
  final int shipmentDate;
  final String? referenceType; // SALES_ORDER, GATEPASS, TRANSFER
  final int? referenceId;
  final int? carrierId;
  final int? vehicleId;
  final int? routeId;
  final String? driverName;
  final String? driverPhone;
  final String? originAddress;
  final String? destinationAddress;
  final double? originLat;
  final double? originLng;
  final double? destLat;
  final double? destLng;
  final String status; // PLANNED, ASSIGNED, LOADED, IN_TRANSIT, ARRIVED, UNLOADED, DELIVERED, CANCELLED
  final double totalWeight;
  final double totalVolume;
  final int totalPackages;
  final double freightCharges;
  final double additionalCharges;
  final double totalFreight;
  final int? loadingStartTime;
  final int? loadingEndTime;
  final int? departureTime;
  final int? arrivalTime;
  final int? unloadingStartTime;
  final int? unloadingEndTime;
  final String? proofOfDelivery;
  final int? podTimestamp;
  final String? podReceivedBy;
  final String? narration;
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  Shipment({
    this.id,
    required this.shipmentNumber,
    required this.shipmentDate,
    this.referenceType,
    this.referenceId,
    this.carrierId,
    this.vehicleId,
    this.routeId,
    this.driverName,
    this.driverPhone,
    this.originAddress,
    this.destinationAddress,
    this.originLat,
    this.originLng,
    this.destLat,
    this.destLng,
    this.status = 'PLANNED',
    this.totalWeight = 0,
    this.totalVolume = 0,
    this.totalPackages = 0,
    this.freightCharges = 0,
    this.additionalCharges = 0,
    this.totalFreight = 0,
    this.loadingStartTime,
    this.loadingEndTime,
    this.departureTime,
    this.arrivalTime,
    this.unloadingStartTime,
    this.unloadingEndTime,
    this.proofOfDelivery,
    this.podTimestamp,
    this.podReceivedBy,
    this.narration,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => _$ShipmentFromJson(json);
  Map<String, dynamic> toJson() => _$ShipmentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ShipmentItem {
  final int? id;
  final int shipmentId;
  final int? itemId;
  final String? description;
  final double quantity;
  final String? unit;
  final double? weight;
  final double? volume;
  final int packages;
  final int temperatureRequired;
  final double? minTemp;
  final double? maxTemp;
  final double loadedQuantity;
  final double deliveredQuantity;

  ShipmentItem({
    this.id,
    required this.shipmentId,
    this.itemId,
    this.description,
    required this.quantity,
    this.unit,
    this.weight,
    this.volume,
    this.packages = 1,
    this.temperatureRequired = 0,
    this.minTemp,
    this.maxTemp,
    this.loadedQuantity = 0,
    this.deliveredQuantity = 0,
  });

  factory ShipmentItem.fromJson(Map<String, dynamic> json) => _$ShipmentItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShipmentItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ShipmentTracking {
  final int? id;
  final int shipmentId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? speed;
  final double? heading;
  final String? status; // LOADING, IN_TRANSIT, UNLOADING, DELIVERED, DELAYED
  final double? temperature;
  final double? humidity;
  final double? batteryLevel;
  final double? signalStrength;
  final int timestamp;
  final String? source; // GPS, MANUAL, DRIVER_APP

  ShipmentTracking({
    this.id,
    required this.shipmentId,
    this.latitude,
    this.longitude,
    this.address,
    this.speed,
    this.heading,
    this.status,
    this.temperature,
    this.humidity,
    this.batteryLevel,
    this.signalStrength,
    required this.timestamp,
    this.source,
  });

  factory ShipmentTracking.fromJson(Map<String, dynamic> json) => _$ShipmentTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$ShipmentTrackingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LoadPlan {
  final int? id;
  final int shipmentId;
  final int vehicleId;
  final int planDate;
  final double totalWeight;
  final double totalVolume;
  final int totalPackages;
  final double weightUtilization;
  final double volumeUtilization;
  final int palletCount;
  final String? loadingSequence; // JSON
  final String status; // DRAFT, APPROVED, EXECUTED
  final int? approvedBy;
  final int? approvedAt;
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  LoadPlan({
    this.id,
    required this.shipmentId,
    required this.vehicleId,
    required this.planDate,
    this.totalWeight = 0,
    this.totalVolume = 0,
    this.totalPackages = 0,
    this.weightUtilization = 0,
    this.volumeUtilization = 0,
    this.palletCount = 0,
    this.loadingSequence,
    this.status = 'DRAFT',
    this.approvedBy,
    this.approvedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory LoadPlan.fromJson(Map<String, dynamic> json) => _$LoadPlanFromJson(json);
  Map<String, dynamic> toJson() => _$LoadPlanToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LoadPlanItem {
  final int? id;
  final int loadPlanId;
  final int shipmentItemId;
  final int? loadOrder;
  final double? positionX;
  final double? positionY;
  final double? positionZ;
  final int stackable;
  final int fragile;
  final String? temperatureZone;

  LoadPlanItem({
    this.id,
    required this.loadPlanId,
    required this.shipmentItemId,
    this.loadOrder,
    this.positionX,
    this.positionY,
    this.positionZ,
    this.stackable = 1,
    this.fragile = 0,
    this.temperatureZone,
  });

  factory LoadPlanItem.fromJson(Map<String, dynamic> json) => _$LoadPlanItemFromJson(json);
  Map<String, dynamic> toJson() => _$LoadPlanItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FreightRate {
  final int? id;
  final int? carrierId;
  final int? routeId;
  final String? vehicleType;
  final String rateType; // PER_KM, PER_TON, PER_TON_KM, FLAT, PER_PALLET
  final double baseRate;
  final double minCharge;
  final double fuelSurchargePercent;
  final int tollIncluded;
  final double gstRate;
  final int? effectiveFrom;
  final int? effectiveTo;
  final int isActive;
  final int? createdAt;
  final int? updatedAt;

  FreightRate({
    this.id,
    this.carrierId,
    this.routeId,
    this.vehicleType,
    required this.rateType,
    required this.baseRate,
    this.minCharge = 0,
    this.fuelSurchargePercent = 0,
    this.tollIncluded = 0,
    this.gstRate = 0,
    this.effectiveFrom,
    this.effectiveTo,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory FreightRate.fromJson(Map<String, dynamic> json) => _$FreightRateFromJson(json);
  Map<String, dynamic> toJson() => _$FreightRateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FreightBill {
  final int? id;
  final String billNumber;
  final int billDate;
  final int carrierId;
  final int? shipmentId;
  final int? routeId;
  final int? vehicleId;
  final double? distanceKm;
  final double? weightCharged;
  final double? rateApplied;
  final double baseFreight;
  final double fuelSurcharge;
  final double tollCharges;
  final double otherCharges;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final String status; // DRAFT, VERIFIED, APPROVED, PAID, DISPUTED
  final int? verifiedBy;
  final int? verifiedAt;
  final int? paidDate;
  final String? narration;
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  FreightBill({
    this.id,
    required this.billNumber,
    required this.billDate,
    required this.carrierId,
    this.shipmentId,
    this.routeId,
    this.vehicleId,
    this.distanceKm,
    this.weightCharged,
    this.rateApplied,
    this.baseFreight = 0,
    this.fuelSurcharge = 0,
    this.tollCharges = 0,
    this.otherCharges = 0,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.igstAmount = 0,
    required this.totalAmount,
    this.status = 'DRAFT',
    this.verifiedBy,
    this.verifiedAt,
    this.paidDate,
    this.narration,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory FreightBill.fromJson(Map<String, dynamic> json) => _$FreightBillFromJson(json);
  Map<String, dynamic> toJson() => _$FreightBillToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VehicleMaintenance {
  final int? id;
  final int vehicleId;
  final String? maintenanceType; // PREVENTIVE, BREAKDOWN, ACCIDENT, INSPECTION
  final String? description;
  final double cost;
  final int? serviceDate;
  final int? nextDueDate;
  final int? odometerReading;
  final String? serviceProvider;
  final String status; // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
  final int? createdBy;
  final int? createdAt;
  final int? updatedAt;

  VehicleMaintenance({
    this.id,
    required this.vehicleId,
    this.maintenanceType,
    this.description,
    this.cost = 0,
    this.serviceDate,
    this.nextDueDate,
    this.odometerReading,
    this.serviceProvider,
    this.status = 'SCHEDULED',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleMaintenance.fromJson(Map<String, dynamic> json) => _$VehicleMaintenanceFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleMaintenanceToJson(this);
}