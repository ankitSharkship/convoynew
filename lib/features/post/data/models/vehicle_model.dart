import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/vehicle_verification_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.vehicleNumber,
    required super.truckType,
    required super.capacity,
    required super.verificationStatus,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
    id: json['_id'] as String,
    vehicleNumber: json['vehicleNumber'] as String,
    truckType: json['truckType'] as String,
    capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    verificationStatus: json['verificationStatus'] as String? ?? 'pending',
  );
}

VehicleVerificationEntity vehicleVerificationFromJson(
  Map<String, dynamic> json,
) {
  return VehicleVerificationEntity(
    verified: json['verified'] as bool? ?? false,
    message: json['message'] as String? ?? '',
  );
}
