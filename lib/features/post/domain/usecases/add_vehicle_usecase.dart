import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicleUseCase {
  final VehicleRepository _repository;

  AddVehicleUseCase(this._repository);

  Future<VehicleEntity> execute({
    required String userId,
    required String vehicleNumber,
    required String truckType,
    required double capacity,
    double? length,
    double? height,
  }) => _repository.addVehicle(
    userId: userId,
    vehicleNumber: vehicleNumber,
    truckType: truckType,
    capacity: capacity,
    length: length,
    height: height,
  );
}
