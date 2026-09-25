// lib/models/logistics_models.dart

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'gstin': gstin,
      'pan': pan,
      'license_number': licenseNumber,
      'rating': rating,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Carrier.fromMap(Map<String, dynamic> m) {
    return Carrier(
      id: m['id'] as int?,
      name: m['name'] as String,
      code: m['code'] as String?,
      contactPerson: m['contact_person'] as String?,
      phone: m['phone'] as String?,
      email: m['email'] as String?,
      address: m['address'] as String?,
      gstin: m['gstin'] as String?,
      pan: m['pan'] as String?,
      licenseNumber: m['license_number'] as String?,
      rating: (m['rating'] as num?)?.toDouble() ?? 0,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carrier_id': carrierId,
      'registration_number': registrationNumber,
      'vehicle_type': vehicleType,
      'capacity_weight': capacityWeight,
      'capacity_volume': capacityVolume,
      'capacity_pallets': capacityPallets,
      'temperature_controlled': temperatureControlled,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'gps_device_id': gpsDeviceId,
      'insurance_expiry': insuranceExpiry,
      'fitness_expiry': fitnessExpiry,
      'permit_expiry': permitExpiry,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'driver_license': driverLicense,
      'status': status,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> m) {
    return Vehicle(
      id: m['id'] as int?,
      carrierId: m['carrier_id'] as int?,
      registrationNumber: m['registration_number'] as String,
      vehicleType: m['vehicle_type'] as String?,
      capacityWeight: (m['capacity_weight'] as num?)?.toDouble(),
      capacityVolume: (m['capacity_volume'] as num?)?.toDouble(),
      capacityPallets: m['capacity_pallets'] as int?,
      temperatureControlled: m['temperature_controlled'] as int? ?? 0,
      minTemp: (m['min_temp'] as num?)?.toDouble(),
      maxTemp: (m['max_temp'] as num?)?.toDouble(),
      gpsDeviceId: m['gps_device_id'] as String?,
      insuranceExpiry: m['insurance_expiry'] as int?,
      fitnessExpiry: m['fitness_expiry'] as int?,
      permitExpiry: m['permit_expiry'] as int?,
      driverName: m['driver_name'] as String?,
      driverPhone: m['driver_phone'] as String?,
      driverLicense: m['driver_license'] as String?,
      status: m['status'] as String? ?? 'AVAILABLE',
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'origin': origin,
      'destination': destination,
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'toll_charges': tollCharges,
      'route_description': routeDescription,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Route.fromMap(Map<String, dynamic> m) {
    return Route(
      id: m['id'] as int?,
      code: m['code'] as String,
      name: m['name'] as String,
      origin: m['origin'] as String,
      destination: m['destination'] as String,
      distanceKm: (m['distance_km'] as num?)?.toDouble(),
      estimatedDurationMinutes: m['estimated_duration_minutes'] as int?,
      tollCharges: (m['toll_charges'] as num?)?.toDouble() ?? 0,
      routeDescription: m['route_description'] as String?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'route_id': routeId,
      'stop_order': stopOrder,
      'location_name': locationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'estimated_arrival': estimatedArrival,
      'estimated_departure': estimatedDeparture,
      'stop_type': stopType,
    };
  }

  factory RouteStop.fromMap(Map<String, dynamic> m) {
    return RouteStop(
      id: m['id'] as int?,
      routeId: m['route_id'] as int,
      stopOrder: m['stop_order'] as int,
      locationName: m['location_name'] as String,
      address: m['address'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      estimatedArrival: m['estimated_arrival'] as int?,
      estimatedDeparture: m['estimated_departure'] as int?,
      stopType: m['stop_type'] as String?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipment_number': shipmentNumber,
      'shipment_date': shipmentDate,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'carrier_id': carrierId,
      'vehicle_id': vehicleId,
      'route_id': routeId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'origin_address': originAddress,
      'destination_address': destinationAddress,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'status': status,
      'total_weight': totalWeight,
      'total_volume': totalVolume,
      'total_packages': totalPackages,
      'freight_charges': freightCharges,
      'additional_charges': additionalCharges,
      'total_freight': totalFreight,
      'loading_start_time': loadingStartTime,
      'loading_end_time': loadingEndTime,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'unloading_start_time': unloadingStartTime,
      'unloading_end_time': unloadingEndTime,
      'proof_of_delivery': proofOfDelivery,
      'pod_timestamp': podTimestamp,
      'pod_received_by': podReceivedBy,
      'narration': narration,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Shipment.fromMap(Map<String, dynamic> m) {
    return Shipment(
      id: m['id'] as int?,
      shipmentNumber: m['shipment_number'] as String,
      shipmentDate: m['shipment_date'] as int,
      referenceType: m['reference_type'] as String?,
      referenceId: m['reference_id'] as int?,
      carrierId: m['carrier_id'] as int?,
      vehicleId: m['vehicle_id'] as int?,
      routeId: m['route_id'] as int?,
      driverName: m['driver_name'] as String?,
      driverPhone: m['driver_phone'] as String?,
      originAddress: m['origin_address'] as String?,
      destinationAddress: m['destination_address'] as String?,
      originLat: (m['origin_lat'] as num?)?.toDouble(),
      originLng: (m['origin_lng'] as num?)?.toDouble(),
      destLat: (m['dest_lat'] as num?)?.toDouble(),
      destLng: (m['dest_lng'] as num?)?.toDouble(),
      status: m['status'] as String? ?? 'PLANNED',
      totalWeight: (m['total_weight'] as num?)?.toDouble() ?? 0,
      totalVolume: (m['total_volume'] as num?)?.toDouble() ?? 0,
      totalPackages: m['total_packages'] as int? ?? 0,
      freightCharges: (m['freight_charges'] as num?)?.toDouble() ?? 0,
      additionalCharges: (m['additional_charges'] as num?)?.toDouble() ?? 0,
      totalFreight: (m['total_freight'] as num?)?.toDouble() ?? 0,
      loadingStartTime: m['loading_start_time'] as int?,
      loadingEndTime: m['loading_end_time'] as int?,
      departureTime: m['departure_time'] as int?,
      arrivalTime: m['arrival_time'] as int?,
      unloadingStartTime: m['unloading_start_time'] as int?,
      unloadingEndTime: m['unloading_end_time'] as int?,
      proofOfDelivery: m['proof_of_delivery'] as String?,
      podTimestamp: m['pod_timestamp'] as int?,
      podReceivedBy: m['pod_received_by'] as String?,
      narration: m['narration'] as String?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'item_id': itemId,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'weight': weight,
      'volume': volume,
      'packages': packages,
      'temperature_required': temperatureRequired,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'loaded_quantity': loadedQuantity,
      'delivered_quantity': deliveredQuantity,
    };
  }

  factory ShipmentItem.fromMap(Map<String, dynamic> m) {
    return ShipmentItem(
      id: m['id'] as int?,
      shipmentId: m['shipment_id'] as int,
      itemId: m['item_id'] as int?,
      description: m['description'] as String?,
      quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
      unit: m['unit'] as String?,
      weight: (m['weight'] as num?)?.toDouble(),
      volume: (m['volume'] as num?)?.toDouble(),
      packages: m['packages'] as int? ?? 1,
      temperatureRequired: m['temperature_required'] as int? ?? 0,
      minTemp: (m['min_temp'] as num?)?.toDouble(),
      maxTemp: (m['max_temp'] as num?)?.toDouble(),
      loadedQuantity: (m['loaded_quantity'] as num?)?.toDouble() ?? 0,
      deliveredQuantity: (m['delivered_quantity'] as num?)?.toDouble() ?? 0,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'speed': speed,
      'heading': heading,
      'status': status,
      'temperature': temperature,
      'humidity': humidity,
      'battery_level': batteryLevel,
      'signal_strength': signalStrength,
      'timestamp': timestamp,
      'source': source,
    };
  }

  factory ShipmentTracking.fromMap(Map<String, dynamic> m) {
    return ShipmentTracking(
      id: m['id'] as int?,
      shipmentId: m['shipment_id'] as int,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      address: m['address'] as String?,
      speed: (m['speed'] as num?)?.toDouble(),
      heading: (m['heading'] as num?)?.toDouble(),
      status: m['status'] as String?,
      temperature: (m['temperature'] as num?)?.toDouble(),
      humidity: (m['humidity'] as num?)?.toDouble(),
      batteryLevel: (m['battery_level'] as num?)?.toDouble(),
      signalStrength: (m['signal_strength'] as num?)?.toDouble(),
      timestamp: m['timestamp'] as int,
      source: m['source'] as String?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'vehicle_id': vehicleId,
      'plan_date': planDate,
      'total_weight': totalWeight,
      'total_volume': totalVolume,
      'total_packages': totalPackages,
      'weight_utilization': weightUtilization,
      'volume_utilization': volumeUtilization,
      'pallet_count': palletCount,
      'loading_sequence': loadingSequence,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory LoadPlan.fromMap(Map<String, dynamic> m) {
    return LoadPlan(
      id: m['id'] as int?,
      shipmentId: m['shipment_id'] as int,
      vehicleId: m['vehicle_id'] as int,
      planDate: m['plan_date'] as int,
      totalWeight: (m['total_weight'] as num?)?.toDouble() ?? 0,
      totalVolume: (m['total_volume'] as num?)?.toDouble() ?? 0,
      totalPackages: m['total_packages'] as int? ?? 0,
      weightUtilization: (m['weight_utilization'] as num?)?.toDouble() ?? 0,
      volumeUtilization: (m['volume_utilization'] as num?)?.toDouble() ?? 0,
      palletCount: m['pallet_count'] as int? ?? 0,
      loadingSequence: m['loading_sequence'] as String?,
      status: m['status'] as String? ?? 'DRAFT',
      approvedBy: m['approved_by'] as int?,
      approvedAt: m['approved_at'] as int?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'load_plan_id': loadPlanId,
      'shipment_item_id': shipmentItemId,
      'load_order': loadOrder,
      'position_x': positionX,
      'position_y': positionY,
      'position_z': positionZ,
      'stackable': stackable,
      'fragile': fragile,
      'temperature_zone': temperatureZone,
    };
  }

  factory LoadPlanItem.fromMap(Map<String, dynamic> m) {
    return LoadPlanItem(
      id: m['id'] as int?,
      loadPlanId: m['load_plan_id'] as int,
      shipmentItemId: m['shipment_item_id'] as int,
      loadOrder: m['load_order'] as int?,
      positionX: (m['position_x'] as num?)?.toDouble(),
      positionY: (m['position_y'] as num?)?.toDouble(),
      positionZ: (m['position_z'] as num?)?.toDouble(),
      stackable: m['stackable'] as int? ?? 1,
      fragile: m['fragile'] as int? ?? 0,
      temperatureZone: m['temperature_zone'] as String?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carrier_id': carrierId,
      'route_id': routeId,
      'vehicle_type': vehicleType,
      'rate_type': rateType,
      'base_rate': baseRate,
      'min_charge': minCharge,
      'fuel_surcharge_percent': fuelSurchargePercent,
      'toll_included': tollIncluded,
      'gst_rate': gstRate,
      'effective_from': effectiveFrom,
      'effective_to': effectiveTo,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FreightRate.fromMap(Map<String, dynamic> m) {
    return FreightRate(
      id: m['id'] as int?,
      carrierId: m['carrier_id'] as int?,
      routeId: m['route_id'] as int?,
      vehicleType: m['vehicle_type'] as String?,
      rateType: m['rate_type'] as String,
      baseRate: (m['base_rate'] as num?)?.toDouble() ?? 0,
      minCharge: (m['min_charge'] as num?)?.toDouble() ?? 0,
      fuelSurchargePercent: (m['fuel_surcharge_percent'] as num?)?.toDouble() ?? 0,
      tollIncluded: m['toll_included'] as int? ?? 0,
      gstRate: (m['gst_rate'] as num?)?.toDouble() ?? 0,
      effectiveFrom: m['effective_from'] as int?,
      effectiveTo: m['effective_to'] as int?,
      isActive: m['is_active'] as int? ?? 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_number': billNumber,
      'bill_date': billDate,
      'carrier_id': carrierId,
      'shipment_id': shipmentId,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'distance_km': distanceKm,
      'weight_charged': weightCharged,
      'rate_applied': rateApplied,
      'base_freight': baseFreight,
      'fuel_surcharge': fuelSurcharge,
      'toll_charges': tollCharges,
      'other_charges': otherCharges,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'status': status,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt,
      'paid_date': paidDate,
      'narration': narration,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FreightBill.fromMap(Map<String, dynamic> m) {
    return FreightBill(
      id: m['id'] as int?,
      billNumber: m['bill_number'] as String,
      billDate: m['bill_date'] as int,
      carrierId: m['carrier_id'] as int,
      shipmentId: m['shipment_id'] as int?,
      routeId: m['route_id'] as int?,
      vehicleId: m['vehicle_id'] as int?,
      distanceKm: (m['distance_km'] as num?)?.toDouble(),
      weightCharged: (m['weight_charged'] as num?)?.toDouble(),
      rateApplied: (m['rate_applied'] as num?)?.toDouble(),
      baseFreight: (m['base_freight'] as num?)?.toDouble() ?? 0,
      fuelSurcharge: (m['fuel_surcharge'] as num?)?.toDouble() ?? 0,
      tollCharges: (m['toll_charges'] as num?)?.toDouble() ?? 0,
      otherCharges: (m['other_charges'] as num?)?.toDouble() ?? 0,
      cgstAmount: (m['cgst_amount'] as num?)?.toDouble() ?? 0,
      sgstAmount: (m['sgst_amount'] as num?)?.toDouble() ?? 0,
      igstAmount: (m['igst_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      status: m['status'] as String? ?? 'DRAFT',
      verifiedBy: m['verified_by'] as int?,
      verifiedAt: m['verified_at'] as int?,
      paidDate: m['paid_date'] as int?,
      narration: m['narration'] as String?,
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'maintenance_type': maintenanceType,
      'description': description,
      'cost': cost,
      'service_date': serviceDate,
      'next_due_date': nextDueDate,
      'odometer_reading': odometerReading,
      'service_provider': serviceProvider,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory VehicleMaintenance.fromMap(Map<String, dynamic> m) {
    return VehicleMaintenance(
      id: m['id'] as int?,
      vehicleId: m['vehicle_id'] as int,
      maintenanceType: m['maintenance_type'] as String?,
      description: m['description'] as String?,
      cost: (m['cost'] as num?)?.toDouble() ?? 0,
      serviceDate: m['service_date'] as int?,
      nextDueDate: m['next_due_date'] as int?,
      odometerReading: m['odometer_reading'] as int?,
      serviceProvider: m['service_provider'] as String?,
      status: m['status'] as String? ?? 'SCHEDULED',
      createdBy: m['created_by'] as int?,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}