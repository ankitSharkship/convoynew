import '../entities/vehicle_entity.dart';
import '../entities/vehicle_verification_entity.dart';

abstract class VehicleRepository {
  Future<List<VehicleEntity>> getVehicles(String userId);

  Future<void> deleteVehicle({
    required String userId,
    required String vehicleId,
  });

  Future<VehicleVerificationEntity> verifyVehicle({
    required String userId,
    required String vehicleNumber,
  });

  Future<VehicleEntity> addVehicle({
    required String userId,
    required String vehicleNumber,
    required String truckType,
    required int capacity,
  });
}
