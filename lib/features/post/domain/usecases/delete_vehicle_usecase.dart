import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  final VehicleRepository _repository;

  DeleteVehicleUseCase(this._repository);

  Future<void> execute({required String userId, required String vehicleId}) =>
      _repository.deleteVehicle(userId: userId, vehicleId: vehicleId);
}
