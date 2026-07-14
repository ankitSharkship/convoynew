import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource _remote;

  VehicleRepositoryImpl(this._remote);

  @override
  Future<List<VehicleEntity>> getVehicles(String userId) =>
      _remote.getVehicles(userId);

  @override
  Future<void> deleteVehicle({
    required String userId,
    required String vehicleId,
  }) =>
      _remote.deleteVehicle(userId: userId, vehicleId: vehicleId);
}
