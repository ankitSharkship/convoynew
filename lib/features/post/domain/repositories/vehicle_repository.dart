import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<List<VehicleEntity>> getVehicles(String userId);

  Future<void> deleteVehicle({
    required String userId,
    required String vehicleId,
  });
}
