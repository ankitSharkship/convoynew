import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesUseCase {
  final VehicleRepository _repository;

  GetVehiclesUseCase(this._repository);

  Future<List<VehicleEntity>> execute(String userId) =>
      _repository.getVehicles(userId);
}
