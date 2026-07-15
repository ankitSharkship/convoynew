import '../entities/vehicle_verification_entity.dart';
import '../repositories/vehicle_repository.dart';

class VerifyVehicleUseCase {
  final VehicleRepository _repository;

  VerifyVehicleUseCase(this._repository);

  Future<VehicleVerificationEntity> execute({
    required String userId,
    required String vehicleNumber,
  }) => _repository.verifyVehicle(userId: userId, vehicleNumber: vehicleNumber);
}
